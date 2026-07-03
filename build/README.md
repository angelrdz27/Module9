# Build — pre-rendered print files (Phase 1)

STL files rendered from the parametric `../cad/*.scad` models, ready to slice.
Regenerate any of them with `../cad/render_all.sh` after editing parameters.

## Validation status
All parts rendered with OpenSCAD 2021.01 and report **`Simple: yes`** — i.e.
closed, manifold, 2-manifold solids with no self-intersections, which is what
a slicer requires. (Re-verify with `render_all.sh`, which fails loudly on any
non-simple result.)

| STL | Rendered | Manifold | Vertices (approx) |
|---|---|---|---|
| `finger_index.stl` (80 mm) | ✓ | ✓ | 925 |
| `finger_middle.stl` (88 mm) | ✓ | ✓ | ~930 |
| `finger_ring.stl` (82 mm) | ✓ | ✓ | ~930 |
| `finger_pinky.stl` (65 mm) | ✓ | ✓ | ~900 |
| `finger_floating.stl` (variant) | ✓ | ✓ | ~925 |
| `finger_graded.stl` (variant) | ✓ | ✓ | ~940 |
| `calibration_coupon.stl` | ✓ | ✓ | — |
| `fingertip_pad_mold.stl` | ✓ | ✓ | — |
| `whiffletree.stl` | ✓ | ✓ | — |
| `palm_chassis.stl` | ✓ | ✓ | — |
| `wrist_adapter.stl` | ✓ | ✓ | — |
| `socket_cuff.stl` | ✓ | ✓ | — |

Preview images are in `png/`.

## Phase 1 print order (see ../ROADMAP.md)
Print in this sequence; don't print all fingers until the coupon + one finger pass.

### 1. `calibration_coupon.stl` — FIRST
TPU 95A, your finger settings. Measure the wall at 5 points; adjust flow %
until measured = 1.0 mm ±0.05. (Test T1 in `../docs/test-protocol.md`.)

### 2. One finger variant, then bench-test before committing
Print `finger_index.stl` (baseline), `finger_floating.stl`, and
`finger_graded.stl`. Run tests T2–T4; pick the winner.

### 3. Remaining fingers in the chosen variant
`finger_middle/ring/pinky.stl`. Thumb = reprint `finger_index.stl`.

## Slicer settings by part
| Part(s) | Material | Layer | Walls | Infill | Orientation | Supports |
|---|---|---|---|---|---|---|
| fingers, coupon | TPU 95A | 0.20 mm | 2 | 0–10 % | **lying on side face (as exported)** | none |
| pad mold | PLA | 0.12 mm | 3 | 15 % | cavity up | none |
| whiffletree | PETG/PLA+ | 0.20 mm | 4 | 30 % gyroid | flat | none |
| palm_chassis | PETG/PLA+ | 0.20 mm | 4 | 30 % gyroid | palm-down | on servo pocket overhang |
| wrist_adapter | PETG | 0.20 mm | 4 | 30 % | dovetail up | none |
| socket_cuff | TPU 95A | 0.24 mm | 3 | 0 % | axis vertical | none |

TPU specifics (temps, retraction, drying) are in
`../finray-cad-print-parameters.md` §2. **Dry the TPU first** — it matters more
than any slicer setting.

## Estimated print times / material (0.4 mm nozzle, ~30 mm/s TPU)
| Part | Time | Material |
|---|---|---|
| calibration coupon | ~15 min | ~2 g |
| one finger | ~1.5 h | ~12 g |
| full finger set (5) | ~7.5 h | ~60 g |
| whiffletree plate | ~1 h | ~15 g |
| palm chassis | ~5 h | ~90 g |
| wrist adapter | ~1 h | ~25 g |
| socket cuff | ~4 h | ~70 g |

(Times are rough; a fast CoreXY roughly halves them.)
