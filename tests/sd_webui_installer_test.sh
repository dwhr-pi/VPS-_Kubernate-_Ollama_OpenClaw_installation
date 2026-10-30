#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
eval "$(sed -n '/^sd_webui_python_ok() {/,/^if \[\[/p' "$repo_dir/scripts/tools/stable_diffusion_webui_install.sh" | sed '$d')"
log_info() { :; }
log_error() { :; }
python3.10() { return 1; }
python3.11() { return 0; }
python3() { return 1; }
SD_WEBUI_PYTHON_BIN=python3.11
[[ "$(sd_webui_find_python)" == python3.11 ]]
SD_WEBUI_PYTHON_BIN=python3
if sd_webui_find_python; then
  echo 'FAIL: Python 3.12 accepted'
  exit 1
fi
SD_WEBUI_PYTHON_BIN=python3.11
begin_measurement() {
  echo 'Unexpected installation' >&2
  return 99
}
sd_webui_main --check
sd_webui_main --dry-run
TOOL_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TOOL_DIR"' EXIT
mkdir -p "$TOOL_DIR/venv/bin"
printf 'old-environment\n' >"$TOOL_DIR/venv/marker"
printf '#!/usr/bin/env bash\nexit 1\n' >"$TOOL_DIR/venv/bin/python"
chmod +x "$TOOL_DIR/venv/bin/python"
fake_python() {
  [[ "$1" == -m && "$2" == venv ]]
  mkdir -p "$3/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$3/bin/python"
  chmod +x "$3/bin/python"
}
sd_webui_prepare_venv fake_python
backups=("$TOOL_DIR"/venv-backup.*/venv/marker)
[[ "${#backups[@]}" -eq 1 && -f "${backups[0]}" ]]
sd_webui_python_ok "$TOOL_DIR/venv/bin/python"
sd_webui_prepare_venv fake_python
backups=("$TOOL_DIR"/venv-backup.*/venv/marker)
[[ "${#backups[@]}" -eq 1 ]]
echo 'PASS: Python rejection, dry-run, preserved old venv and environment reuse.'
