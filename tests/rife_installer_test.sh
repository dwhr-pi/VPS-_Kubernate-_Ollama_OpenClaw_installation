#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/rife_install.sh"
python3.11() { return 0; }
python3() { return 1; }
RIFE_PYTHON_BIN=python3.11
[[ "$(rife_find_python)" == python3.11 ]]
RIFE_PYTHON_BIN=python3
if rife_find_python >/dev/null 2>&1; then echo 'FAIL: incompatible Python accepted'; exit 1; fi
RIFE_PYTHON_BIN=python3.11
confirm_heavy_install() { echo 'Unexpected install prompt' >&2; return 99; }
rife_main --check >/dev/null
rife_main --dry-run >/dev/null
temp_env="$(mktemp -d)"
trap 'rm -rf -- "$temp_env"' EXIT
mkdir -p "$temp_env/.venv/bin"
printf 'old-data\n' > "$temp_env/.venv/marker"
printf '#!/usr/bin/env bash\nexit 1\n' > "$temp_env/.venv/bin/python"
chmod +x "$temp_env/.venv/bin/python"
fake_python() {
  [[ "$1" == -m && "$2" == venv ]]
  mkdir -p "$3/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$3/bin/python"
  chmod +x "$3/bin/python"
}
rife_prepare_venv fake_python "$temp_env" >/dev/null
backups=("$temp_env"/venv-backup.*/.venv/marker)
[[ "${#backups[@]}" -eq 1 && -f "${backups[0]}" ]]
rife_python_ok "$temp_env/.venv/bin/python"
rife_prepare_venv fake_python "$temp_env"
echo 'PASS: RIFE Python rejection, non-install modes, venv backup and reuse.'
