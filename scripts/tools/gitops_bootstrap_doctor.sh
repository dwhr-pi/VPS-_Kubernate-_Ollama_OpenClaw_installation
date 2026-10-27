#!/usr/bin/env bash
set -euo pipefail
exec bash "${BASH_SOURCE[0]%/*}/gitops_bootstrap_check.sh" "$@"
