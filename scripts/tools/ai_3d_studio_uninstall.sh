#!/usr/bin/env bash
set -euo pipefail

AI_3D_HOME="${AI_3D_HOME:-$HOME/Ultimate_KI_Setup}"

echo "AI 3D Studio Deinstallation"
echo "Projektordner: $AI_3D_HOME"
echo "Aus Sicherheitsgruenden werden Assets, Modelle und Exporte nicht automatisch geloescht."
echo "Wenn du wirklich alles entfernen willst, pruefe den Pfad und fuehre manuell aus:"
echo "  rm -rf \"$AI_3D_HOME\""

