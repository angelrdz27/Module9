#!/usr/bin/env python3
"""Collect labeled EMG telemetry from the hand firmware over serial.

The firmware streams CSV at 10 Hz:
    millis,emg_raw,emg_env,state,servo_pos,servo_load,jammed

Run one session per gesture; the label is the filename stem. Example:

    python emg_collect.py --port /dev/ttyACM0 --label rest     --seconds 30
    python emg_collect.py --port /dev/ttyACM0 --label close    --seconds 30
    python emg_collect.py --port /dev/ttyACM0 --label open     --seconds 30

Then train with emg_train.py. Requires: pyserial (pip install pyserial).
"""
import argparse
import csv
import sys
import time

try:
    import serial  # pyserial
except ImportError:
    sys.exit("pyserial required: pip install pyserial")

COLUMNS = ["millis", "emg_raw", "emg_env", "state",
           "servo_pos", "servo_load", "jammed"]


def collect(port, baud, label, seconds, outdir):
    ser = serial.Serial(port, baud, timeout=1)
    time.sleep(2)  # let the board reset after opening the port
    ser.reset_input_buffer()

    path = f"{outdir}/{label}.csv"
    rows, t0 = [], time.time()
    print(f"Recording '{label}' for {seconds}s — perform the gesture now...")
    while time.time() - t0 < seconds:
        line = ser.readline().decode(errors="ignore").strip()
        if not line or line.startswith("#") or line.startswith("millis"):
            continue
        parts = line.split(",")
        if len(parts) != len(COLUMNS):
            continue
        try:
            rows.append([int(float(p)) for p in parts])
        except ValueError:
            continue

    ser.close()
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(COLUMNS)
        w.writerows(rows)
    print(f"Saved {len(rows)} samples -> {path}")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--port", required=True, help="e.g. /dev/ttyACM0 or COM3")
    ap.add_argument("--baud", type=int, default=115200)
    ap.add_argument("--label", required=True, help="rest | close | open | ...")
    ap.add_argument("--seconds", type=int, default=30)
    ap.add_argument("--outdir", default="data")
    args = ap.parse_args()

    import os
    os.makedirs(args.outdir, exist_ok=True)
    collect(args.port, args.baud, args.label, args.seconds, args.outdir)


if __name__ == "__main__":
    main()
