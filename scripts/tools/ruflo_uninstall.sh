#!/usr/bin/env bash
# Deinstalliert Ruflo/claude-flow aus dem lokalen Setup, ohne Node.js/pnpm global zu entfernen.

set -euo pipefail

RUFLO_DIR="${RUFLO_DIR:-/opt/ruflo}"

run_sudo() {
    if [ "${EUID}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

echo "Starte Deinstallation von Ruflo..."

if [ -L /usr/local/bin/ruflo ] || [ -e /usr/local/bin/ruflo ]; then
    run_sudo rm -f /usr/local/bin/ruflo
    echo "CLI-Link /usr/local/bin/ruflo entfernt."
fi

if [ -L /usr/local/bin/claude-flow ] || [ -e /usr/local/bin/claude-flow ]; then
    run_sudo rm -f /usr/local/bin/claude-flow
    echo "CLI-Link /usr/local/bin/claude-flow entfernt."
fi

if [ -d "$RUFLO_DIR" ]; then
    run_sudo rm -rf "$RUFLO_DIR"
    echo "Ruflo-Verzeichnis entfernt: $RUFLO_DIR"
else
    echo "Kein Ruflo-Verzeichnis gefunden: $RUFLO_DIR"
fi

echo "Ruflo wurde deinstalliert. Node.js, pnpm/Corepack und gemeinsame Paket-Caches bleiben erhalten, weil sie auch von anderen Tools genutzt werden koennen."
