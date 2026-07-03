// ============================================================
// Wrist / socket interface — connects the palm chassis to a
// residual-limb socket. Two parts:
//   1. wrist_adapter  — bolts to the palm (shared bolt circle),
//                       provides a quick-release dovetail + wire pass.
//   2. socket_cuff    — parametric forearm cuff (scale to a scan or
//                       to two circumference measurements).
//
// v1 is a passive rigid wrist. A compliant wrist (TPU disc between
// the two bolt circles) is a drop-in upgrade — see note at bottom.
//
// PRINT: PETG. Cuff can be TPU 95A for a compliant, comfortable fit.
// ============================================================

/* [Shared with palm_chassis.scad] */
wrist_bolt_circle = 40; wrist_bolt_d = 3.4; wrist_bolt_n = 4;

/* [Adapter] */
adapter_d = 52; adapter_t = 10;
wire_pass_d = 12;
dovetail_w = 24; dovetail_h = 8; dovetail_taper = 3;

/* [Socket cuff] — measure the residual limb */
forearm_prox_circ = 240;   // mm circumference near elbow
forearm_dist_circ = 180;   // mm circumference near wrist
cuff_len = 120;
cuff_wall = 3;
strap_slot_w = 25; strap_slot_h = 4;

$fn = 64;
EPS = 0.01;
function circ_to_r(c) = c / (2 * PI);

module bolt_circle(h) {
    for (i = [0:wrist_bolt_n - 1])
        rotate([0, 0, i * 360/wrist_bolt_n])
            translate([wrist_bolt_circle/2, 0, -EPS])
                cylinder(d = wrist_bolt_d, h = h + 2*EPS);
}

module wrist_adapter() {
    difference() {
        union() {
            cylinder(d = adapter_d, h = adapter_t);
            // male dovetail on top (mates socket_cuff's female slot)
            translate([0, 0, adapter_t])
                linear_extrude(dovetail_h)
                    polygon([[-dovetail_w/2, 0], [dovetail_w/2, 0],
                             [dovetail_w/2 - dovetail_taper, dovetail_h*1.4],
                             [-dovetail_w/2 + dovetail_taper, dovetail_h*1.4]]);
        }
        bolt_circle(adapter_t);
        translate([0, 0, -EPS]) cylinder(d = wire_pass_d, h = adapter_t + 2*EPS);
    }
}

module socket_cuff() {
    rp = circ_to_r(forearm_prox_circ);
    rd = circ_to_r(forearm_dist_circ);
    difference() {
        // tapered tube shell
        difference() {
            cylinder(r1 = rd + cuff_wall, r2 = rp + cuff_wall, h = cuff_len);
            translate([0, 0, -EPS])
                cylinder(r1 = rd, r2 = rp, h = cuff_len + 2*EPS);
        }
        // open the volar side ~140 deg so the limb slides in
        translate([0, 0, -EPS])
            rotate([0, 0, -70])
                linear_extrude(cuff_len + 2*EPS)
                    polygon([[0,0], [rp*2, 0],
                             [rp*2*cos(140), rp*2*sin(140)]]);
        // strap slots (two pairs)
        for (z = [cuff_len*0.25, cuff_len*0.7], a = [30, 150])
            rotate([0, 0, a])
                translate([rd, 0, z])
                    rotate([0, 90, 0])
                        cube([strap_slot_h, strap_slot_w, 12], center = true);
        // female dovetail at the distal end (mates wrist_adapter)
        translate([0, 0, -EPS])
            linear_extrude(dovetail_h + 1)
                polygon([[-dovetail_w/2 - 0.3, 0], [dovetail_w/2 + 0.3, 0],
                         [dovetail_w/2 - dovetail_taper + 0.3, dovetail_h*1.4],
                         [-dovetail_w/2 + dovetail_taper - 0.3, dovetail_h*1.4]]);
    }
}

// ---- render selection ----
part = "adapter"; // "adapter" | "cuff"
if (part == "adapter") wrist_adapter();
else translate([80, 0, 0]) socket_cuff();

// Compliant-wrist upgrade: print a 6 mm TPU 95A disc with the same
// bolt circle and sandwich it between wrist_adapter and palm_chassis
// for a shock-absorbing, slightly flexible wrist.
