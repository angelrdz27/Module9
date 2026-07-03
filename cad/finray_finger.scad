// ============================================================
// Parametric fin-ray finger for tendon-driven prosthetic hand
// See ../finray-cad-print-parameters.md for parameter guidance.
//
// Coordinate system (side profile in XY, extruded along Z):
//   X = depth (back wall at x=0, front/contact wall converging)
//   Y = length (base at y=0, tip at y=finger_length)
//   Z = finger width
//
// PRINT ORIENTATION: lying on its side face (as modeled) — walls
// and ribs are continuous XY extrusion paths; bending stress runs
// along layer lines. TPU 95A, 2 perimeters, 0-10% infill.
// ============================================================

/* [Finger size] */
finger_length = 80;      // base->tip. index/middle/ring/pinky ~ 80/88/82/65
base_depth    = 16;      // wall-to-wall at the base
tip_depth     = 5;       // wall-to-wall at the tip
finger_width  = 16;      // extrusion width (Z)

/* [Walls] */
front_wall_t      = 1.0; // dominant compliance knob (0.8 soft .. 1.6 firm)
front_wall_t_tip  = 1.0; // set < front_wall_t for a graded ("biological") wall
back_wall_t       = 1.8; // keep >= 1.5x front wall

/* [Ribs] */
rib_count    = 7;
rib_t        = 0.8;
rib_tilt     = 15;       // deg toward tip; 0 = perpendicular to back wall
floating_gap = 0;        // 0.4 => "floating ribs" (soft first contact, then stiffen)

/* [Tendon] */
tendon_channel_d = 2.5;  // fits 2mm-OD PTFE liner
tendon_anchor_d  = 4;    // cross-hole near tip, figure-8 stopper knot behind it

/* [Base mount] */
base_height   = 12;      // mounting block below y=0
mount_hole_d  = 3.4;     // M3 clearance, two cross-holes
tip_solid_len = 6;       // solid tip cap

$fn = 48;
EPS = 0.01;

// ---- derived ----
// front wall outer x at height y (linear taper base->tip)
function fw_outer(y) = base_depth - (base_depth - tip_depth) * y / finger_length;
// graded front wall thickness at height y
function fw_t(y) = front_wall_t - (front_wall_t - front_wall_t_tip) * y / finger_length;
function fw_inner(y) = fw_outer(y) - fw_t(y);

// ------------------------------------------------------------
// 2D profile pieces
// ------------------------------------------------------------
N = 24; // taper segmentation

module envelope_2d() { // full outer boundary of the profile
    polygon(concat(
        [[0, 0]],
        [for (i = [0:N]) [fw_outer(i * finger_length / N), i * finger_length / N]],
        [[0, finger_length]]
    ));
}

module cavity_2d() { // interior air: inside walls, minus floating gap strip
    polygon(concat(
        [[back_wall_t, 0]],
        [for (i = [0:N]) let (y = i * finger_length / N)
            [max(back_wall_t + EPS, fw_inner(y) - floating_gap), y]],
        [[back_wall_t, finger_length]]
    ));
}

module ribs_2d() { // overlong tilted ribs, trimmed against the cavity
    intersection() {
        cavity_2d();
        for (i = [1:rib_count]) {
            y = i * (finger_length - tip_solid_len - 4) / (rib_count + 1);
            translate([back_wall_t - EPS, y])
                rotate(rib_tilt)
                    square([base_depth * 1.5, rib_t]);
        }
    }
}

module profile_2d() {
    union() {
        difference() { // walls + solid tip
            envelope_2d();
            // subtract cavity everywhere except the solid tip cap
            intersection() {
                cavity_2d();
                translate([-EPS, -EPS])
                    square([base_depth + 2 * EPS,
                            finger_length - tip_solid_len + EPS]);
            }
        }
        ribs_2d();
        // base mounting block
        translate([0, -base_height]) square([base_depth, base_height + EPS]);
    }
}

// ------------------------------------------------------------
// 3D finger
// ------------------------------------------------------------
module finray_finger() {
    difference() {
        union() {
            linear_extrude(finger_width) profile_2d();
            // thickened ridge on the back wall to house the tendon channel
            translate([-tendon_channel_d / 2, -base_height, finger_width / 2])
                rotate([-90, 0, 0])
                    cylinder(d = tendon_channel_d + 2 * 1.2,
                             h = finger_length - tip_solid_len / 2 + base_height);
        }
        // tendon channel bore (along the back wall, full length)
        translate([-tendon_channel_d / 2, -base_height - EPS, finger_width / 2])
            rotate([-90, 0, 0])
                cylinder(d = tendon_channel_d,
                         h = finger_length + base_height + 2 * EPS);
        // tendon anchor cross-hole in the solid tip
        translate([-tendon_channel_d, finger_length - tip_solid_len / 2, -EPS])
            cylinder(d = tendon_anchor_d, h = finger_width + 2 * EPS);
        // M3 mounting cross-holes in the base block
        for (y = [-base_height * 0.3, -base_height * 0.75])
            translate([base_depth / 2, y, -EPS])
                cylinder(d = mount_hole_d, h = finger_width + 2 * EPS);
        // silicone-pad dovetail keys on the distal third of the contact wall
        for (i = [0:2]) {
            y = finger_length * (0.68 + i * 0.09);
            translate([fw_inner(y) + fw_t(y) / 2, y, finger_width / 2])
                rotate([0, 90, 0])
                    cylinder(d1 = 3.5, d2 = 2, h = fw_t(y) + EPS, center = false);
        }
    }
}

// ------------------------------------------------------------
// Optional: open-face drape mold for the silicone fingertip pad.
// Print in PLA, pour Ecoflex 00-30 ~3.5mm deep, press finger tip in.
// ------------------------------------------------------------
module fingertip_pad_mold(pad_t = 3.5) {
    pad_len = finger_length * 0.33;
    difference() {
        cube([base_depth + 10, pad_len + 10, finger_width * 0.8]);
        translate([5 + pad_t, 5 - (finger_length - pad_len), finger_width * 0.8
                   - finger_width + 2])
            finray_finger();
    }
}

// ---- render selection ----
part = "finger"; // "finger" | "mold"
if (part == "finger") finray_finger();
else fingertip_pad_mold();
