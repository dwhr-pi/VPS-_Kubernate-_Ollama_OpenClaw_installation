"""
Parametrisches FreeCAD-Beispiel: Gehaeuse mit optionalem Deckel,
vier Schraubloechern und Lueftungsschlitzen.

Ausfuehrung:
  freecadcmd profiles/cad_konstrukteur/examples/freecad_box_example.py
"""

import os

import FreeCAD as App
import Part

length = 100.0
width = 70.0
height = 35.0
wall = 2.5
screw_diameter = 3.2
screw_offset = 8.0
vent_count = 5
vent_width = 4.0
vent_length = 28.0
export_dir = os.path.abspath("cad_exports")

os.makedirs(export_dir, exist_ok=True)

doc = App.newDocument("parametric_case")

outer = Part.makeBox(length, width, height)
inner = Part.makeBox(length - 2 * wall, width - 2 * wall, height)
inner.translate(App.Vector(wall, wall, wall))
case = outer.cut(inner)

for x in (screw_offset, length - screw_offset):
    for y in (screw_offset, width - screw_offset):
        hole = Part.makeCylinder(screw_diameter / 2, height + 2)
        hole.translate(App.Vector(x, y, -1))
        case = case.cut(hole)

vent_spacing = vent_width * 2.2
start_x = (length - ((vent_count - 1) * vent_spacing + vent_width)) / 2
for i in range(vent_count):
    vent = Part.makeBox(vent_width, vent_length, wall + 2)
    vent.translate(App.Vector(start_x + i * vent_spacing, (width - vent_length) / 2, height - wall - 1))
    case = case.cut(vent)

case_obj = doc.addObject("Part::Feature", "case_body")
case_obj.Shape = case

lid = Part.makeBox(length, width, wall)
lid_obj = doc.addObject("Part::Feature", "optional_lid")
lid_obj.Shape = lid
lid_obj.Placement.Base = App.Vector(0, 0, height + 5)

doc.recompute()

Part.export([case_obj], os.path.join(export_dir, "parametric_case_body.stl"))
Part.export([case_obj, lid_obj], os.path.join(export_dir, "parametric_case_with_lid.step"))

print(f"Exportiert nach: {export_dir}")
