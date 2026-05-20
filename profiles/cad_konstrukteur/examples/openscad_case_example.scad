// Parametrisches OpenSCAD-Gehaeuse mit Schraubloechern und Lueftungsschlitzen.
// Export in OpenSCAD: F6 rendern, dann File -> Export -> STL.

length = 100;
width = 70;
height = 35;
wall = 2.5;
screw_diameter = 3.2;
screw_offset = 8;
vent_count = 5;
vent_width = 4;
vent_length = 28;

module case_body() {
    difference() {
        cube([length, width, height], center = false);
        translate([wall, wall, wall])
            cube([length - 2 * wall, width - 2 * wall, height], center = false);

        for (x = [screw_offset, length - screw_offset])
            for (y = [screw_offset, width - screw_offset])
                translate([x, y, -1])
                    cylinder(h = height + 2, d = screw_diameter, $fn = 40);

        start_x = (length - ((vent_count - 1) * vent_width * 2.2 + vent_width)) / 2;
        for (i = [0 : vent_count - 1])
            translate([start_x + i * vent_width * 2.2, (width - vent_length) / 2, height - wall - 1])
                cube([vent_width, vent_length, wall + 2], center = false);
    }
}

module optional_lid() {
    translate([0, 0, height + 5])
        cube([length, width, wall], center = false);
}

case_body();
optional_lid();
