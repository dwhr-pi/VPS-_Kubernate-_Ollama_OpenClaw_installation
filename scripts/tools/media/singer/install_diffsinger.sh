#!/usr/bin/env bash
# Compatibility entry: pinned sources only, never automatic inference.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../../.." && pwd)"
exec bash "$ROOT/scripts/tools/diffsinger_install.sh" "$@"
