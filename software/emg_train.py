#!/usr/bin/env python3
"""Train a gesture classifier from labeled EMG sessions.

Reads data/<label>.csv files produced by emg_collect.py, windows the
envelope signal, extracts standard EMG time-domain features, trains a
RandomForest, prints a confusion matrix, and emits firmware-ready
constants. Optional TFLite export path is documented at the bottom.

    python emg_train.py --datadir data --labels rest close open

Requires: numpy, scikit-learn (pip install numpy scikit-learn).
A synthetic self-test runs if no data files are found:
    python emg_train.py --selftest
"""
import argparse
import glob
import os
import sys

import numpy as np

WINDOW = 4      # samples per window (~400 ms at 10 Hz telemetry)
STRIDE = 2      # 50% overlap
ENV_COL = 2     # emg_env column index in the CSV


# ---------------- feature extraction ----------------
def features(window):
    """Standard EMG time-domain features over one window of envelope values."""
    w = np.asarray(window, dtype=float)
    diff = np.diff(w) if len(w) > 1 else np.array([0.0])
    mav = np.mean(np.abs(w))                      # mean absolute value
    rms = np.sqrt(np.mean(w ** 2))                # root mean square
    wl = np.sum(np.abs(diff))                     # waveform length
    zc = np.sum(np.abs(np.sign(w[:-1] - np.mean(w))
                       - np.sign(w[1:] - np.mean(w))) > 0) if len(w) > 1 else 0
    return [mav, rms, wl, float(zc)]


def windowize(series, label):
    X, y = [], []
    for i in range(0, len(series) - WINDOW + 1, STRIDE):
        X.append(features(series[i:i + WINDOW]))
        y.append(label)
    return X, y


def load_dataset(datadir, labels):
    X, y = [], []
    for label in labels:
        path = os.path.join(datadir, f"{label}.csv")
        if not os.path.exists(path):
            print(f"! missing {path}, skipping")
            continue
        data = np.genfromtxt(path, delimiter=",", skip_header=1)
        if data.ndim == 1:
            data = data.reshape(1, -1)
        env = data[:, ENV_COL]
        Xi, yi = windowize(env, label)
        X.extend(Xi)
        y.extend(yi)
        print(f"  {label}: {len(yi)} windows from {len(env)} samples")
    return np.array(X), np.array(y)


def train(X, y):
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.metrics import classification_report, confusion_matrix
    from sklearn.model_selection import train_test_split

    Xtr, Xte, ytr, yte = train_test_split(
        X, y, test_size=0.25, random_state=0, stratify=y)
    clf = RandomForestClassifier(n_estimators=100, max_depth=8, random_state=0)
    clf.fit(Xtr, ytr)
    pred = clf.predict(Xte)

    print("\n=== confusion matrix ===")
    print("labels:", sorted(set(y)))
    print(confusion_matrix(yte, pred, labels=sorted(set(y))))
    print("\n=== report ===")
    print(classification_report(yte, pred))
    return clf


def emit_thresholds(X, y):
    """Print simple per-class MAV bands the firmware can use without ML."""
    print("=== firmware threshold hints (envelope MAV per class) ===")
    for label in sorted(set(y)):
        mav = X[y == label][:, 0]
        print(f"  {label:8s}: MAV mean={mav.mean():7.1f}  "
              f"p10={np.percentile(mav, 10):7.1f}  "
              f"p90={np.percentile(mav, 90):7.1f}")
    print("# Set CLOSE_FRACTION so its threshold sits between rest.p90 "
          "and close.p10.")


def selftest():
    """Synthetic three-class data so the pipeline runs with no hardware."""
    rng = np.random.default_rng(0)
    rest = rng.normal(120, 15, 300)
    close = rng.normal(600, 60, 300)
    openg = np.concatenate([rng.normal(500, 50, 150), rng.normal(120, 15, 150)])
    X, y = [], []
    for series, label in [(rest, "rest"), (close, "close"), (openg, "open")]:
        Xi, yi = windowize(series, label)
        X.extend(Xi)
        y.extend(yi)
    return np.array(X), np.array(y)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--datadir", default="data")
    ap.add_argument("--labels", nargs="+", default=["rest", "close", "open"])
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()

    if args.selftest or not glob.glob(os.path.join(args.datadir, "*.csv")):
        if not args.selftest:
            print("No data files found — running synthetic self-test.\n")
        X, y = selftest()
    else:
        X, y = load_dataset(args.datadir, args.labels)

    if len(X) < 10:
        sys.exit("Not enough windows to train.")

    train(X, y)
    emit_thresholds(X, y)

    print("\n# TFLite-Micro upgrade path: replace RandomForest with a small "
          "Keras MLP (Dense 16->8->3), then `tflite_convert` and embed the "
          ".tflite as a C array for TensorFlow Lite Micro on the ESP32-S3.")


if __name__ == "__main__":
    main()
