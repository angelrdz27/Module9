# Software — EMG data collection & training

Python pipeline that turns the firmware's serial telemetry into a gesture
classifier and firmware-ready thresholds.

## Install
```bash
pip install -r requirements.txt
```

## Workflow
1. Flash the firmware, put on the MyoWare sensor, plug in USB.
2. Record one session per gesture (label = gesture name):
   ```bash
   python emg_collect.py --port /dev/ttyACM0 --label rest  --seconds 30
   python emg_collect.py --port /dev/ttyACM0 --label close --seconds 30
   python emg_collect.py --port /dev/ttyACM0 --label open  --seconds 30
   ```
   Files land in `data/<label>.csv`.
3. Train and read the results:
   ```bash
   python emg_train.py --datadir data --labels rest close open
   ```
   It prints a confusion matrix, a per-class report, and **envelope MAV
   bands** you can paste back into the firmware to tune `CLOSE_FRACTION`.

## No hardware yet?
```bash
python emg_train.py --selftest
```
runs the whole pipeline on synthetic data so you can verify the toolchain.

## Features extracted
Per 400 ms window (50 % overlap): MAV, RMS, waveform length, zero crossings —
the standard EMG time-domain set. Good separability with a small
RandomForest; upgrade to a Keras MLP + TFLite-Micro to run inference
on-device (noted at the end of `emg_train.py`).

## Files
- `emg_collect.py` — serial logger, one labeled CSV per session
- `emg_train.py` — windowing, features, RandomForest, threshold hints
- `requirements.txt` — pyserial, numpy, scikit-learn
