# Flexible Prosthetic Hand — Design Brainstorm

## Problem
Commercial prosthetic hands are too stiff. The stiffness comes from their design
philosophy, not just their materials: rigid links, one motor per joint,
gearboxes, and position control. A human hand is the opposite — compliant by
default, recruiting stiffness only when needed.

**Core design principle: don't build a stiff hand and soften it.
Build a soft hand and add stiffness on demand.**

## Design directions

### 1. Compliant mechanisms & soft structures
- Replace pin joints with printed flexures (living hinges): the finger becomes
  one monolithic part with no joints to jam or wear.
- **Fin Ray effect fingers**: a triangular flexible structure that passively
  wraps around any object it touches — the geometry does the grasping, with no
  sensors or control loop. Printable in TPU.

### 2. Underactuation with adaptive synergies
- One motor drives multiple tendons through a differential (whiffle-tree or
  floating pulleys).
- When one finger contacts the object, tension automatically flows to the
  remaining fingers until the whole hand conforms.
- Reference: Pisa/IIT SoftHand — a single actuator grasps eggs, hammers, and
  sheets of paper because the object shapes the grasp.

### 3. Variable stiffness — soft by default, rigid on demand
- **Layer jamming / granular jamming**: a finger filled with granular media or
  stacked flexible sheets is floppy until a small vacuum is applied, then it
  locks rigid. Stiffness becomes a switchable state.
- **Antagonistic tendons**: co-contract opposing tendons to stiffen a joint,
  exactly as human muscles do.
- **Phase-change elements**: shape-memory alloys or low-melting-point polymers
  in the joint that soften/harden electrically.

### 4. Gradient materials (bio-inspired)
- Human fingertip: bone → tendon → fat pad → ridged skin.
- Reproduce with multi-material fabrication: rigid PLA core, TPU flexure
  joints, cast silicone fingertip pads.
- The soft pad is functional, not cosmetic — it provides grip friction and
  enables delicate handling.

### 5. Compliant control
- **Impedance/force control** ("push with 2 N") instead of position control
  ("move to 40°").
- **Series elastic actuation**: a spring between motor and tendon absorbs
  shocks and makes force sensing cheap.
- **Continuous EMG regression** instead of discrete grip modes, so the user
  modulates *how hard*, not just open/close.

## First prototype (low cost, ~1 weekend)
1. 3D-print fin-ray fingers in TPU (95A shore hardness).
2. Route fishing-line tendons through the palm.
3. Single hobby servo + whiffle-tree differential for adaptive grasp.
4. Cast silicone (e.g. Ecoflex) fingertip pads for friction.
5. Test grasps: egg, water bottle, pen, sheet of paper.

**Iteration 2 differentiator**: add granular-jamming stiffening — a hand that
is gentle by default and locks rigid on demand (e.g. carrying a heavy bag).

## Key references to study
- Fin Ray Effect grippers (Festo)
- Pisa/IIT SoftHand (adaptive synergies, underactuation)
- Yale OpenHand project (open-source underactuated hands)
- Jamming-based variable stiffness (iRobot/Chicago universal jamming gripper)
- Series elastic actuators (Pratt & Williamson)
