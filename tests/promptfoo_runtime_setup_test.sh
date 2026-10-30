#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/promptfoo_install.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
OPENCLAW_USER_DATA_DIR="$temp_dir"
ready=false runtime_calls=0 npm_calls=0 disk_rc=0 npm_rc=0
check_promptfoo_runtime() { [[ "$ready" == true ]]; }
ensure_node_tool_runtime() {
  runtime_calls=$((runtime_calls + 1))
  return 0
}
check_node_runtime_disk() { return "$disk_rc"; }
npm() {
  [[ "$*" == "install --prefix $temp_dir/runtimes/promptfoo-npm-11.11.0 --no-save --package-lock=false --ignore-scripts npm@11.11.0" ]] || return 99
  npm_calls=$((npm_calls + 1))
  [[ "$npm_rc" == 0 ]] || return 1
  ready=true
}
promptfoo_main --dry-run >/dev/null
[[ "$runtime_calls" == 0 && "$npm_calls" == 0 ]]
disk_rc=1
if prepare_promptfoo_runtime >/dev/null; then exit 1; fi
[[ "$npm_calls" == 0 ]]
disk_rc=0
prepare_promptfoo_runtime >/dev/null
[[ "$npm_calls" == 1 && "$ready" == true ]]
[[ "$PATH" == "$temp_dir/runtimes/promptfoo-npm-11.11.0/node_modules/.bin:"* ]]
prepare_promptfoo_runtime >/dev/null
[[ "$npm_calls" == 1 ]]
ready=false npm_rc=1
if prepare_promptfoo_runtime >/dev/null 2>&1; then exit 1; fi
[[ "$npm_calls" == 2 && "$ready" == false ]]
echo 'PASS: dry-run, runtime reuse, disk gate, private npm pin/PATH and failed install propagation.'
