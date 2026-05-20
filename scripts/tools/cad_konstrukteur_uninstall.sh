#!/usr/bin/env bash
set -euo pipefail

CAD_HOME="${CAD_HOME:-$HOME/.openclaw_ultimate_user_data/cad_konstrukteur}"

echo "CAD_Konstrukteur nutzt Benutzerdateien unter: $CAD_HOME"
echo "Aus Sicherheitsgruenden werden keine CAD-Projekte automatisch geloescht."
echo "Zum bewussten Entfernen der venv/Logs:"
echo "  CAD_REMOVE_USER_DATA=1 bash scripts/tools/cad_konstrukteur_uninstall.sh"

if [ "${CAD_REMOVE_USER_DATA:-0}" = "1" ]; then
    rm -rf "$CAD_HOME"
    echo "CAD_Konstrukteur-Benutzerdaten wurden entfernt."
else
    echo "Keine Daten geloescht."
fi
