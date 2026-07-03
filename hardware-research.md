# DIY Flexible Prosthetic Hand — 2025/2026 Component Research & BOM

*Scope: TPU fin-ray fingers, fishing-line tendons, single-servo whiffletree
differential, silicone fingertip pads, with later granular-jamming stiffness
and EMG control. All prices are **approximate** (USD, mid-2026) and shift with
retailer/quantity.*

---

## 1. Actuators

The architecture uses **one main actuator** pulling a whiffletree, so you want
high stall torque, position feedback (ideally), and enough travel to close all
fingers. Serial-bus servos win here because they give torque + encoder
feedback + daisy-chaining on 3 wires, which matters once you add EMG and want
current-based grip feedback.

| Model | Type | Stall torque | Size / weight | Interface | Price (approx) |
|---|---|---|---|---|---|
| **Feetech STS3215** (C018, 12V) | Serial bus, magnetic encoder | ~30 kg·cm @12V (19.5 kg·cm @7.4V C001) | 40×20×40 mm, ~60 g | TTL serial bus (daisy-chain), 12-bit abs encoder | **~$14–27 each** |
| **Dynamixel XC330-M288-T** | Serial bus, metal gear | ~0.6 N·m (~6 kg·cm) | ~34 mm tall, ~23 g | TTL, 4096-step encoder, current/temp feedback | ~$45–55 |
| **Dynamixel XL330-M288-T** | Serial bus, plastic gear | 0.52 N·m (~5.3 kg·cm) @5V | 20×34×26 mm, **18 g** | TTL serial bus, full feedback | ~$27 |
| **DS3218 / DS3218MG** (ANNIMOS) | Standard PWM digital, metal gear | 19–21.5 kg·cm | 40×20×40.5 mm, ~60 g | PWM (no feedback) | ~$15–20 |
| **Actuonix PQ12-63-12-S** | Micro linear actuator | 30 N push @ 8 mm/s, 20 mm stroke | ~34 mm body | PWM/analog + position feedback | ~$70–90 |
| **Actuonix L12** | Linear actuator (longer stroke) | up to ~40–80 N depending on gearing | 50–100 mm stroke | PWM/RC/analog | ~$70–110 |

**Picks:**
- **Pick the Feetech STS3215 if** you want the best torque-per-dollar and
  position/current feedback for a whiffletree main pull — it's the de-facto
  open-source robotics servo (SO-ARM100/101) and is cheap enough to buy
  spares. **Recommended default.**
- **Pick the Dynamixel XL330/XC330 if** weight and clean feedback
  (current-based grip sensing) matter more than cost, e.g. a wearable
  prosthesis where 18 g and precise control beat raw torque.
- **Pick the DS3218 if** you just want the cheapest strong "pull the tendon
  bundle" actuator for a first mechanical prototype and will do position
  control open-loop off a microcontroller PWM pin.
- **Linear actuator (Actuonix PQ12/L12) if** you prefer a direct linear tendon
  pull with built-in position feedback and no horn geometry — cleaner force
  curve, but pricier and slower.

---

## 2. Tendon Materials

Both Spectra and Dyneema are UHMWPE (same fiber family); "PE braid" fishing
line is the accessible form. Key properties: **near-zero stretch,
steel-comparable strength-to-weight, excellent abrasion resistance**, but it
*creeps* under sustained load and can saw through soft plastic anchors, so
route through PTFE and use metal/round anchor points.

| Material | Recommended rating | Behavior | Use for |
|---|---|---|---|
| **Braided UHMWPE (Spectra/Dyneema/PE braid)** — e.g. PowerPro, Berkley | **50–100 lb test** for a full-hand main tendon; 30–50 lb for individual fingers | Very low stretch, high fatigue life, low friction; slowly creeps, needs good knots (Palomar) or crimps | **Primary tendon material — recommended** |
| **Nylon monofilament** | 30–80 lb | Stretches noticeably (elastic return can help passive extension), UV/fatigue weaker, cheaper | Return/antagonist springs, non-critical routing, prototyping |
| **Bowden cable (steel inner + housing)** | n/a (steel) | No stretch, high push/pull, heavier, more friction | Long routing runs through the forearm where you need push as well as pull |
| **PTFE tube (Bowden liner, 2 mm OD / ~1 mm ID, "Capricorn"-style)** | — | Ultra-low-friction routing sheath; keeps braid from sawing plastic | Route tendons around every direction change |

**Picks:**
- **Pick 65–80 lb PE braid + PTFE liner if** you want the standard, reliable
  tendon setup (a 100 lb PowerPro line is exactly what research tendon-driven
  hands like the Seed Robotics RH8D use). **Recommended.**
- **Pick nylon mono if** you specifically want built-in stretch for passive
  finger extension, or as a cheap disposable prototype line.
- **Add short PTFE tube segments** at all fin-ray entry/exit points and pulley
  bends — this is the single biggest longevity upgrade for fishing-line
  tendons (~$8–12 for 1 m of Capricorn tube).

*Cost: a spool of quality PE braid is ~$15–25 and will last many builds.*

---

## 3. EMG Sensing (later iteration)

| Board | Channels | Interface | Ease | Price (approx) |
|---|---|---|---|---|
| **MyoWare 2.0 Muscle Sensor** (SparkFun DEV-21265) | 1 (envelope + raw out) | Analog out, snap-on shields (LED/power/cable/BLE) | Easiest — plug-and-play, wearable, shield ecosystem | ~$38 (sensor); Basic/Wireless kits ~$70–110 |
| **BioAmp EXG Pill** (Upside Down Labs) | 1 (EMG/ECG/EOG/EEG) | Analog out to any ADC | Easy, needs gel electrodes + cable; publication-grade signal | ~$25–35 each (2-pack ~$69) |
| **uMyo** (Ultimate Robotics / uDevices) | 1 wireless + IMU | BLE / nRF24 / USB, 9 g wearable PCB | Easy wireless, great for untethered; add nRF24 to read on Arduino | ~$30–40 |
| **Gravity / OYMotion (DFRobot SEN0240 etc.)** | 1 | Analog | Easy, robust analog front-end | ~$35–45 |

**Picks:**
- **Pick MyoWare 2.0 if** you want the lowest-friction start: it outputs a
  clean rectified envelope you can threshold on any ADC pin, and the shield
  ecosystem (power, BLE, cable) is genuinely beginner-friendly.
  **Recommended first EMG.**
- **Pick BioAmp EXG Pill if** you want the best signal quality per dollar and
  plan to do real ML classification — you get the raw waveform for feature
  extraction, and it's cheap enough to run 2–3 channels for multi-gesture
  control.
- **Pick uMyo if** you want wireless, wearable EMG (untethered forearm band)
  with an onboard IMU for sensor-fusion gestures.

*For TinyML multi-gesture control, budget 2–3 channels (e.g. 3× BioAmp EXG
Pill ≈ $75–90).*

---

## 4. Microcontrollers

| Board | CPU / ML | Wireless | Notes | Price (approx) |
|---|---|---|---|---|
| **ESP32-S3** (DevKit / XIAO ESP32-S3) | Dual-core 240 MHz, vector/SIMD for ML inference | Wi-Fi + BLE | Best all-rounder: enough ADC channels, cheap, huge community, runs TFLite-Micro; XIAO form factor fits in a forearm | ~$8–15 |
| **Teensy 4.0 / 4.1** | Cortex-M7 @600 MHz (overclock ~1 GHz) | none (4.1 has Ethernet) | Fastest MCU here; excellent ADC + tons of PWM/serial for many servos; ideal if you outgrow ESP32 compute | ~$20–30 |
| **Arduino Nano 33 BLE Sense (Rev2)** | Cortex-M4F @64 MHz + IMU | BLE | The canonical TinyML board — best-documented TensorFlow Lite Micro workflow, onboard IMU | ~$45–55 |
| **RP2040 / RP2350 (Pico 2)** | Dual M0+/M33; RP2350 adds more compute | RP2350 W has Wi-Fi/BLE | Cheap, PIO is great for driving many servos/serial buses precisely | ~$4–8 |

**Picks:**
- **Pick ESP32-S3 if** you want one board to do servo control + EMG ADC +
  future on-device ML + wireless telemetry. Best value and future-proofing.
  **Recommended default.**
- **Pick Teensy 4.x if** your EMG classifier gets heavy (higher sample rates,
  more channels, real-time DSP) — raw horsepower and superb peripheral count.
- **Pick Nano 33 BLE Sense if** you're following TinyML tutorials directly —
  the gesture/EMG classification toolchain is most turnkey here.
- **Pick RP2350/Pico 2 if** you want a rock-bottom-cost controller and will
  use PIO to bit-bang the Feetech serial bus and PWM cleanly.

---

## 5. Granular Jamming Supplies (iteration 2)

The classic "coffee-balloon" universal jamming gripper (Brown/Amend/Jaeger,
PNAS 2010) is the reference; here you'd apply it as **variable-stiffness
pads/palm**.

| Item | Options | Notes | Price (approx) |
|---|---|---|---|
| **Vacuum pump** | 12V mini diaphragm (SparkFun ROB-10398 style); **SC3101PM** (Skoocom, very small 3–5V); generic 6–12V diaphragm | Diaphragm pumps are one-way (can't reverse to inflate). ~-40 to -70 kPa is plenty for jamming | ~$15–30 |
| **Solenoid valve** | 2-way/3-way 6–12V normally-closed (e.g. small barbed pneumatic solenoid) | Lets you hold vacuum without running pump; 3-way vents to atmosphere to un-jam fast | ~$6–12 |
| **Membrane** | Latex balloons / party balloons; thin latex sheet; nitrile finger cots for small pads | Balloons are the cheap standard; latex sheet lasts longer | ~$5–10 |
| **Granular media** | **Ground coffee** (low density, best jamming-hardness/weight — the classic pick); **glass beads** (harder grip, heavier); ground rice/sand as alternatives; EPS/soft beads give *higher* force but less rigidity | Coffee = best all-round for lightweight pads; glass beads if you want maximum rigidity | ~$5 |
| Check valve + barbed fittings + silicone tubing | 4 mm / 6 mm ID tubing | Plumbing | ~$8 |

**Picks:**
- **Pick a 12V mini diaphragm pump + 3-way solenoid + coffee-filled latex pad
  if** you want the proven, cheapest variable-stiffness route. **Recommended.**
- **Pick glass beads if** you need maximum locked rigidity (heavier);
  **coffee grounds if** weight matters (fingertip/palm pads).
- Budget ~$40–55 total for a working single-chamber jamming subsystem.

---

## 6. Silicone for Fingertip Pads

| Product | Shore hardness | Feel / use | Buy small qty | Price (approx) |
|---|---|---|---|---|
| **Ecoflex 00-30** (Smooth-On) | Shore 00-30 (very soft), ~900% elongation | Skin-like, grippy, deformable fingertip pads; skin-safe | Trial unit (~1 lb total) | **~$40–52 trial** |
| **Dragon Skin 10** (Smooth-On) | Shore 10A (firmer, tougher) | More durable, higher tear strength; good for structural fin-ray reinforcement or grippier tougher pads | Trial unit | ~$40–55 trial |
| **Ecoflex 00-50** | 00-50 (mid) | Compromise: softer than Dragon Skin, tougher than 00-30 | Trial unit | ~$45 |

**Picks:**
- **Pick Ecoflex 00-30 if** you want maximally compliant, high-friction,
  skin-like fingertip pads for adaptive grasp. **Recommended for pads.**
- **Pick Dragon Skin 10 if** you want durability/tear resistance (pads that
  survive abrasion, or flexible joint webbing).
- Buy **trial units** direct from Smooth-On or resellers (Douglas & Sturgess,
  Reynolds); one trial kit casts many fingertip pads. Add a
  **Slacker/Thi-Vex** additive later if you want softer or thixotropic
  (non-drip) mixes.

---

## 7. TPU Filaments (fin-ray fingers)

Fin-ray fingers need flexibility but enough backbone to transmit tendon
force — **95A is the sweet spot** for fin-ray; 85A for very compliant tips;
Varioshore lets you grade stiffness within one print.

| Filament | Shore | Printability | Price/kg (approx) |
|---|---|---|---|
| **NinjaFlex 85A** (NinjaTek) | 85A, ~660% elong | Softest common FDM TPU; **direct-drive only**, 20–25 mm/s, no retraction, must be dry | ~$45 |
| **NinjaTek Cheetah 95A** | 95A | Engineered to print on **Bowden** extruders too; forgiving, fast | ~$40–50 |
| **Polymaker PolyFlex TPU95** | 95A | Easy, reliable, good surface | ~$30 |
| **eSUN TPU 95A** | 95A | Best value, widest colors incl. translucent; QC "good not great" | **~$20** |
| **Overture TPU 95A** | 95A | Cheap, reliable budget option | ~$20–25 |
| **colorFabb varioShore TPU** | **~92A (60–70% flow) down to ~55A fully foamed** | Foaming — vary stiffness/density by temp & flow (200–250 °C expands ~1.6×); great for graded fin-ray | ~$52 |

**Picks:**
- **Pick eSUN or Overture TPU 95A if** you want cheap, reliable fin-ray
  fingers and have a direct-drive printer. **Recommended default for
  structure.**
- **Pick NinjaTek Cheetah 95A if** you're on a Bowden printer (Ender-style) —
  it's specifically formulated not to jam.
- **Pick NinjaFlex 85A if** you want very compliant fingers/webbing and have
  direct drive + patience.
- **Pick varioShore TPU if** you want to grade stiffness within a single
  finger (stiff base → soft tip) — ideal for advanced fin-ray tuning.

---

## 8. Reference Open-Source Projects

- **Yale OpenHand Project** (GrabLab) — the canonical open-source
  underactuated hand line (Model T, T42, M2, etc.): 3D-printed,
  tendon-driven, differential/underactuated fingers. **Study first — closest
  to this architecture.** eng.yale.edu/grablab/openhand
- **Whiffletree differential papers** — Kontoudis & Kyriakopoulos /
  Leddy & Dollar; the Frontiers/PMC review *"On Differential Mechanisms for
  Underactuated, Lightweight, Adaptive Prosthetic Hands"* and the
  *selectively-lockable whiffletree* work (144 postures from one motor).
  **Essential reading for the single-servo differential.**
- **exiii HACKberry** — fully open 3D-printable EMG bionic hand
  (Arduino-based, ~$200 BOM). exiii-hackberry.com — good for EMG integration
  + socket/wrist design.
- **Open Bionics — Brunel Hand 2.0** — open design files on GitHub
  (Open-Bionics/Brunel) and Thingiverse; tendon-driven, research-grade. Good
  mechanical reference.
- **Tactile SoftHand-A** (arXiv 2406.12731, 2024) — 3D-printed,
  highly-underactuated anthropomorphic hand with **antagonistic tendons** +
  tactile sensing. Recent and directly relevant to soft tendon hands.
- **e-NABLE / LimbForge** — community body-powered and simple designs
  (Phoenix Hand, Unlimbited Arm); best for socket, cosmesis, and fit patterns
  rather than actuation.
- **HANDSON Hand (CYBATHLON 2024, PMC11939478)** — recent competition-grade
  design notes worth skimming for real-world robustness lessons.

---

## Suggested ~$150 Starter BOM (mechanical proof-of-concept)

*Goal: TPU fin-ray fingers, fishing-line tendons, single-servo whiffletree,
silicone pads, basic microcontroller control.*

| Item | Choice | Qty | Price (approx) |
|---|---|---|---|
| Main actuator | Feetech STS3215 (serial bus, feedback) | 1 | $20 |
| Microcontroller | ESP32-S3 (XIAO or DevKit) | 1 | $12 |
| Servo/bus driver + wiring | TTL bus adapter + buck converter + connectors | 1 | $12 |
| TPU filament | eSUN / Overture TPU 95A, 1 kg | 1 | $22 |
| Tendon line | PE braid 65–80 lb spool | 1 | $18 |
| PTFE routing tube | Capricorn 2×1 mm, 1 m | 1 | $10 |
| Fingertip silicone | Ecoflex 00-30 trial unit | 1 | $45 |
| Fasteners / springs / anchors / crimps | assorted | — | $12 |
| **Total** | | | **≈ $151** |

*(Swap to a DS3218 at ~$16 to shave cost, or add a second STS3215 for a
driven thumb.)*

---

## Suggested ~$400 "Iteration 2" BOM (adds granular jamming + EMG)

*Builds on Starter BOM; adds variable stiffness and myoelectric control.*

| Item | Choice | Qty | Price (approx) |
|---|---|---|---|
| **(Carryover: starter build)** | mechanical hand as above | 1 | ~$151 |
| Upgrade main actuator | Dynamixel XC330-M288-T (current feedback for grip force) | 1 | $50 |
| EMG sensing | BioAmp EXG Pill | 2 | $60 |
| EMG sensing (easy channel) | MyoWare 2.0 sensor + cable shield | 1 | $50 |
| Gel/electrodes + electrode cables | consumables | — | $15 |
| Vacuum pump | 12V mini diaphragm | 1 | $22 |
| Solenoid valve (3-way) + check valve | pneumatics | 1 set | $15 |
| Membrane + granular media | latex + ground coffee (+ glass beads sample) | — | $12 |
| Pneumatic tubing + barbed fittings + MOSFET driver board | plumbing + switching | — | $20 |
| varioShore TPU (graded-stiffness fingers) | colorFabb, 700 g | 1 | $40 |
| Battery + power management (Li-ion pack + BMS/buck) | — | 1 | $25 |
| **Total** | | | **≈ $410** |

*(Trim toward $360 by using 3× BioAmp EXG Pill instead of MyoWare, or reusing
the starter STS3215 instead of upgrading to Dynamixel.)*

---

### Practical notes / gotchas
- **Tendon anchoring** is the #1 failure point: use PTFE at every bend, and
  terminate braid with a Palomar knot or a metal crimp around a smooth post —
  braid saws through raw printed TPU/PLA.
- **Diaphragm vacuum pumps are one-directional** — you can't reverse one to
  inflate the jamming bag; use the 3-way solenoid to vent-to-atmosphere for
  fast un-jamming.
- **Print TPU dry** (dry box / 50 °C for a few hours). 95A on direct-drive is
  easy; on Bowden use Cheetah 95A specifically.
- **EMG needs a common reference electrode** and clean skin prep; start with
  MyoWare's envelope output for thresholding before moving to raw-signal ML
  on BioAmp.
- For **current-based grip feedback** (adaptive grasp without tactile
  sensors), the Dynamixel XC330 or a current-sensing shunt on the Feetech
  supply is the cheapest path.

*All prices approximate, mid-2026, single-unit retail; expect 10–30% swings
by vendor and quantity.*

---

## Addendum — verified pricing & extra options (second research pass, July 2026)

A second, source-verified pass on actuators and tendons produced these
corrections and additions:

### Actuators
- **Dynamixel XL330-M288-T**: confirmed **$27.49** at robotis.us, 18 g, true
  current (torque) control at 5 V — the best option for grip-force control by
  weight. 6 units ≈ $165.
- **Dynamixel XC330-T288-T**: verified **~$103** at robotis.us (pricier than
  first-pass estimate — the M288/T288 variants differ; check the exact SKU
  before budgeting).
- **Waveshare ST3215** (Feetech-based): 30 kg·cm @12V, 360° magnetic encoder,
  servo/motor mode switch, up to 253 on one bus — **~$25–27** and easy to buy
  on Amazon. Good STS3215 alternative with Western retail availability.
- **Feetech SCS0009**: 9 g-class micro *bus* servo, 2.3 kg·cm, **~$7** — cheap
  option for thumb abduction or individual finger tweaks on the same bus.
- **STS3215 ecosystem note**: this is the servo in Hugging Face
  **LeRobot SO-100/SO-101** arms — Python drivers (`feetech-servo-sdk`,
  lerobot) and a large community already exist.
- **Budget linear option**: N20 gearmotor + M3/M4 lead-screw shaft, **$3–10**
  each — no feedback or limit switches (add a pot yourself), slow, but five
  of them cost less than one Actuonix.

### Tendons
- **KastKing SuperPower braid** (8-strand UHMWPE), 65–80 lb × 327 yd:
  **~$10–16** on Amazon — best value; PowerPro 65 lb/150 yd runs ~$20–25.
- Recommended spec confirmed: **65–100 lb test (~0.4–0.55 mm dia)** — routes
  through 1 mm channels with load margin; stretch <1–3 %.
- **UHMWPE caveats**: creeps slowly under sustained tension (make tendon
  terminations re-tensionable with adjustment screws) and melts at ~144 °C —
  keep away from hot ends when printing repairs.
- **Kevlar braid** (100 lb, ~0.8 mm, ~$8–12/100 ft): zero creep and
  heat-proof, but **worse flex-fatigue over small pulleys** than UHMWPE —
  only pick it where creep or heat genuinely matters.
- **PTFE sizing**: 1 mm ID × 2 mm OD microtube (~$8–10 for 5 m) fits 0.5 mm
  tendons in tight finger channels; standard 2 mm ID × 4 mm OD Bowden tube
  for palm/forearm runs.
- **Nylon mono verdict**: stretches 15–25 % and creeps badly — use only for
  elastic return, never as a flexor tendon.

### Verified budget summaries (actuation + tendons only)
- 6× DS3218 + KastKing 80 lb braid + PTFE ≈ **$90–100**
- 6× Feetech STS3215 (smart bus) ≈ **$100–120**
- 6× Dynamixel XL330 (lightweight, current control) ≈ **$180**
