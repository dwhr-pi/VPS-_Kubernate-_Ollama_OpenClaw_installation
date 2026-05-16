#!/usr/bin/env bash
set -euo pipefail

echo "Deinstalliere YARA. Lokale Regeln bleiben erhalten."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get remove -y yara || true
else
    echo "Hinweis: Kein apt-get gefunden. Bitte YARA manuell ueber den Paketmanager entfernen."
fi
