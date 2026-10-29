#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
# Rollback bleibt beim vorhandenen, pfad- und eigentuemerpruefenden Runner.
# Keine pauschale ERR-Bereinigung: vorhandene Workspaces bleiben erhalten.
if ! command -v python3 >/dev/null 2>&1; then
    printf 'Fehler: python3 fehlt; keine Installation gestartet.\n' >&2
    exit 127
fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec python3 -I -B "$ROOT/scripts/lib/install_rollback.py" "$@"
