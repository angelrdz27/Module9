# CAD — parametric OpenSCAD models

All parts are driven by the parameter blocks at the top of each file.
Open in OpenSCAD (or run `openscad -o out.stl file.scad` headless).

## Files
- `finray_finger.scad` — the fin-ray finger. Also contains the fingertip
  silicone-pad drape mold (`part = "mold"`).
- `whiffletree.scad` — 3-rocker tendon differential print plate.

## Generating the finger set
Render four STLs by overriding `finger_length` (all other params shared):

```bash
for f in index:80 middle:88 ring:82 pinky:65; do
  name=${f%%:*}; len=${f##*:}
  openscad -o finger_${name}.stl -D finger_length=${len} finray_finger.scad
done
```

Thumb: reuse the index finger (80 mm) mounted on the palm at ~45° opposition.

## Variants to print in Phase 1 (see ../ROADMAP.md)
| Variant | Override |
|---|---|
| Baseline | (defaults) |
| Floating ribs | `-D floating_gap=0.4` |
| Graded wall | `-D front_wall_t=1.4 -D front_wall_t_tip=0.8` |

## Material / print quick reference
| Part | Material | Notes |
|---|---|---|
| Fingers | TPU 95A | Print lying on side face (as modeled); dry filament first |
| Rockers | PETG/PLA+ | Flat, 4 walls, 30% gyroid |
| Pad mold | PLA | 0.12 mm layers, smooth cavity with brief heat-gun pass |

Full settings: `../finray-cad-print-parameters.md`.
