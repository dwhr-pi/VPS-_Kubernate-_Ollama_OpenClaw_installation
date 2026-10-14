#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/puppeteer_install.sh"
runtime_ready=true installs=0 fail_install=false disk_free=100000
check_node_tool_runtime() { [[ "$runtime_ready" == true ]]; }
nvm() {
    case "$1" in
        use) [[ "$runtime_ready" == true ]] ;;
        install)
            [[ "$*" == 'install -b 22' ]] || return 99
            installs=$((installs + 1))
            [[ "$fail_install" == false ]] || return 1
            runtime_ready=true ;;
        *) return 99 ;;
    esac
}
df() { printf 'Filesystem 1M-blocks Used Available Use%% Mounted\nmock 200000 0 %s 0%% /\n' "$disk_free"; }
prepare_puppeteer_runtime
[[ "$installs" -eq 0 ]]
runtime_ready=false
puppeteer_main --dry-run >/dev/null
[[ "$runtime_ready" == false && "$installs" -eq 0 ]]
if puppeteer_main --check >/dev/null; then exit 1; fi
disk_free=100
if prepare_puppeteer_runtime >/dev/null 2>&1; then exit 1; fi
[[ "$installs" -eq 0 ]]
disk_free=100000
prepare_puppeteer_runtime >/dev/null
[[ "$runtime_ready" == true && "$installs" -eq 1 ]]
runtime_ready=false fail_install=true
if prepare_puppeteer_runtime >/dev/null 2>&1; then exit 1; fi
[[ "$runtime_ready" == false && "$installs" -eq 2 ]]
echo 'PASS: compatible runtime reused, dry-run/check do not install, low disk blocks, nvm install/failure handled.'
