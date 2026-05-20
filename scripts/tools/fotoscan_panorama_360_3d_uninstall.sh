#!/usr/bin/env bash
set -euo pipefail

MEDIA_HOME="${FOTOSCAN_MEDIA_HOME:-$HOME/KI-Media}"

echo "FotoScan Panorama 360 3D Tool-Deinstallation"
echo "Datenordner: $MEDIA_HOME"
echo "Fotos/Outputs werden nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  rm -rf \"$MEDIA_HOME\""

