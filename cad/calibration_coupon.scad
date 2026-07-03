// ============================================================
// TPU flow-calibration coupon (Phase 1, test T1).
// A single-wall rectangle: print it, measure the wall with
// calipers at 5 points, adjust slicer flow % until measured =
// designed (wall_t) +/- 0.05 mm. Print lying flat, same settings
// as the fingers.
// ============================================================

wall_t   = 1.0;   // target wall thickness (match front_wall_t you'll use)
height   = 50;    // Z
length   = 20;    // X footprint
$fn = 8;
EPS = 0.01;

difference() {
    cube([length, wall_t + 8, height]);
    // hollow it into a thin U-wall so only the target wall is printed
    translate([-EPS, wall_t, -EPS])
        cube([length - 2*EPS, 8 + EPS, height + 2*EPS]);
}
// engrave the target thickness so coupons don't get mixed up
translate([2, wall_t/2, height - 6])
    rotate([90, 0, 0])
        linear_extrude(wall_t + EPS, center = true)
            text(str(wall_t), size = 5);
