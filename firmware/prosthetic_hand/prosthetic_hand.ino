// ============================================================
// Flexible prosthetic hand — ESP32-S3 control firmware
//
// Hardware: Feetech STS3215 on UART1 (half-duplex TTL),
//           MyoWare 2.0 envelope on ADC, pump + 3-way valve
//           on MOSFET gates for the granular-jamming pad.
//
// Control loop @100 Hz, telemetry CSV @10 Hz over USB serial.
// Serial commands (115200): o=open c=close g<0-100>=grip effort
//                           j=jam v=vent e=toggle EMG mode ?=status
//
// See ../../architecture.md §4 for the state machine spec and
// ../README.md for wiring.
// ============================================================

#include <Arduino.h>
#include "sts_servo.h"

// ---------------- pins ----------------
constexpr int PIN_SERVO_TX = 17;
constexpr int PIN_SERVO_RX = 18;
constexpr int PIN_EMG      = 4;   // ADC1_CH3, MyoWare ENV out
constexpr int PIN_PUMP     = 5;
constexpr int PIN_VALVE    = 6;   // energized = sealed, off = vent
constexpr int PIN_BUTTON   = 7;   // INPUT_PULLUP, manual open/close
constexpr int PIN_LED      = 15;

// ---------------- servo ----------------
constexpr uint8_t  SERVO_ID       = 1;
constexpr uint16_t POS_OPEN       = 1024;  // calibrate on assembly
constexpr uint16_t POS_CLOSED     = 3072;  // ~120 deg sweep
constexpr uint16_t CLOSE_STEP     = 12;    // ticks per 10ms => ~1.7s full close
constexpr int      GRIP_LOAD      = 350;   // present-load units, stop-closing threshold
constexpr int      JAM_LOAD       = 600;   // auto-stiffen threshold
constexpr int      OVERLOAD       = 900;   // back off above this
constexpr uint32_t JAM_DWELL_MS   = 1000;  // sustained high load before jamming
constexpr uint32_t PUMP_MS        = 1500;  // pump run time to evacuate the pad

// ---------------- EMG ----------------
constexpr uint32_t CALIB_MS        = 3000;
constexpr float    CLOSE_FRACTION  = 0.35; // of calibrated dynamic range
constexpr uint32_t DEBOUNCE_MS     = 150;
constexpr uint32_t DOUBLE_PULSE_MS = 600;  // two pulses inside this = open intent

enum State { ST_OPEN, ST_CLOSING, ST_HOLDING, ST_RELEASING };
const char *STATE_NAMES[] = {"OPEN", "CLOSING", "HOLDING", "RELEASING"};

StsServo servo(Serial1, SERVO_ID);

State    state         = ST_OPEN;
bool     emgMode       = false;
bool     jammed        = false;
uint16_t goalPos       = POS_OPEN;
int      gripLoadLimit = GRIP_LOAD;
float    emgFloor = 0, emgMax = 1;
float    emgEnv = 0;
uint32_t loadHighSince = 0, pumpOffAt = 0, lastPulseAt = 0, pulseStartAt = 0;
bool     pulseActive = false;

// 20-sample moving average over the MyoWare envelope
float emgSample() {
  static float buf[20] = {0};
  static int   idx = 0;
  static float sum = 0;
  float v = analogReadMilliVolts(PIN_EMG);
  sum += v - buf[idx];
  buf[idx] = v;
  idx = (idx + 1) % 20;
  return sum / 20.0f;
}

void calibrateEmg() {
  Serial.println("# EMG calibration: relax 3s...");
  uint32_t t0 = millis();
  float acc = 0; int n = 0;
  while (millis() - t0 < CALIB_MS) { acc += emgSample(); n++; delay(10); }
  emgFloor = acc / n;
  Serial.println("# now one strong squeeze (3s window)...");
  t0 = millis(); emgMax = emgFloor + 50; // minimum sane range
  while (millis() - t0 < CALIB_MS) { emgMax = max(emgMax, emgSample()); delay(10); }
  Serial.printf("# calibrated floor=%.0f max=%.0f mV\n", emgFloor, emgMax);
}

// Returns +1 close intent, -1 open intent, 0 none.
int emgIntent() {
  float thresh = emgFloor + CLOSE_FRACTION * (emgMax - emgFloor);
  bool above = emgEnv > thresh;
  uint32_t now = millis();

  if (above && !pulseActive) { pulseActive = true; pulseStartAt = now; }
  if (!above && pulseActive && now - pulseStartAt > DEBOUNCE_MS) {
    pulseActive = false;
    // quick double pulse => open; otherwise a completed pulse arms close
    if (now - lastPulseAt < DOUBLE_PULSE_MS) { lastPulseAt = 0; return -1; }
    lastPulseAt = now;
  }
  // sustained squeeze (not a quick pulse) => close
  if (pulseActive && now - pulseStartAt > 2 * DEBOUNCE_MS) return +1;
  return 0;
}

void jamStart() {
  digitalWrite(PIN_VALVE, HIGH);          // seal
  digitalWrite(PIN_PUMP, HIGH);           // evacuate
  pumpOffAt = millis() + PUMP_MS;
  jammed = true;
}

void jamVent() {
  digitalWrite(PIN_PUMP, LOW);
  digitalWrite(PIN_VALVE, LOW);           // 3-way vents to atmosphere
  jammed = false;
}

void enterState(State s) {
  state = s;
  if (s == ST_RELEASING) jamVent();       // always vent before opening
}

void fsmStep(int intent) {
  int load = servo.presentLoad();
  uint32_t now = millis();

  switch (state) {
    case ST_OPEN:
      if (intent > 0) enterState(ST_CLOSING);
      break;

    case ST_CLOSING:
      if (intent < 0) { enterState(ST_RELEASING); break; }
      goalPos = min<uint16_t>(goalPos + CLOSE_STEP, POS_CLOSED);
      if (load > gripLoadLimit || goalPos >= POS_CLOSED) enterState(ST_HOLDING);
      break;

    case ST_HOLDING:
      if (intent < 0) { enterState(ST_RELEASING); break; }
      if (load > OVERLOAD) goalPos = max<uint16_t>(goalPos - CLOSE_STEP, POS_OPEN);
      // auto-stiffen on sustained heavy load (e.g. carrying a bag)
      if (load > JAM_LOAD) {
        if (loadHighSince == 0) loadHighSince = now;
        else if (!jammed && now - loadHighSince > JAM_DWELL_MS) jamStart();
      } else loadHighSince = 0;
      break;

    case ST_RELEASING:
      goalPos = max<uint16_t>(goalPos - 3 * CLOSE_STEP, POS_OPEN);
      if (goalPos <= POS_OPEN) enterState(ST_OPEN);
      break;
  }

  if (jammed && pumpOffAt && now > pumpOffAt) {  // valve holds the vacuum
    digitalWrite(PIN_PUMP, LOW);
    pumpOffAt = 0;
  }
  servo.setGoalPosition(goalPos);
}

int dispatchCommand(const String &cmd) {
  if (cmd == "c") return +1;
  if (cmd == "o") return -1;
  if (cmd == "j") { jamStart(); return 0; }
  if (cmd == "v") { jamVent();  return 0; }
  if (cmd == "e") {
    emgMode = !emgMode;
    if (emgMode) calibrateEmg();
    Serial.printf("# EMG mode %s\n", emgMode ? "ON" : "OFF");
    return 0;
  }
  if (cmd.startsWith("g")) {  // grip effort 0-100 -> load limit
    int pct = constrain(cmd.substring(1).toInt(), 0, 100);
    gripLoadLimit = GRIP_LOAD + (OVERLOAD - GRIP_LOAD) * pct / 100;
    Serial.printf("# grip load limit=%d\n", gripLoadLimit);
    return 0;
  }
  if (cmd == "?")
    Serial.printf("# state=%s pos=%d load=%d jammed=%d emg=%d\n",
                  STATE_NAMES[state], servo.presentPosition(),
                  servo.presentLoad(), jammed, emgMode);
  return 0;
}

// Non-blocking command reader. Accumulates bytes into a bounded buffer and
// only dispatches on a complete line — NEVER blocks the 100 Hz control loop
// waiting for a newline (a partial/withheld serial line must not stall an
// actuator strapped to a limb). Oversized lines are dropped, not overflowed.
int serialIntent() {
  static char buf[24];
  static uint8_t len = 0;
  while (Serial.available()) {
    char ch = Serial.read();
    if (ch == '\n' || ch == '\r') {
      if (len == 0) continue;          // ignore blank lines / CRLF pairs
      buf[len] = '\0';
      String cmd(buf);
      len = 0;
      cmd.trim();
      int intent = dispatchCommand(cmd);
      if (intent != 0) return intent;  // surface open/close immediately
    } else if (len < sizeof(buf) - 1) {
      buf[len++] = ch;
    } else {
      len = 0;                         // overrun guard: discard the line
    }
  }
  return 0;
}

void setup() {
  Serial.begin(115200);
  Serial1.begin(1000000, SERIAL_8N1, PIN_SERVO_RX, PIN_SERVO_TX);
  pinMode(PIN_PUMP, OUTPUT);
  pinMode(PIN_VALVE, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_LED, OUTPUT);
  analogReadResolution(12);
  jamVent();
  servo.setGoalPosition(POS_OPEN);
  Serial.println("# prosthetic hand v1 — 'e' for EMG mode, '?' for status");
  Serial.println("millis,emg_raw,emg_env,state,servo_pos,servo_load,jammed");
}

void loop() {
  static uint32_t lastTick = 0, lastTelem = 0;
  uint32_t now = millis();
  if (now - lastTick < 10) return;      // 100 Hz superloop
  lastTick = now;

  emgEnv = emgSample();

  int intent = serialIntent();
  if (emgMode && intent == 0) intent = emgIntent();
  if (digitalRead(PIN_BUTTON) == LOW)   // manual override button
    intent = (state == ST_OPEN) ? +1 : -1;

  fsmStep(intent);

  digitalWrite(PIN_LED, state == ST_HOLDING ? HIGH : (now / 500) % 2);

  if (now - lastTelem >= 100) {         // 10 Hz telemetry CSV
    lastTelem = now;
    Serial.printf("%lu,%d,%.0f,%d,%d,%d,%d\n",
                  now, analogRead(PIN_EMG), emgEnv, (int)state,
                  servo.presentPosition(), servo.presentLoad(), jammed);
  }
}
