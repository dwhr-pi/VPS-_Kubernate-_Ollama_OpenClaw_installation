#!/usr/bin/env bash
set -euo pipefail

ARCHITECTURE_HOME="${ARCHITECTURE_HOME:-$HOME/Ultimate_KI_Setup/architecture}"

echo "Architektur 3D BIM Deinstallation"
echo "Projektordner: $ARCHITECTURE_HOME"
echo "Projekte, IFC, CAD, Texturen, Renderings und Backups werden nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  rm -rf \"$ARCHITECTURE_HOME\""

