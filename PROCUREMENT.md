# Phase 0 — Procurement & Setup Checklist

Work through this before Phase 1. Prices approximate (mid-2026, single-unit
retail); see `hardware-research.md` for alternatives and "pick this if..."
guidance. This is the **starter (~$150)** order that gets you through Phase 1–2.

## A. Order — starter BOM
| ✓ | Item | Suggested part | Qty | ~Price | Notes |
|---|---|---|---|---|---|
| ☐ | Main servo | Feetech STS3215 (serial bus) | 1 | $20 | position + load feedback |
| ☐ | Microcontroller | ESP32-S3 DevKitC (or XIAO ESP32-S3) | 1 | $12 | |
| ☐ | Bus adapter | Waveshare Bus Servo Adapter | 1 | $6 | OR a 1 kΩ resistor (free) |
| ☐ | Buck converter | 12→5 V, 3 A | 1 | $4 | powers MyoWare/logic |
| ☐ | TPU filament | eSUN / Overture TPU 95A, 1 kg | 1 | $22 | fingers |
| ☐ | PETG filament | any brand, 1 kg | 1 | $20 | palm/rockers/wrist (may have on hand) |
| ☐ | Tendon line | KastKing/PowerPro UHMWPE 65–80 lb | 1 | $15 | |
| ☐ | PTFE liner | Capricorn 2×1 mm, 1 m | 1 | $10 | route at every bend |
| ☐ | Fingertip silicone | Ecoflex 00-30 trial unit | 1 | $45 | casts many pads |
| ☐ | Fasteners kit | M3 screws/nuts/grub + heat-set inserts | 1 | $12 | |
| ☐ | 2S Li-ion pack + BMS | 7.4 V, ≥5 A | 1 | (have/Phase 2) | can bench-power first |
| | **Starter subtotal** | | | **~$166** | |

## B. Order — Phase 3+ add-ons (defer until Phase 1–2 pass)
| ✓ | Item | Part | ~Price |
|---|---|---|---|
| ☐ | EMG sensor | MyoWare 2.0 + cable/electrode shield | $50 |
| ☐ | Electrodes | disposable gel pads (30-pack) | $10 |
| ☐ | Vacuum pump | 12 V mini diaphragm | $22 |
| ☐ | 3-way solenoid + check valve | 6–12 V | $15 |
| ☐ | 2× MOSFET modules | logic-level N-FET + flyback | $8 |
| ☐ | Latex balloons + ground coffee | jamming media | $8 |

## C. Consumables you likely already have
- Kitchen scale (fingertip-force test), calipers, multimeter
- Soldering iron (also sets heat-set inserts), heat-shrink
- Fishing-line crimps + pliers (or practice the Palomar knot)

## D. Toolchain setup
| ✓ | Tool | Purpose | Verify |
|---|---|---|---|
| ☐ | OpenSCAD | render CAD → STL | `openscad --version` |
| ☐ | Slicer (Cura / PrusaSlicer / OrcaSlicer) | STL → G-code | opens `build/stl/*.stl` |
| ☐ | Arduino IDE + ESP32 board package | flash firmware | compiles `firmware/prosthetic_hand` |
| ☐ | Python 3.11+ + `software/requirements.txt` | EMG pipeline | `python emg_train.py --selftest` |
| ☐ | Filament dryer / dry box | TPU must be dry | — |

### Toolchain notes
- **Firmware compile**: install the ESP32 Arduino core, select board
  "ESP32S3 Dev Module". No external libraries needed — the STS3215 driver is
  the bundled `sts_servo.h`.
- **Python**: `pip install -r software/requirements.txt`, then
  `python software/emg_train.py --selftest` should print a confusion matrix.
- **STLs are pre-rendered** in `build/stl/` — you can slice immediately even
  before installing OpenSCAD; OpenSCAD is only needed to change parameters.

## Phase 0 exit criteria
- [ ] All starter-BOM parts on hand
- [ ] TPU dried (6–8 h @ 55 °C or in a dry box)
- [ ] Slicer opens the STLs; firmware compiles; `emg_train.py --selftest` passes

Once all three hold, proceed to `ROADMAP.md` Phase 1 and `build/README.md`.
