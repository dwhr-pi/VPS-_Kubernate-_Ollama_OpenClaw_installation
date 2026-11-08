#!/usr/bin/env bash
# Explicit private compiler prerequisite; no application, service or system install.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
exec "${GAP_TOOLS_PYTHON_BIN:-python3}" -I -B -c \
  'import runpy, sys; sys.path.insert(0, sys.argv.pop(1)); runpy.run_module("cargo_build_tools", run_name="__main__")' \
  "$ROOT/scripts/tools/helpers" "$@"
