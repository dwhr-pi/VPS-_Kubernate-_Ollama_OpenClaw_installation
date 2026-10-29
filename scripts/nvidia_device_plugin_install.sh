#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
# Host-Treiber und K3s-Runtime werden ausdruecklich nicht installiert.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 -I -B "$ROOT/scripts/lib/platform_helm.py" nvidia "$@"
