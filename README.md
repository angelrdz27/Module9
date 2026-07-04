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
| `PROCUREMENT.md` | Phase 0 order checklist + toolchain setup |
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
| `build/` | Pre-rendered, manifold-checked STLs + preview PNGs (ready to slice) |
| `attacksurface.md` | Running security inventory of every system/vendor/tech + its exposure |
| `.claude/skills/attack-surface/` | Skill that maintains `attacksurface.md` |
| `.claude/workflows/AssessAttackSurface.js` | Workflow that assesses a surface & recommends test cadence |

### Quick start
1. Read `ROADMAP.md`; order the starter BOM via `PROCUREMENT.md`.
2. Slice the ready-made STLs in `build/stl/` (no CAD tool needed), or
   regenerate with `cad/render_all.sh` after editing parameters.
3. Flash `firmware/prosthetic_hand/`, drive it over serial (`c`/`o`).
4. Add EMG: `cd software && python emg_train.py --selftest` to check the
   pipeline, then collect real data and train.

### Current status
Phase 0/1 **design & toolchain complete**: all 12 parts render to
manifold-checked STLs (`build/`), the firmware compiles, and the EMG pipeline
passes its self-test. Remaining Phase 0/1 items are the physical
print-and-measure steps (`docs/test-protocol.md` T1–T4).

---

### Original task (Session 12)
See `Homework-12_MTMP.md` — dining philosophers problem.
