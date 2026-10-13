#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/promptfoo_install.sh"
test_node=v22.22.0 test_npm=11.11.0
node() {
    if [[ "$1" == --version ]]; then printf '%s\n' "$test_node";
    else echo smoke >> "$calls"; return "$smoke_rc"; fi
}
npm() {
    if [[ "$1" == --version ]]; then printf '%s\n' "$test_npm"; return; fi
    echo "$*" >> "$calls"
    case "$1" in ci) return "$ci_rc" ;; run) return "$build_rc" ;; *) return 99 ;; esac
}
init_tool_tracking() { echo 'FAIL: tracking/installation reached during preflight' >&2; return 99; }
for test_node in v18.19.1 v22.21.0 invalid; do
    if promptfoo_main --check >/dev/null 2>&1; then exit 1; fi
done
test_node=v22.22.0
for test_npm in 9.2.0 10.9.0 11.6.2 12.0.0 invalid; do
    if promptfoo_main --dry-run >/dev/null 2>&1; then exit 1; fi
done
test_npm=11.11.0
promptfoo_main --check >/dev/null
promptfoo_main --dry-run >/dev/null
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
TOOL_DIR="$temp_dir"
touch "$temp_dir/package.json" "$temp_dir/package-lock.json"
calls="$temp_dir/calls" ci_rc=1 build_rc=0 smoke_rc=0
if build_promptfoo_from_source >/dev/null 2>&1; then exit 1; fi
[[ "$(wc -l < "$calls")" -eq 1 ]]
ci_rc=0 build_rc=1
: > "$calls"
if build_promptfoo_from_source >/dev/null 2>&1; then exit 1; fi
[[ "$(wc -l < "$calls")" -eq 2 ]]
build_rc=0 smoke_rc=1
if build_promptfoo_from_source >/dev/null 2>&1; then exit 1; fi
smoke_rc=0
: > "$calls"
build_promptfoo_from_source
[[ "$(wc -l < "$calls")" -eq 3 ]]
grep -Fxq 'ci --engine-strict' "$calls"
grep -Fxq 'run build' "$calls"
rm "$temp_dir/package-lock.json"
: > "$calls"
if build_promptfoo_from_source >/dev/null 2>&1; then exit 1; fi
[[ ! -s "$calls" ]]
echo 'PASS: Runtime rejection, read-only preflight, lockfile, ci/build/smoke failure propagation.'
