# Test & Validation Protocol

Objective, repeatable tests mapped to the `ROADMAP.md` phase exit criteria.
Record every run in a build log; change **one** parameter per iteration.

## T1 — Finger flow calibration (Phase 1)
- **Setup:** print the 20 mm wall coupon (`finray-cad-print-parameters.md` §2).
- **Measure:** wall thickness with calipers at 5 points.
- **Pass:** measured = designed ±0.05 mm. If not, adjust flow % and reprint.

## T2 — Passive wrap (Phase 1)
- **Setup:** clamp finger base; no tendon.
- **Action:** press a 20 mm rod against the mid-finger front wall with ~5 N.
- **Pass:** tip deflects **toward** the rod (wrapping), not away. If it bows
  outward, front wall is too thick relative to back wall — reduce `front_wall_t`.

## T3 — Fingertip force (Phase 1)
- **Setup:** finger + tendon; tip resting on a kitchen scale.
- **Action:** pull tendon to full servo travel (or by hand to the same length).
- **Measure:** peak force (N = grams × 0.0098).
- **Pass:** 5–15 N. Below 5 N → thicker back wall or shorter finger; above 15 N
  with poor conformity → thinner front wall / floating ribs.

## T4 — Fatigue (Phase 1)
- **Action:** 500 open/close cycles (script the servo or use a cam).
- **Inspect:** rib-to-wall junctions for cracks/whitening; tendon channel wear.
- **Pass:** no visible cracking; fingertip force within 15 % of pre-test.
  Failure here almost always means wrong print orientation — reprint on side.

## T5 — Differential balance (Phase 2)
- **Setup:** full hand, tendons tensioned.
- **Action:** hold a flat card against two fingers, close the hand.
- **Pass:** free fingers keep closing after the blocked ones stall (whiffle-
  tree routing works); all fingers reach the object surface within ~0.3 s of
  each other on an irregular object.

## T6 — Grasp set (Phase 2 exit)
Objects: egg, 500 ml bottle, pen, sheet of paper, apple.
- **Action:** close on each; lift and hold 30 s.
- **Measure:** servo `present_load` at hold (telemetry).
- **Pass:** ≥4/5 held for 30 s at ≤60 % load. Egg must not crack (tune
  `GRIP_LOAD` down); paper must be pinchable (thumb opposition + pad friction).

## T7 — EMG open/close reliability (Phase 3 exit)
- **Setup:** MyoWare on forearm flexor; run boot calibration.
- **Action:** 20 close attempts + 20 open attempts, natural muscle effort.
- **Measure:** success rate; false triggers per minute at rest.
- **Pass:** >90 % intended actions succeed; <1 false trigger/min at rest over
  a 10-min session with no recalibration. Tune `CLOSE_FRACTION` from
  `emg_train.py` MAV bands; increase `DEBOUNCE_MS` if jittery.

## T8 — Classifier quality (Phase 3, optional ML)
- **Action:** collect 30 s each of rest/close/open; `python emg_train.py`.
- **Pass:** per-class F1 ≥ 0.85 on the held-out split; if `open` is weak,
  collect more co-contraction examples or add a channel.

## T9 — Variable stiffness (Phase 4 exit)
- **Action A (soft):** grasp an egg unjammed → must not crack.
- **Action B (rigid):** grasp a 2 kg bag handle; auto-jam triggers on load →
  hand holds without the fingers splaying.
- **Measure:** pad rigidity by pressing a finger — noticeably firmer jammed.
- **Pass:** both A and B succeed with **no manual mode switch** (firmware
  auto-stiffens on sustained load, vents on release).

## T10 — Fail-soft (safety)
- **Action:** cut servo power mid-grasp.
- **Pass:** hand relaxes to passive compliance (does not clamp or lock). This
  is the intended failure mode of the soft design.

## T11 — Endurance (pre-wearable, Phase 5)
- **Action:** 5000 grasp cycles on the bottle; re-tension check daily.
- **Pass:** grip force within 20 % of start; no tendon failure; document
  UHMWPE creep take-up needed (informs the re-tensioning interval).

## Build-log template
```
date | phase | change made | test | result | pass/fail | notes
```
