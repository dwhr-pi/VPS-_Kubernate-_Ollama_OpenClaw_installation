#!/usr/bin/env bash
set -euo pipefail

echo "Installiere YARA fuer lokale defensive Regel-Scans..."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y yara
else
    echo "Fehler: Automatische YARA-Installation ist derzeit nur fuer apt-basierte Systeme vorbereitet."
    exit 1
fi

mkdir -p "$HOME/.openclaw_ultimate_user_data/security/yara_rules"
echo "YARA installiert. Lokale Regeln: ~/.openclaw_ultimate_user_data/security/yara_rules"
