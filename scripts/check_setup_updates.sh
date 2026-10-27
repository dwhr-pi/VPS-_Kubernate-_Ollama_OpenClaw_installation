#!/usr/bin/env bash
# Lokale Release-Pruefung, kein ungefragter main-Fetch oder Versionsvergleich mit latest.
set -Eeuo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
exec bash "$ROOT/scripts/update_setup_only.sh" --dry-run "$@"
