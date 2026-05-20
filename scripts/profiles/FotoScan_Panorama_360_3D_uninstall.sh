#!/usr/bin/env bash
set -euo pipefail

MEDIA_HOME="${FOTOSCAN_MEDIA_HOME:-$HOME/KI-Media}"

echo "FotoScan Panorama 360 3D Deinstallation"
echo "Projekt-/Outputordner: $MEDIA_HOME"
echo "Aus Sicherheitsgruenden werden Fotos, Panoramen, Modelle und Splats nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  rm -rf \"$MEDIA_HOME\""

