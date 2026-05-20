#!/usr/bin/env bash
set -euo pipefail

INSTALL_ROOT="${HUNYUAN3D_INSTALL_ROOT:-/opt/hunyuan3d-2.1}"

echo "Hunyuan3D Deinstallation"
echo "Pfad: $INSTALL_ROOT"
echo "Aus Sicherheitsgruenden nicht automatisch geloescht, weil Modelle/Assets gross und wertvoll sein koennen."
echo "Manuell nach Pruefung:"
echo "  sudo rm -rf \"$INSTALL_ROOT\""

