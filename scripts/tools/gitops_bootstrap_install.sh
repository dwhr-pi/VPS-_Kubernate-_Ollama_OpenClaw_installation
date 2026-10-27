#!/usr/bin/env bash
# Quellen: https://github.com/k3s-io/k3s und gepruefte Artefakt-Lockdatei.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../.." && pwd)"
if (($# == 0)); then
  printf '%s\n' 'Bewusster Infrastruktur-Bootstrap: zuerst --plan --artifacts ABS --private-address IP. Apply nur als root mit separaten Freigaben. Anleitung: docs/GITOPS_SMALL_VPS.md.' >&2
  exit 2
fi
exec bash "$ROOT/scripts/bootstrap_gitops.sh" "$@"
