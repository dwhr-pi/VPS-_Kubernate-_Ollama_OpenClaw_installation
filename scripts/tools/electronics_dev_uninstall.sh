#!/usr/bin/env bash
set -euo pipefail

ELECTRONICS_HOME="${ELECTRONICS_HOME:-$HOME/Ultimate_KI_Setup/electronics}"

echo "Elektronik Entwickler Deinstallation"
echo "Projektordner: $ELECTRONICS_HOME"
echo "Aus Sicherheitsgruenden werden Projekte, Datenblaetter, Gerber, BOMs und Firmware nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  rm -rf \"$ELECTRONICS_HOME\""

