#!/usr/bin/env bash
# Expliziter Setup-Schritt: kein source/eval und keine automatische Secret-Nutzung.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
exec "${SOPS_ENV_PYTHON_BIN:-python3}" -I -B "$ROOT/scripts/security/decrypt_sops_env.py" "$@"
