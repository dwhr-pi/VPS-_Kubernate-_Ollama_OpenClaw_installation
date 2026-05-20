#!/usr/bin/env bash
set -euo pipefail

GAMEDEV_HOME="${GAMEDEV_HOME:-$HOME/Ultimate_KI_Setup/gamedev_3d_studio}"

echo "GameDev 3D Studio liegt unter: $GAMEDEV_HOME"
echo "Aus Sicherheitsgruenden loescht dieses Skript keine Projekte automatisch."
echo "Zum vollstaendigen Entfernen bewusst ausfuehren:"
echo "  rm -rf \"$GAMEDEV_HOME\""

if [ "${GAMEDEV_REMOVE_ALL:-0}" = "1" ]; then
    rm -rf "$GAMEDEV_HOME"
    echo "GameDev 3D Studio Daten wurden entfernt."
else
    echo "Keine Daten geloescht. Setze GAMEDEV_REMOVE_ALL=1 fuer bewusste Entfernung."
fi
