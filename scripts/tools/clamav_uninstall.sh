#!/usr/bin/env bash
set -euo pipefail

echo "Deinstalliere ClamAV-Pakete. Benutzer-Quarantaene bleibt erhalten."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get remove -y clamav clamav-daemon || true
else
    echo "Hinweis: Kein apt-get gefunden. Bitte ClamAV manuell ueber den Paketmanager entfernen."
fi
