#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/opentelemetry_install.sh"
USER=tester
linux_mb=4000 test_windows_mb=6800
snapshot_disk_mb() { echo "$linux_mb"; }
snapshot_windows_host_disk_mb() { echo "$test_windows_mb"; }
if check_opentelemetry_disk >/dev/null 2>&1; then exit 1; fi
test_windows_mb=20000
check_opentelemetry_disk
linux_mb=1000
if check_opentelemetry_disk >/dev/null 2>&1; then exit 1; fi
linux_mb=4000 test_windows_mb=''
check_opentelemetry_disk

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
calls="$temp_dir/calls"
direct_access=1 sudo_access=0 compose_rc=0 config_rc=0
docker() {
    if [[ "$1" == info ]]; then return "$direct_access"; fi
    [[ "$*" == 'compose version' ]] && return 0
    echo "direct $*" >> "$calls"
    return "$compose_rc"
}
sudo() {
    [[ "$1" == docker ]] || return 99
    shift
    [[ "$1" == info ]] && return "$sudo_access"
    [[ "$*" == 'compose version' ]] && return 0
    echo "sudo $*" >> "$calls"
    [[ "$*" == *'config --quiet' ]] && return "$config_rc"
    return "$compose_rc"
}
mark_current_tool_installed() { echo marked >> "$calls"; }
start_opentelemetry_stack /mock/compose.yml >/dev/null
grep -Fq 'sudo compose -f /mock/compose.yml up -d' "$calls"
grep -Fxq marked "$calls"
: > "$calls"
compose_rc=1
if start_opentelemetry_stack /mock/compose.yml >/dev/null 2>&1; then exit 1; fi
if grep -Fxq marked "$calls"; then exit 1; fi
: > "$calls"
compose_rc=0 config_rc=1
if start_opentelemetry_stack /mock/compose.yml >/dev/null 2>&1; then exit 1; fi
[[ "$(wc -l < "$calls")" -eq 1 ]]
config_rc=0 sudo_access=1
if start_opentelemetry_stack /mock/compose.yml >/dev/null 2>&1; then exit 1; fi
direct_access=0
run_docker_compose_tool -f /mock/compose.yml up -d >/dev/null
grep -Fq 'direct compose -f /mock/compose.yml up -d' "$calls"
: > "$calls"
install_opentelemetry --check >/dev/null
install_opentelemetry --dry-run >/dev/null
[[ ! -s "$calls" ]]
grep -Fq '127.0.0.1:4317:4317' "$repo_dir/scripts/tools/opentelemetry_install.sh"
grep -Fq '127.0.0.1:4318:4318' "$repo_dir/scripts/tools/opentelemetry_install.sh"
echo 'PASS: disk protection, direct/sudo Compose, error propagation, no false marking, read-only preflight.'
