#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/stable_diffusion_webui_forge_install.sh"
python3.10() { return 1; }
python3.11() { return 0; }
python3() { return 1; }
FORGE_PYTHON_BIN=python3.11
[[ "$(forge_find_python)" == python3.11 ]]
FORGE_PYTHON_BIN=python3
if forge_find_python >/dev/null 2>&1; then
  echo 'FAIL: incompatible explicit Python accepted'
  exit 1
fi
unset FORGE_PYTHON_BIN
[[ "$(forge_find_python)" == python3.11 ]]
begin_measurement() {
  echo 'Unexpected installation started' >&2
  return 99
}
sudo() {
  echo 'Unexpected sudo' >&2
  return 99
}
FORGE_PYTHON_BIN=python3.11
forge_main --check >/dev/null
forge_main --dry-run >/dev/null
FORGE_PYTHON_BIN=python3
if forge_main >/dev/null 2>&1; then
  echo 'FAIL: incompatible Python allowed installation'
  exit 1
fi
echo 'PASS: Python selection, explicit rejection and check/dry-run without installation.'
