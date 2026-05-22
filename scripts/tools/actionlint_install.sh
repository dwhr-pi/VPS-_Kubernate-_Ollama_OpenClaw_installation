#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib/common.sh"

ACTIONLINT_DIR="${ACTIONLINT_DIR:-/opt/actionlint}"
ACTIONLINT_REPO_URL="${ACTIONLINT_REPO_URL:-https://github.com/rhysd/actionlint.git}"

begin_measurement "tool_install_Actionlint" "Tool installieren: Actionlint"

echo "Starte Installation von Actionlint aus GitHub-Quelle..."
echo "Primaerquelle: $ACTIONLINT_REPO_URL"
ensure_base_apt_packages git golang-go build-essential ca-certificates

sudo mkdir -p "$(dirname "$ACTIONLINT_DIR")"
sudo chown -R "$USER:$USER" "$(dirname "$ACTIONLINT_DIR")"

if [ -d "$ACTIONLINT_DIR/.git" ]; then
    echo "Actionlint Repository existiert bereits unter $ACTIONLINT_DIR. Aktualisiere Repository..."
    git -C "$ACTIONLINT_DIR" pull --ff-only || {
        echo "Warnung: Git-Update war nicht moeglich. Vorhandene lokale Kopie wird verwendet."
    }
elif [ -e "$ACTIONLINT_DIR" ] && [ "$(find "$ACTIONLINT_DIR" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "Fehler: $ACTIONLINT_DIR existiert, ist aber kein leeres Git-Repository."
    echo "Bitte Verzeichnis pruefen oder Actionlint vorher deinstallieren."
    end_measurement "failed"
    exit 1
else
    rm -rf "$ACTIONLINT_DIR"
    git clone "$ACTIONLINT_REPO_URL" "$ACTIONLINT_DIR"
fi

cd "$ACTIONLINT_DIR"
echo "Baue Actionlint CLI..."
if ! go build -o actionlint ./cmd/actionlint; then
    echo "Hinweis: ./cmd/actionlint konnte nicht gebaut werden, versuche Root-Package..."
    go build -o actionlint .
fi

sudo install -m 0755 "$ACTIONLINT_DIR/actionlint" /usr/local/bin/actionlint
actionlint --version || true

mark_tool_installed "Actionlint"
end_measurement "success"
