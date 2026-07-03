// ============================================================
// Palm / chassis — mounts 4 fingers + thumb, houses the servo,
// whiffle-tree differential, tendon routing, and the jamming pad.
//
// PRINT: PETG or PLA+, 4 perimeters, 30% gyroid, flat (palm-down).
// Fingers bolt to the finger rail with M3; the STS3215 drops into
// the servo pocket; the jamming pad seats in the palm recess.
//
// See ../architecture.md §2 for the mechanical layout.
// ============================================================

/* [Palm size] */
palm_w      = 85;   // across the knuckles
palm_len    = 95;   // wrist to knuckle line
palm_t      = 22;   // thickness (houses servo + routing)
wall        = 3;

/* [Finger mounts] — x offset of each finger centerline from palm center */
// index / middle / ring / pinky spacing across an 85 mm palm
finger_x    = [-30, -10, 10, 28];
finger_w    = 16;   // must match finray_finger.scad finger_width
mount_hole_d = 3.4; // M3 clearance, matches base cross-holes

/* [Thumb] */
thumb_oppose_deg = 45;
thumb_x = -38; thumb_y = 28;

/* [Servo pocket] — Feetech STS3215: 45.2 x 24.7 x 35 mm */
servo_l = 45.6; servo_w = 25.1; servo_h = 35.4;

/* [Jamming pad recess] */
pad_recess_d = 45; pad_recess_depth = 8;

/* [Wrist interface] — bolt circle shared with wrist_socket.scad */
wrist_bolt_circle = 40; wrist_bolt_d = 3.4; wrist_bolt_n = 4;

$fn = 48;
EPS = 0.01;

module rounded_box(w, l, h, r = 4) {
    hull() for (x = [r - w/2, w/2 - r], y = [r, l - r])
        translate([x, y, 0]) cylinder(r = r, h = h);
}

module finger_mount_negative(x) {
    // slot the finger base sits in + two cross-holes for M3
    translate([x, palm_len - EPS, palm_t - finger_w]) {
        translate([-finger_w/2 - 0.3, -14, -0.3])
            cube([finger_w + 0.6, 15, finger_w + 0.6]);   // base pocket
        for (z = [finger_w * 0.3, finger_w * 0.7])
            translate([-palm_w, -7, z])
                rotate([0, 90, 0]) cylinder(d = mount_hole_d, h = palm_w * 2);
        translate([0, -7, finger_w/2])                     // tendon exit
            rotate([90, 0, 0]) cylinder(d = 4, h = 20);
    }
}

module palm_chassis() {
    difference() {
        rounded_box(palm_w, palm_len, palm_t);

        // hollow interior for routing + differential
        translate([0, 0, wall])
            rounded_box(palm_w - 2*wall, palm_len - 2*wall, palm_t, 3);

        // servo pocket (drops in from the palm side, wires exit to wrist)
        translate([servo_l/2 - 8, palm_len/2 - servo_w/2, palm_t - servo_h])
            cube([servo_l, servo_w, servo_h + EPS]);
        translate([servo_l/2 - 8, palm_len/2 - servo_w/2, palm_t - servo_h])
            translate([-6, servo_w/2, servo_h/2])          // horn/cable slot
                rotate([0, 90, 0]) cylinder(d = 14, h = servo_l + 12);

        // finger mounts
        for (x = finger_x) finger_mount_negative(x);

        // thumb mount (rotated post)
        translate([thumb_x, thumb_y, palm_t - finger_w])
            rotate([0, 0, thumb_oppose_deg])
                translate([-finger_w/2 - 0.3, 0, -0.3])
                    cube([finger_w + 0.6, 15, finger_w + 0.6]);

        // jamming pad recess in the palm face
        translate([5, palm_len * 0.4, palm_t - pad_recess_depth])
            cylinder(d = pad_recess_d, h = pad_recess_depth + EPS);
        translate([5, palm_len * 0.4, 0])                  // pad tube pass-through
            cylinder(d = 6, h = palm_t);

        // wrist bolt circle at the proximal face
        for (i = [0:wrist_bolt_n - 1])
            rotate([0, 0, i * 360/wrist_bolt_n])
                translate([wrist_bolt_circle/2, 0, -EPS])
                    translate([0, 3, 0])
                        rotate([90, 0, 0])
                            cylinder(d = wrist_bolt_d, h = 8);
    }
}

palm_chassis();
