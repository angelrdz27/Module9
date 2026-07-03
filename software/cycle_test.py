#!/usr/bin/env python3
"""Automated open/close cycling for fatigue tests (T4/T11).

Drives the firmware over serial, alternating `c` and `o`, and logs the
telemetry so you can watch grip-force drift across thousands of cycles.

    python cycle_test.py --port /dev/ttyACM0 --cycles 500 --dwell 1.5

Requires pyserial. Ctrl-C stops early and still writes the log.
"""
import argparse
import sys
import time

try:
    import serial
except ImportError:
    sys.exit("pyserial required: pip install pyserial")


def run(port, baud, cycles, dwell, logpath):
    ser = serial.Serial(port, baud, timeout=0.1)
    time.sleep(2)
    ser.reset_input_buffer()

    log = open(logpath, "w")
    log.write("cycle,phase,millis,emg_raw,emg_env,state,servo_pos,servo_load,jammed\n")
    done = 0
    try:
        for c in range(1, cycles + 1):
            for phase in ("c", "o"):
                ser.write((phase + "\n").encode())
                t0 = time.time()
                while time.time() - t0 < dwell:
                    line = ser.readline().decode(errors="ignore").strip()
                    if line and not line.startswith("#") and "," in line \
                            and not line.startswith("millis"):
                        log.write(f"{c},{phase},{line}\n")
            done = c
            if c % 50 == 0:
                print(f"  {c}/{cycles} cycles")
    except KeyboardInterrupt:
        print("\nstopped early")
    finally:
        ser.write(b"o\n")   # leave the hand open
        ser.close()
        log.close()
    print(f"Completed {done} cycles -> {logpath}")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--port", required=True)
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument("--cycles", type=int, default=500)
    ap.add_argument("--dwell", type=float, default=1.5, help="seconds per phase")
    ap.add_argument("--log", default="cycle_log.csv")
    args = ap.parse_args()
    run(args.port, args.baud, args.cycles, args.dwell, args.log)


if __name__ == "__main__":
    main()
