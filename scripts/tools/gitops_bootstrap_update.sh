#!/usr/bin/env bash
# Quellen: https://github.com/k3s-io/k3s und gepruefte Artefakt-Lockdatei.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
exec bash "$ROOT/scripts/bootstrap_gitops.sh" "$@"
