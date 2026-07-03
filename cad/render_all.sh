#!/usr/bin/env bash
# Render every printable part to ../build/stl and fail loudly on any
# non-manifold ("Simple: no") result. Requires OpenSCAD in PATH.
set -euo pipefail
cd "$(dirname "$0")"
OUT=../build/stl
mkdir -p "$OUT"

render() { # name  scadfile  [extra -D args...]
  local name="$1"; local scad="$2"; shift 2
  echo "-> $name.stl"
  local log
  log=$(openscad -o "$OUT/$name.stl" "$@" "$scad" 2>&1)
  if ! grep -q "Simple:\s*yes" <<<"$log"; then
    echo "!! $name is NOT a manifold solid:"; echo "$log" | grep -iE "simple|error|warning" || true
    exit 1
  fi
}

render finger_index         finray_finger.scad     -D finger_length=80
render finger_middle        finray_finger.scad     -D finger_length=88
render finger_ring          finray_finger.scad     -D finger_length=82
render finger_pinky         finray_finger.scad     -D finger_length=65
render finger_floating      finray_finger.scad     -D floating_gap=0.4
render finger_graded        finray_finger.scad     -D front_wall_t=1.4 -D front_wall_t_tip=0.8
render calibration_coupon   calibration_coupon.scad
render fingertip_pad_mold   finray_finger.scad     -D 'part="mold"'
render whiffletree          whiffletree.scad
render palm_chassis         palm_chassis.scad
render wrist_adapter        wrist_socket.scad      -D 'part="adapter"'
render socket_cuff          wrist_socket.scad      -D 'part="cuff"'

echo "All parts rendered and manifold-checked OK."
