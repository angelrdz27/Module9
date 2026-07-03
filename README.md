# Module9

This module contains all the tasks.

## Flexible Prosthetic Hand project

An out-of-the-box answer to "commercial prosthetic hands are too stiff":
instead of building a rigid hand and softening it, build a **soft hand that
stiffens on demand**. Passive fin-ray fingers conform with zero computation,
one servo drives all fingers through a self-balancing differential, and a
granular-jamming pad locks the hand rigid only when it needs to carry load.

### Documentation
| File | What it covers |
|---|---|
| `prosthetic-hand-design.md` | Design philosophy & concept directions |
| `finray-cad-print-parameters.md` | Fin-ray geometry & TPU print settings |
| `hardware-research.md` | Component research & ~$150 / ~$400 BOMs |
| `architecture.md` | System architecture (mechanical / electrical / firmware / software) |
| `ROADMAP.md` | Phased development plan with exit criteria |
| `docs/wiring-schematic.md` | Full electrical schematic & connection tables |
| `docs/assembly-guide.md` | Step-by-step build instructions |
| `docs/test-protocol.md` | Validation tests mapped to roadmap exit criteria |

### Build artifacts
| Directory | Contents |
|---|---|
| `cad/` | Parametric OpenSCAD models (fin-ray finger, whiffle-tree, palm chassis, wrist/socket, pad mold) |
| `firmware/` | ESP32-S3 control firmware (grasp FSM, STS3215 driver, EMG intent, jamming) |
| `software/` | EMG collection, classifier training, and fatigue cycle-test scripts |
| `docs/` | Wiring schematic, assembly guide, test protocol |

### Quick start
1. Read `ROADMAP.md` → order the starter BOM in `hardware-research.md`.
2. Generate fingers: `cd cad && openscad -o finger.stl finray_finger.scad`.
3. Flash `firmware/prosthetic_hand/`, drive it over serial (`c`/`o`).
4. Add EMG: `cd software && python emg_train.py --selftest` to check the
   pipeline, then collect real data and train.

---

### Original task (Session 12)
See `Homework-12_MTMP.md` — dining philosophers problem.
