// ============================================================
// Whiffle-tree tendon differential — one servo, four fingers
//
//   servo horn --> primary rocker --> 2x secondary rockers --> fingers
//
// Each rocker pivots freely at its midpoint on an M3 bolt. When one
// finger contacts an object its tendon stalls; the rocker rotates and
// routes the remaining travel to the sibling finger. Tendon ends clamp
// under M3 grub screws in slotted holes so UHMWPE creep can be taken
// up without re-knotting.
//
// PRINT: PETG or PLA+, flat on the bed, 4 perimeters, 30% gyroid.
// ============================================================

/* [Rockers] */
primary_len   = 50;
secondary_len = 40;
rocker_w      = 9;
rocker_t      = 5;

/* [Holes] */
pivot_d       = 3.4;  // M3 clearance at midpoint
tendon_hole_d = 2.0;  // tendon pass-through at rocker ends
grub_d        = 2.6;  // M3 self-tap for tendon clamp grub screw
slot_len      = 5;    // tensioning slot at each end

/* [Servo link] */
horn_hole_d   = 3.4;  // link from servo horn to primary rocker midpoint tab
tab_len       = 8;

$fn = 40;
EPS = 0.01;

module rocker(len) {
    difference() {
        hull() // rounded bar
            for (x = [-len/2, len/2])
                translate([x, 0, 0]) cylinder(d = rocker_w, h = rocker_t);
        // midpoint pivot
        translate([0, 0, -EPS]) cylinder(d = pivot_d, h = rocker_t + 2*EPS);
        // tensioning slots + tendon holes at both ends
        for (s = [-1, 1]) {
            hull() for (x = [0, -s * slot_len])
                translate([s * (len/2 - 2) + x, 0, -EPS])
                    cylinder(d = tendon_hole_d, h = rocker_t + 2*EPS);
            // grub screw enters from the edge, clamps tendon in the slot
            translate([s * (len/2 - 2 - slot_len/2), -rocker_w/2 - EPS, rocker_t/2])
                rotate([-90, 0, 0])
                    cylinder(d = grub_d, h = rocker_w/2);
        }
    }
}

module primary_rocker() {
    union() {
        rocker(primary_len);
        // tab linking to the servo horn (drive input at the midpoint)
        difference() {
            hull() {
                translate([0, 0, 0]) cylinder(d = rocker_w, h = rocker_t);
                translate([0, -tab_len - rocker_w/2, 0])
                    cylinder(d = rocker_w, h = rocker_t);
            }
            translate([0, -tab_len - rocker_w/2, -EPS])
                cylinder(d = horn_hole_d, h = rocker_t + 2*EPS);
            translate([0, 0, -EPS]) cylinder(d = pivot_d, h = rocker_t + 2*EPS);
        }
    }
}

// ---- print plate: 1 primary + 2 secondary ----
primary_rocker();
translate([0, 25, 0]) rocker(secondary_len);
translate([0, 40, 0]) rocker(secondary_len);
