#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/puppeteer_install.sh"
node() { printf '%s\n' "$test_node_version"; }
npm() { :; }
for test_node_version in v18.19.1 v20.19.0 v22.11.9 invalid; do
    if check_node_tool_runtime >/dev/null 2>&1; then
        echo "FAIL: incompatible Node accepted: $test_node_version"; exit 1
    fi
done
for test_node_version in v22.12.0 v22.22.0 v24.0.0; do
    check_node_tool_runtime
done
test_node_version=v18.19.1 init_called=false
init_tool_tracking() { init_called=true; return 99; }
if install_node_tool >/dev/null 2>&1; then echo 'FAIL: installation with Node 18'; exit 1; fi
[[ "$init_called" == false ]]
test_node_version=v22.12.0
puppeteer_main --check >/dev/null
puppeteer_main --dry-run >/dev/null
[[ "$init_called" == false && "$TOOL_APT_PACKAGES" == *unzip* ]]
echo 'PASS: Node minimum, pre-install rejection, check/dry-run and unzip declaration.'
