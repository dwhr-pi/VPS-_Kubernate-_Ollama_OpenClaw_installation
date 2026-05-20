#!/usr/bin/env bash
set -euo pipefail

CAD3D_HOME="${CAD3D_HOME:-$HOME/Ultimate_KI_Setup/cad_3d_konstruktion}"

echo "CAD 3D Konstruktion Deinstallation"
echo "Projektordner: $CAD3D_HOME"
echo "CAD-Dateien, Exporte, STL/STEP, Slicer-Projekte, Reports und Archive werden nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  rm -rf \"$CAD3D_HOME\""
