// Minimal Feetech STS-series (STS3215) half-duplex TTL driver.
// Implements only what the hand needs: goal position write, present
// position/load reads. Protocol: 0xFF 0xFF ID LEN INSTR PARAMS CHKSUM,
// checksum = ~(sum of ID..last param) & 0xFF. STS registers are
// little-endian (unlike the older SCS series).
//
// Wiring: single data line. Cheapest interface: ESP32 TX -> 1k resistor
// -> data line, RX -> data line directly. TX idles high; the resistor
// lets the servo win the line when it replies.

#pragma once
#include <Arduino.h>

class StsServo {
 public:
  // STS3215 memory map (relevant subset)
  static constexpr uint8_t REG_GOAL_POSITION    = 42;  // 2 bytes, 0-4095
  static constexpr uint8_t REG_PRESENT_POSITION = 56;  // 2 bytes
  static constexpr uint8_t REG_PRESENT_LOAD     = 60;  // 2 bytes, bit10 = sign
  static constexpr uint8_t INSTR_WRITE = 0x03;
  static constexpr uint8_t INSTR_READ  = 0x02;

  StsServo(HardwareSerial &port, uint8_t id) : port_(port), id_(id) {}

  void setGoalPosition(uint16_t pos) {
    uint8_t p[] = {REG_GOAL_POSITION, (uint8_t)(pos & 0xFF), (uint8_t)(pos >> 8)};
    sendPacket(INSTR_WRITE, p, sizeof(p));
    drainEcho();
  }

  int presentPosition() { return readWord(REG_PRESENT_POSITION); }

  // Load magnitude 0-1000 (per-mille of stall); sign bit stripped.
  int presentLoad() {
    int raw = readWord(REG_PRESENT_LOAD);
    return raw < 0 ? lastLoad_ : (lastLoad_ = raw & 0x3FF);
  }

 private:
  HardwareSerial &port_;
  uint8_t id_;
  int lastLoad_ = 0;

  void sendPacket(uint8_t instr, const uint8_t *params, uint8_t n) {
    uint8_t len = n + 2;
    uint8_t sum = id_ + len + instr;
    port_.write(0xFF); port_.write(0xFF);
    port_.write(id_);  port_.write(len); port_.write(instr);
    for (uint8_t i = 0; i < n; i++) { port_.write(params[i]); sum += params[i]; }
    port_.write((uint8_t)(~sum));
    port_.flush();
  }

  // On a shared single-wire bus our own TX bytes echo back on RX.
  void drainEcho() {
    delayMicroseconds(200);
    while (port_.available()) port_.read();
  }

  // Read a 2-byte register; returns -1 on timeout/checksum error so the
  // caller can keep the last good value (fail-soft, see architecture.md §7).
  int readWord(uint8_t reg) {
    uint8_t p[] = {reg, 2};
    while (port_.available()) port_.read();  // clear stale bytes
    sendPacket(INSTR_READ, p, sizeof(p));
    drainEcho();

    // reply: FF FF ID LEN(=4) ERR LO HI CHKSUM
    uint8_t buf[8];
    uint32_t t0 = micros();
    int got = 0;
    while (got < 8 && micros() - t0 < 2000)
      if (port_.available()) buf[got++] = port_.read();
    if (got < 8 || buf[0] != 0xFF || buf[1] != 0xFF || buf[2] != id_) return -1;
    uint8_t sum = buf[2] + buf[3] + buf[4] + buf[5] + buf[6];
    if ((uint8_t)(~sum) != buf[7]) return -1;
    return buf[5] | (buf[6] << 8);
  }
};
