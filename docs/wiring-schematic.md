# Wiring Schematic

Complete electrical connections for the hand controller. Companion to
`../architecture.md` §3 and `../firmware/README.md`.

## Block diagram

```
                    ┌──────────────────────── 2S Li-ion pack (7.4–12 V) ───────────────────────┐
                    │                                                                            │
              ┌─────┴─────┐                                                                      │
              │    BMS    │  (≥5 A, over-current + over-discharge protection)                    │
              └─────┬─────┘                                                                      │
        VBAT ───────┼──────────────┬───────────────┬────────────────┐                           │
                    │              │               │                │                           │
              ┌─────▼─────┐   ┌────▼────┐    ┌──────▼──────┐  ┌──────▼──────┐                     │
              │ Buck 5 V  │   │ STS3215 │    │ Pump (via   │  │ Solenoid    │                     │
              │  (3 A)    │   │  servo  │    │  MOSFET Q1) │  │ (via MOSFET │                     │
              └──┬────┬───┘   └────┬────┘    └──────┬──────┘  │   Q2)       │                     │
                 │    │            │ 1-wire         │         └──────┬──────┘                     │
              5V │    │ 5V         │ TTL bus        │ gate           │ gate                       │
                 │    │            │                │                │                            │
        ┌────────▼──┐ │      ┌─────▼─────────────────────────────────────────────┐               │
        │ MyoWare2.0│ │      │                  ESP32-S3                          │               │
        │  ENV out ─┼─┼──────► GPIO4 (ADC1_CH3)                                   │               │
        └───────────┘ │      │  GPIO17 (TX1) ──[1kΩ]──┐                           │               │
                      │      │  GPIO18 (RX1) ─────────┴──► STS3215 data           │               │
                      └──────► 3V3 / VIN (USB or buck)                            │               │
                             │  GPIO5  ──────────────────► Q1 gate (pump)         │               │
                             │  GPIO6  ──────────────────► Q2 gate (solenoid)     │               │
                             │  GPIO7  ◄── button ── GND                          │               │
                             │  GPIO15 ──────────────────► LED ──[330Ω]── GND     │               │
                             │  GND ─────────────────────────────────────────────┼───────────────┘
                             └──────────────────────────────────────────────────-┘
                                        (common ground tie — REQUIRED)
```

## Half-duplex servo bus (the one non-obvious part)

The STS3215 talks on a **single data wire**. To drive it from a normal UART:

```
ESP32 GPIO17 (TX1) ──[1 kΩ]──┬──► STS3215 DATA
ESP32 GPIO18 (RX1) ──────────┘
```

- TX idles HIGH. When the ESP32 sends, the 1 kΩ resistor is weak enough that
  the servo can still pull the line for its reply; RX reads both our echo and
  the response. The firmware's `drainEcho()` discards our own transmitted
  bytes before parsing the reply.
- Tidy alternative: a **Waveshare Bus Servo Adapter (~$6)** does the direction
  switching in hardware — wire GPIO17→TX, GPIO18→RX, and skip the resistor.

## MOSFET low-side switches (pump & solenoid)

Both inductive loads use a logic-level N-channel MOSFET (IRLZ44N, AO3400, or a
ready-made MOSFET module):

```
VBAT ──► load(+)
         load(−) ──► MOSFET drain
                     MOSFET source ──► GND
         GPIO ──[100Ω]──► MOSFET gate,  gate ──[10kΩ]──► GND (pulldown)
   flyback diode (1N4007 / SS34) across the load, cathode to VBAT
```

The flyback diode is mandatory — without it the coil's collapse spike will
reset or damage the ESP32.

## Connection table

| From | To | Wire |
|---|---|---|
| BMS VBAT+ | Servo V+, Buck IN+, Pump+, Solenoid+ | 20 AWG |
| BMS VBAT− | Common ground rail | 20 AWG |
| Buck 5 V | MyoWare VIN, (optional ESP32 VIN) | 24 AWG |
| ESP32 GPIO17 | 1 kΩ → STS3215 data | 26 AWG |
| ESP32 GPIO18 | STS3215 data | 26 AWG |
| ESP32 GPIO4 | MyoWare ENV | shielded if long |
| ESP32 GPIO5/6 | Q1/Q2 gate (100 Ω series) | 26 AWG |
| ESP32 GPIO7 | Button → GND | 26 AWG |
| ESP32 GPIO15 | LED anode (330 Ω) | 26 AWG |
| ESP32 GND | Common ground rail | 22 AWG |

## Safety notes
- **Common ground** between the servo/pump supply and the ESP32 is required or
  the serial bus and MOSFET gates float.
- Fuse VBAT at ~5 A right after the BMS.
- Never back-power the servo from the ESP32 5 V pin — it can't source stall
  current and will brown out.
- On brown-out the ESP32 reboots with the servo torque-off; the hand goes
  **passively compliant** rather than clamping — a safety property of the soft
  design (`../architecture.md` §7).
