# Fin-Ray Finger — CAD & 3D-Print Parameters

Companion to `prosthetic-hand-design.md`. Everything here targets a standard
FDM printer with a 0.4 mm nozzle and TPU 95A filament.

## 1. Fin-ray geometry (the parameters that matter)

A fin-ray finger is two converging walls joined by internal ribs. When the
front (contact) wall is pushed, the rib truss makes the tip curl *toward* the
object instead of away — that's the passive wrapping behavior.

```
        tip
        /|
       / |
      /  |   <- back wall (thicker, stiffer)
ribs /---|
    /----|
   /-----|
  /______|
  base (mounts to palm / tendon anchor)
```

### Recommended starting dimensions (adult index finger scale)

| Parameter | Value | Effect when you change it |
|---|---|---|
| Finger length (base→tip) | 80 mm | Match to hand anthropometry (index ≈ 70–90 mm) |
| Base depth (wall-to-wall) | 16 mm | Deeper base = higher grip force, less conformity |
| Tip depth | 4–6 mm | Sharper tip wraps small objects better |
| Finger width | 15–18 mm | Wider = more contact area, stiffer in torsion |
| Front (contact) wall thickness | 1.0 mm | Dominant compliance knob. 0.8 = very soft, 1.6 = firm |
| Back wall thickness | 1.6–2.0 mm | Keep ≥1.5× front wall so bending concentrates at the contact side |
| Rib thickness | 0.8 mm | Thicker ribs resist wrap; keep ≤ front wall |
| Rib count | 6–8 | More ribs = smoother curvature, slightly stiffer |
| Rib spacing | 8–10 mm | Even spacing; last rib ≥5 mm from tip |
| Rib angle | 90° to back wall, or tilted 10–20° toward tip | Tilting toward the tip increases wrap depth |
| Rib–wall junction fillet | 0.5–1 mm | Prevents stress cracking at layer lines |

### Two high-leverage variants
- **Floating ribs**: leave a 0.3–0.5 mm gap between rib ends and the front
  wall. The finger is very soft on first contact, then stiffens as ribs
  engage — a free, passive version of "soft by default, stiff on demand."
- **Graded walls**: taper the front wall from 1.4 mm at the base to 0.8 mm at
  the tip. Mimics the proximal-to-distal stiffness gradient of a human finger.

### Tendon integration (for the actuated version)
- Run a 2.5 mm diameter tendon channel along the *back* wall, exiting at the
  base. Pulling the tendon pre-curls the finger; contact then triggers the
  fin-ray wrap. Line the channel with PTFE tube (2 mm ID) to cut friction.
- Tendon anchor: a 4 mm cross-hole near the tip; knot a figure-8 stopper knot
  behind it.

### CAD approach
Model it parametrically so every value above is a named variable:
- **Fusion 360 / Onshape**: single sketch of the side profile (two walls +
  ribs as a sketch pattern), extrude to finger width. Drive everything from
  a parameters table.
- **OpenSCAD**: ideal here — the whole finger is ~40 lines with `for` loops
  for ribs, and you can regenerate a full 4-finger set with one variable
  change per finger length (index/middle/ring/pinky ≈ 80/88/82/65 mm).

## 2. TPU print settings (95A, e.g. Overture/Polymaker/eSUN TPU)

**Dry the filament first — 6–8 h at 55 °C.** Wet TPU is the #1 cause of
stringing, weak layer bonds, and popping. This matters more than any slicer
setting below.

| Setting | Value | Notes |
|---|---|---|
| Nozzle temp | 225–235 °C | Higher end for better layer adhesion (flexures live or die on this) |
| Bed temp | 40–50 °C | TPU sticks aggressively to PEI — use glue stick as a *release* layer |
| Print speed | 25–35 mm/s (Bowden: 15–20) | Direct-drive strongly preferred; modern CoreXY (Bambu/Voron) can run 50+ |
| Layer height | 0.2 mm | 0.15 mm for smoother flexure surfaces |
| Perimeters | 2 | Walls of the fin-ray ARE the part — set wall thickness in CAD as a multiple of (2 × 0.42 mm line width) |
| Infill | 0–10 % | The rib truss replaces infill; interior voids should stay empty |
| Retraction | 0.5–1 mm @ 25 mm/s (direct drive) | Disable coasting/wipe; enable "avoid crossing perimeters" to cut stringing |
| Fan | 30–50 % after layer 2 | Full fan weakens layer bonds |
| Flow | 105–110 % | TPU under-extrudes at speed; calibrate with a wall-thickness test |

### Print orientation — critical
Print the finger **lying on its side face** (side profile flat on the bed).
The walls and ribs are then continuous extrusion paths in the XY plane, and
bending stress runs *along* layer lines, not across them. Printed upright,
the finger will delaminate at a rib junction within a few hundred cycles.
No supports needed in this orientation.

### Quick calibration part
Before printing full fingers, print one 20 mm-wide test coupon: a 1.0 mm wall,
50 mm tall, lying flat. Flex it 50 times and check wall thickness with
calipers. Adjust flow until measured = designed ±0.05 mm.

## 3. Rigid parts (palm, whiffle-tree, servo mount)

| Setting | Value |
|---|---|
| Material | PETG (tougher) or PLA+ (easier) |
| Perimeters / infill | 4 walls, 30 % gyroid |
| Layer height | 0.2 mm |
| Pivot pins | M3 bolts or 1.75 mm filament rivets (melt heads with a lighter) |
| Hole compensation | Model holes +0.2 mm; TPU holes +0.4 mm (elastic recovery shrinks them) |
| Clearances | 0.3 mm for press-fit into TPU, 0.5 mm for free-moving pivots |

Whiffle-tree: a 40 mm rocker bar per finger pair, pivoted at its midpoint,
cascading to a central bar on the servo horn. Two levels of rockers balance
four fingers off one servo automatically.

## 4. Fingertip pad molds
- Print 2-piece molds in PLA at 0.12 mm layers, smooth with a heat gun pass.
- Pour Ecoflex 00-30 or Dragon Skin 10; a 3–4 mm pad thickness on the distal
  third of the front wall is enough.
- Key the pad into the TPU with 2–3 dovetail slots modeled into the front
  wall — silicone doesn't glue well to TPU (use Sil-Poxy if you need adhesive).

## 5. First test protocol
1. Grasp set: egg, 500 ml bottle, pen, sheet of paper, apple.
2. Measure fingertip force with a kitchen scale (target 5–15 N per finger).
3. Cycle test: 500 open/close cycles, then inspect rib junctions for cracks.
4. Log which geometry variant (wall thickness / rib angle) you printed —
   change one parameter per iteration.
