#!/usr/bin/env bash
set -euo pipefail

INSTALL_ROOT="${TRIPOSR_INSTALL_ROOT:-/opt/triposr}"

echo "TripoSR Deinstallation"
echo "Pfad: $INSTALL_ROOT"
echo "Aus Sicherheitsgruenden nicht automatisch geloescht."
echo "Manuell nach Pruefung:"
echo "  sudo rm -rf \"$INSTALL_ROOT\""

