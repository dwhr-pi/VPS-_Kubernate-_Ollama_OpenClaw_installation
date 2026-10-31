#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../scripts/tools/rife_install.sh
source "$repo_dir/scripts/tools/rife_install.sh"
python3.11() { return 0; }
python3() { return 1; }
RIFE_PYTHON_BIN=python3.11
[[ "$(rife_find_python)" == python3.11 ]]
RIFE_PYTHON_BIN=python3
if rife_find_python >/dev/null 2>&1; then
  echo 'FAIL: incompatible Python accepted'
  exit 1
fi
RIFE_PYTHON_BIN=python3.11
confirm_heavy_install() {
  echo 'Unexpected install prompt' >&2
  return 99
}
rife_main --check >/dev/null
rife_main --dry-run >/dev/null
temp_env="$(mktemp -d)"
trap 'rm -rf -- "$temp_env"' EXIT
mkdir -p "$temp_env/.venv/bin"
printf 'old-data\n' >"$temp_env/.venv/marker"
printf '#!/usr/bin/env bash\nexit 1\n' >"$temp_env/.venv/bin/python"
chmod +x "$temp_env/.venv/bin/python"
fake_python() {
  [[ "$1" == -m && "$2" == venv ]]
  mkdir -p "$3/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$3/bin/python"
  chmod +x "$3/bin/python"
}
rife_prepare_venv fake_python "$temp_env" >/dev/null
backups=("$temp_env"/venv-backup.*/.venv/marker)
[[ "${#backups[@]}" -eq 1 && -f "${backups[0]}" ]]
rife_python_ok "$temp_env/.venv/bin/python"
rife_prepare_venv fake_python "$temp_env"
echo 'PASS: RIFE Python rejection, non-install modes, venv backup and reuse.'

# Exercise missing-Python orchestration without downloading or building anything.
(
  unset RIFE_PYTHON_BIN
  rife_find_python() { return 1; }
  calls="$temp_env/calls"
  build_isolated_cpython311() {
    echo build >>"$calls"
    echo /mock/python3.11
  }
  rife_main --dry-run >/dev/null
  [[ ! -e "$calls" ]]
  if rife_main --check >/dev/null; then exit 1; fi
  [[ ! -e "$calls" ]]
  RIFE_PYTHON_BIN=/bad/explicit
  if rife_main --dry-run >/dev/null 2>&1; then exit 1; fi
  [[ ! -e "$calls" ]]
  unset RIFE_PYTHON_BIN
  confirm_heavy_install() { return 0; }
  begin_measurement() { :; }
  end_measurement() { echo "$1" >>"$temp_env/status"; }
  require_disk_mb() { return "$disk_rc"; }
  ensure_base_apt_packages() { return 0; }
  sudo() { return 0; }
  clone_or_update_git_target() { return 1; }
  rife_python_ok() { [[ "$1" == /mock/python3.11 ]]; }
  USER=testuser disk_rc=1
  if rife_main >/dev/null; then exit 1; fi
  [[ ! -e "$calls" ]]
  disk_rc=0
  if rife_main >/dev/null; then exit 1; fi
  [[ "$(<"$calls")" == build ]]
  grep -Fxq failed "$temp_env/status"
  echo 'PASS: missing Python plans a build, explicit override rejects, disk gate precedes mocked build.'
)
