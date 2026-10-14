#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
eval "$(sed -n '/^start_supabase_stack() {/,/^TOOL_POST_INSTALL_FUNCTION=/p' "$repo_dir/scripts/tools/supabase_install.sh" | sed '$d')"
TOOL_DIR=/opt/supabase
log_error() { :; }
ensure_docker_compose_available() { return 0; }
cd() { :; }
cp() { echo copied-template; }
chmod() { [[ "$*" == '600 .env' ]]; }
pull_supabase_images() { return 0; }
run_docker_compose() { [[ "$*" == 'up -d --pull never' ]]; echo compose-wrapper; return "$compose_result"; }
function [ {
    if [[ "$1" == '!' ]]; then
        shift
        if [ "$@"; then return 1; else return 0; fi
    fi
    if [[ "$1" == -d ]]; then return 0; fi
    if [[ "$1" == -f && "$2" == .env ]]; then return "$env_missing"; fi
    if [[ "$1" == -f && "$2" == .env.example ]]; then return 0; fi
    builtin [ "$@"
}
env_missing=0 compose_result=0
output="$(start_supabase_stack)"
[[ "$output" == compose-wrapper ]]
env_missing=1
output="$(start_supabase_stack)"
[[ "$output" == *copied-template* && "$output" == *compose-wrapper* ]]
compose_result=1
if start_supabase_stack >/dev/null; then echo 'FAIL: Compose error accepted'; exit 1; fi
echo 'PASS: Supabase uses Compose wrapper, preserves existing env and propagates errors.'
