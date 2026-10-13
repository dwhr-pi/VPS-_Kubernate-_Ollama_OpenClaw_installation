#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
eval "$(sed -n '/^airbyte_confirm_heavy_install() {/,/^airbyte_docker_cmd() {/p' "$repo_dir/scripts/tools/airbyte_install.sh" | sed '$d')"
log_warn() { :; }
log_info() { echo "$*"; }
log_error() { echo "$*"; }
get_free_mb_for_path() { echo "$test_linux_mb"; }
get_windows_host_free_mb() { echo "$test_windows_mb"; }
get_mem_available_mb() { echo "$test_ram_mb"; }
AIRBYTE_MIN_FREE_MB=32768 AIRBYTE_RECOMMENDED_FREE_MB=65536
AIRBYTE_MIN_WINDOWS_FREE_MB=20480
AIRBYTE_MIN_MEMORY_MB=8192 AIRBYTE_RECOMMENDED_MEMORY_MB=12288
test_linux_mb=976369 test_windows_mb=40890 test_ram_mb=3356
if output="$(airbyte_confirm_heavy_install)"; then echo 'FAIL: low RAM accepted'; exit 1; fi
[[ "$output" == *'4836 MB'* ]]
test_ram_mb=12288
airbyte_confirm_heavy_install >/dev/null
test_windows_mb=1000
if airbyte_confirm_heavy_install >/dev/null; then echo 'FAIL: low host disk accepted'; exit 1; fi
test_windows_mb=40890 test_linux_mb=1000
if airbyte_confirm_heavy_install >/dev/null; then echo 'FAIL: low Linux disk accepted'; exit 1; fi
echo 'PASS: Airbyte RAM and Linux/Windows disk guards checked.'
