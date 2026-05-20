#!/usr/bin/env bash
set -euo pipefail

ROBOTICS_HOME="${ROBOTICS_HOME:-$HOME/Ultimate_KI_Setup/robotics_control}"

echo "Robotik & Anlagensteuerung Deinstallation"
echo "Projektordner: $ROBOTICS_HOME"
echo "Logs, Simulationen, Safety-Konfigurationen und Projektdateien werden nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  rm -rf \"$ROBOTICS_HOME\""

