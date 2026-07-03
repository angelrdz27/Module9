# Firmware — ESP32-S3 hand controller

Arduino sketch in `prosthetic_hand/`. Requires the ESP32 Arduino core
(board: "ESP32S3 Dev Module"). No external libraries — the Feetech
STS3215 driver is the self-contained `sts_servo.h`.

## Wiring

| ESP32-S3 GPIO | Connects to | Notes |
|---|---|---|
| 17 (TX1) | STS3215 data line **through 1 kΩ resistor** | half-duplex trick |
| 18 (RX1) | STS3215 data line (direct) | |
| 4 | MyoWare 2.0 ENV output | ADC1_CH3, sensor powered at 3.3 V |
| 5 | Pump MOSFET gate (logic-level N-FET, e.g. IRLZ44N/AO3400) | flyback diode across pump |
| 6 | Valve MOSFET gate | flyback diode across solenoid; energized = sealed |
| 7 | Momentary button to GND | manual open/close override |
| 15 | Status LED (+ resistor) | solid = HOLDING, blink = idle |
| GND | common ground with servo/pump supply | **required** |

Power: servo + pump from 2S Li-ion (7.4–12 V, ≥5 A BMS); ESP32 from USB or a
buck converter. Never power the servo from the devkit's 5 V pin.

A Waveshare "Bus Servo Adapter" (~$6) replaces the resistor trick if you
prefer a clean TTL interface.

## Serial interface (115200 baud)

| Command | Effect |
|---|---|
| `c` / `o` | close / open |
| `g<0-100>` | grip effort → servo load limit |
| `j` / `v` | jam / vent the stiffening pad |
| `e` | toggle EMG mode (runs 2×3 s calibration: relax, then squeeze) |
| `?` | status line |

Telemetry streams as CSV at 10 Hz:
`millis,emg_raw,emg_env,state,servo_pos,servo_load,jammed`
(state: 0=OPEN 1=CLOSING 2=HOLDING 3=RELEASING). Feed it to
`../software/emg_collect.py` or the Arduino serial plotter.

## Calibration on first assembly
1. With tendons slack, send `o`, then set `POS_OPEN` to the servo's current
   position (`?`).
2. Manually close the fingers, note the position, set `POS_CLOSED`.
3. Grip an object and watch `servo_load` in telemetry; tune `GRIP_LOAD`
   (stop-closing threshold) and `JAM_LOAD` (auto-stiffen threshold).

## EMG intent scheme (v1, single channel)
- Sustained squeeze above 35 % of calibrated range → **close**.
- Two quick pulses within 600 ms → **open** (so a long squeeze can't
  accidentally drop the object).
- Upgrade path: 3-class classifier from `../software/emg_train.py`.
