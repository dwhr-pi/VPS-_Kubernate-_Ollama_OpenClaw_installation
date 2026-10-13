#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Extract only the resource functions: never source the executable installer.
eval "$(sed -n '/^is_wsl_for_autogpt() {/,/^docker_info_available_for_autogpt() {/p' "$repo_dir/scripts/tools/autogpt_install.sh" | sed '$d')"
GREEN='' BLUE='' RED='' YELLOW='' NC=''
AUTOGPT_DIR=/unused
AUTOGPT_MIN_LINUX_DISK_MB=40960
AUTOGPT_MIN_WINDOWS_C_MB=51200
AUTOGPT_MIN_RAM_SWAP_MB=8192
AUTOGPT_RECOMMENDED_RAM_SWAP_MB=12288
AUTOGPT_SKIP_RESOURCE_PREFLIGHT=0

is_wsl_for_autogpt() { return 0; }
get_available_mb_for_path() { echo 974926; }
get_windows_c_free_mb_for_autogpt() { echo "$test_disk_mb"; }
get_ram_swap_available_mb_for_autogpt() { echo "$test_memory_mb"; }
get_docker_root_dir_for_autogpt() { echo 'Unexpected Docker call' >&2; return 99; }
docker() { echo 'Unexpected Docker call' >&2; return 99; }
sudo() { echo 'Unexpected sudo call' >&2; return 99; }

test_disk_mb=39019 test_memory_mb=4315
if output="$(check_autogpt_resource_preflight host 2>&1)"; then
    echo 'FAIL: resource shortage accepted'; exit 1
fi
[[ "$output" == *'12181 MB'* && "$output" == *'3877 MB'* ]]
[[ "$output" != *'Unexpected'* ]]

test_disk_mb=60000 test_memory_mb=4315
if check_autogpt_resource_preflight host >/dev/null; then
    echo 'FAIL: insufficient memory accepted'; exit 1
fi
test_disk_mb=39019 test_memory_mb=16000
if check_autogpt_resource_preflight host >/dev/null; then
    echo 'FAIL: insufficient disk accepted'; exit 1
fi
test_disk_mb=60000 test_memory_mb=16000
output="$(check_autogpt_resource_preflight host 2>&1)"
[[ "$output" != *'Unexpected'* ]]
echo 'PASS: host preflight rejects low disk/RAM and runs without Docker/sudo.'
