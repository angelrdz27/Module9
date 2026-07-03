# Assembly Guide

Step-by-step build of the flexible prosthetic hand, in the order the
`ROADMAP.md` phases expect. Times assume parts are printed and the BOM is on
hand.

## Tools & consumables
- 3D printer (direct-drive preferred for TPU), filament dryer
- Soldering iron, heat-shrink, 100 Ω / 330 Ω / 1 kΩ / 10 kΩ resistors
- M3 hardware: socket screws (6–16 mm), grub screws, nyloc nuts, heat-set inserts
- Soldering iron tip for heat-set inserts
- Fishing-line crimps + crimp pliers, or practice the Palomar knot
- Multimeter; kitchen scale (fingertip-force check)
- Silicone: Ecoflex 00-30, mixing cups, gram scale

## Step 1 — Print everything
| Part | File | Material | Qty |
|---|---|---|---|
| Fingers | `cad/finray_finger.scad` (80/88/82/65 mm) | TPU 95A | 4 |
| Thumb | `cad/finray_finger.scad` (80 mm) | TPU 95A | 1 |
| Palm chassis | `cad/palm_chassis.scad` | PETG/PLA+ | 1 |
| Whiffle-tree | `cad/whiffletree.scad` | PETG/PLA+ | 1 plate |
| Wrist adapter | `cad/wrist_socket.scad` (`part="adapter"`) | PETG | 1 |
| Socket cuff | `cad/wrist_socket.scad` (`part="cuff"`) | TPU 95A | 1 |
| Pad mold | `cad/finray_finger.scad` (`part="mold"`) | PLA | 1 |

Dry the TPU first. Print fingers **lying on their side face** (as modeled).

## Step 2 — Heat-set inserts & fastener test
Install M3 heat-set inserts in the palm's servo-mount and wrist bolt bosses.
Verify a finger base slides into its palm pocket and the two cross-holes line
up with the base holes; ream with a 3.2 mm bit if tight (TPU shrinks holes).

## Step 3 — Silicone fingertip pads
1. Mix Ecoflex 00-30 1:1 by weight, degas if you have a chamber (optional).
2. Pour ~3.5 mm into the pad mold; press the finger's distal third in so the
   dovetail keys fill. Cure 4 h at room temp (or 10 min at 60 °C).
3. Demold; the pad is mechanically keyed — Sil-Poxy only if it lifts.

## Step 4 — Tendons
1. Cut UHMWPE braid ~1.5× finger+palm length per finger.
2. Thread PTFE liner through each finger's back-wall channel and the palm
   routing holes.
3. Anchor at the fingertip: pass braid through the tip cross-hole, tie a
   figure-8 stopper (or crimp around a smooth post).
4. Route the free end through the palm to its whiffle-tree rocker slot; leave
   slack — tensioning comes after the servo is in.

## Step 5 — Whiffle-tree + servo
1. Bolt the two secondary rockers to the primary rocker's ends via M3 +
   nyloc, pivoting **freely** (do not overtighten — they must rotate).
2. Attach the primary rocker's drive tab to the servo horn.
3. Drop the STS3215 into the palm pocket; secure with M3 into inserts.
4. Set servo ID = 1 and 1 Mbps with a Feetech/Waveshare config tool before
   final assembly (or over the same bus from the firmware).

## Step 6 — Tension the tendons
1. Power the servo, send `o` (open) so the horn is at `POS_OPEN`.
2. Pull each tendon just taut (no finger curl yet), clamp under the rocker
   grub screw.
3. Send `c` / `o` a few times; adjust each grub screw until all fingers
   start and finish together. **Re-check after a day** — UHMWPE creeps.

## Step 7 — Electronics
Wire per `wiring-schematic.md`. Build the two MOSFET switches with flyback
diodes. Do a **smoke test at low voltage** first: 5 V bench supply, confirm
the ESP32 enumerates and `?` returns a status line before connecting the
Li-ion pack.

## Step 8 — Jamming pad (Phase 4)
1. Fill a latex balloon ~70 % with dry ground coffee; knot around a barbed
   tube stub; seat it in the palm recess.
2. Route the tube through the palm pass-through to the 3-way solenoid and
   pump.
3. Test: send `j` — the pad should firm up in ~1.5 s; `v` — it goes floppy.

## Step 9 — Wrist & socket
1. Bolt the wrist adapter to the palm's proximal bolt circle (wire pass-
   through aligned to the servo cable exit).
2. Slide the socket cuff's dovetail onto the adapter; add straps.
3. Optional compliant wrist: sandwich a 6 mm TPU disc between adapter and
   palm (`wrist_socket.scad` note).

## Step 10 — Commissioning
Follow `ROADMAP.md` Phase 2 exit criteria (grasp set), then Phase 3 for EMG:
send `e`, do the relax/squeeze calibration, and test open/close. Log telemetry
with `software/emg_collect.py` and validate against `test-protocol.md`.
