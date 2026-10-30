#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/musicgen_install.sh"
python3.11() { return 0; }
python3() { return 1; }
MUSICGEN_PYTHON_BIN=python3
if musicgen_find_python >/dev/null 2>&1; then exit 1; fi
MUSICGEN_PYTHON_BIN=python3.11
[[ "$(musicgen_find_python)" == python3.11 ]]
test_disk=900000 test_windows=9000
snapshot_disk_mb() { echo "$test_disk"; }
snapshot_windows_host_disk_mb() { echo "$test_windows"; }
if musicgen_main --dry-run >/dev/null 2>&1; then exit 1; fi
test_windows=30000
confirm_heavy_install() {
  echo 'FAIL: unexpected install' >&2
  return 99
}
musicgen_main --check >/dev/null
musicgen_main --dry-run >/dev/null
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
mkdir -p "$temp_dir/venv/bin"
printf '#!/usr/bin/env bash\nexit 1\n' >"$temp_dir/venv/bin/python"
chmod +x "$temp_dir/venv/bin/python"
touch "$temp_dir/venv/preserved"
fake_python() {
  [[ "$1" == -m && "$2" == venv ]]
  mkdir -p "$3/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$3/bin/python"
  chmod +x "$3/bin/python"
}
musicgen_prepare_venv fake_python "$temp_dir" >/dev/null
backups=("$temp_dir"/venv-backup.*/venv/preserved)
[[ "${#backups[@]}" -eq 1 && -f "${backups[0]}" ]]
musicgen_prepare_venv fake_python "$temp_dir"
calls="$temp_dir/calls" fail_packages=false
mock_python() {
  echo "$*" >>"$calls"
  if [[ "$*" == *'audiocraft @'* && "$fail_packages" == true ]]; then return 1; fi
}
musicgen_install_packages mock_python
grep -Fq 'git+https://github.com/facebookresearch/audiocraft.git@v1.3.0' "$calls"
fail_packages=true
: >"$calls"
if musicgen_install_packages mock_python >/dev/null 2>&1; then exit 1; fi
[[ "$(wc -l <"$calls")" -eq 3 ]]
echo 'PASS: Python selection, low Windows disk rejection, dry-run, venv backup/reuse, GitHub pin and package failure.'
