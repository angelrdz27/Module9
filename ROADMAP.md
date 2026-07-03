# Flexible Prosthetic Hand — Development Roadmap

Project docs:
- `prosthetic-hand-design.md` — design philosophy & concept directions
- `finray-cad-print-parameters.md` — fin-ray geometry & print settings
- `hardware-research.md` — component research & BOMs
- `architecture.md` — system architecture (this roadmap's technical companion)
- `cad/` — parametric OpenSCAD models
- `firmware/` — ESP32-S3 control firmware
- `software/` — EMG data collection & training pipeline

## Phase 0 — Procurement & setup (week 0)
- [ ] Order the ~$150 starter BOM (`hardware-research.md`)
- [ ] Dry-box or filament dryer for TPU
- [ ] Install OpenSCAD, Arduino IDE (ESP32 board package), Python 3.11+

**Exit criteria:** all parts on hand, TPU dried, toolchain compiles the firmware.

## Phase 1 — Single finger (weeks 1–2)
- [ ] Print the flow-calibration coupon (`finray-cad-print-parameters.md` §2)
- [ ] Print 3 finger variants from `cad/finray_finger.scad`:
      baseline (1.0 mm wall), floating-rib, graded-wall
- [ ] Bench test: clamp base, push mid-finger, verify tip wraps toward contact
- [ ] Add tendon + PTFE liner, pull by hand, measure fingertip force
      (kitchen scale, target 5–15 N)
- [ ] 500-cycle flex test; inspect rib junctions

**Exit criteria:** one variant selected; ≥5 N fingertip force; no cracks at 500 cycles.

## Phase 2 — Hand assembly, single servo (weeks 3–4)
- [ ] Print 4 fingers (80/88/82/65 mm) + thumb + palm + whiffle-tree
      (`cad/whiffletree.scad`)
- [ ] Route tendons through PTFE; re-tensionable anchor screws (UHMWPE creeps)
- [ ] Wire STS3215 to ESP32-S3 (`firmware/README.md` wiring table)
- [ ] Flash `firmware/prosthetic_hand/` — serial-command mode first (no EMG)
- [ ] Grasp test set: egg, 500 ml bottle, pen, paper sheet, apple

**Exit criteria:** 4/5 grasp-set objects held for 30 s at ≤60 % servo load.

## Phase 3 — EMG control (weeks 5–6)
- [ ] Add MyoWare 2.0 on forearm flexor; verify envelope signal in serial plotter
- [ ] Enable EMG mode in firmware: dual-threshold hysteresis → open/close
- [ ] Proportional mode: EMG amplitude → grip effort
- [ ] Collect training data with `software/emg_collect.py`; train classifier
      with `software/emg_train.py` (rest / close / open via co-contraction)

**Exit criteria:** user opens/closes hand reliably (>90 % of attempts) wearing
the sensor, 10-minute session without recalibration.

## Phase 4 — Variable stiffness (weeks 7–9)
- [ ] Build jamming pad (latex + coffee grounds) into palm
- [ ] Plumb pump + 3-way solenoid; MOSFET drivers on ESP32 pins
- [ ] Firmware: auto-stiffen when servo load exceeds threshold (heavy carry),
      vent on release
- [ ] Compare grasp-set performance jammed vs unjammed

**Exit criteria:** hand carries a 2 kg bag handle jammed; same hand handles an
egg unjammed, with no manual mode switch.

## Phase 5 — Iterate toward wearable (weeks 10+)
- [ ] Socket/wrist interface (study exiii HACKberry, e-NABLE patterns)
- [ ] Battery + BMS integration, power budget validation (`architecture.md` §6)
- [ ] Weight pass: target <450 g distal of wrist
- [ ] Upgrade path: Dynamixel XL330 current control, varioShore graded fingers,
      2–3 channel BioAmp EMG + on-device TinyML

## Risks & mitigations
| Risk | Mitigation |
|---|---|
| Tendon creep loosens grip over days | Re-tensionable anchor screws (Phase 2) |
| TPU delamination at ribs | Print orientation rule + 500-cycle gate (Phase 1) |
| EMG drift between sessions | Auto-calibration routine at startup (firmware) |
| Jamming membrane puncture | Spare balloons; latex sheet upgrade in Phase 5 |
| Servo overheating on sustained grip | Load-based duty limiting in firmware |
