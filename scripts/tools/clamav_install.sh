#!/usr/bin/env bash
set -euo pipefail

echo "Installiere ClamAV fuer lokale defensive Datei-Scans..."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y clamav clamav-daemon
    if command -v freshclam >/dev/null 2>&1; then
        sudo freshclam || echo "Hinweis: freshclam konnte Signaturen gerade nicht aktualisieren. Bitte spaeter erneut ausfuehren."
    fi
else
    echo "Fehler: Automatische ClamAV-Installation ist derzeit nur fuer apt-basierte Systeme vorbereitet."
    exit 1
fi

mkdir -p "$HOME/.openclaw_ultimate_user_data/security/quarantine"
echo "ClamAV installiert. Quarantaene: ~/.openclaw_ultimate_user_data/security/quarantine"
