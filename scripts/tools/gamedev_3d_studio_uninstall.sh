#!/usr/bin/env bash
set -euo pipefail

GAMEDEV_HOME="${GAMEDEV_HOME:-$HOME/Ultimate_KI_Setup/gamedev_3d_studio}"

echo "GameDev 3D Studio NEXTLEVEL Deinstallation"
echo "Projektordner: $GAMEDEV_HOME"
echo "Godot-Repositories, Projekte, Assets, NPC-Memory, Builds und Backups werden nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  rm -rf \"$GAMEDEV_HOME\""
