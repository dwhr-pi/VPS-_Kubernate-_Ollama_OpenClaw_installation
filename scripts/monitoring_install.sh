#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
# Ohne --render oder --apply erfolgt ausschliesslich ein Offline-Plan.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 -I -B "$ROOT/scripts/lib/platform_helm.py" monitoring "$@"
