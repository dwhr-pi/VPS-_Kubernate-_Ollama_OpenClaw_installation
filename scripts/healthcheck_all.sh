#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
printf '%s\n' 'Hinweis: Kompatibilitaetspfad; Diagnose ist offline, Runtime nur mit --runtime --require NAME.' >&2
exec python3 -I -B "$ROOT_DIR/scripts/operations/platform_health.py" doctor "$@"
