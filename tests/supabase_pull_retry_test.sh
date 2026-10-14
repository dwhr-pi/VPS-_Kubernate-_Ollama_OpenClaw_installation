#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
eval "$(sed -n '/^pull_supabase_images() (/,/^)/p' "$repo_dir/scripts/tools/supabase_install.sh")"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
counter="$temp_dir/counter"
pauses="$temp_dir/pauses"
log_error() { echo "$*" >&2; }
sleep() { echo "$1" >> "$pauses"; }
run_docker_compose() {
    [[ "$*" == '--parallel 1 pull' ]] || return 99
    local count
    count="$(< "$counter")"
    count=$((count + 1))
    echo "$count" > "$counter"
    if [[ "$count" -le "$fail_count" ]]; then echo "$error_message" >&2; return 1; fi
}
fail_count=1 error_message='read tcp: connection reset by peer'
echo 0 > "$counter"
pull_supabase_images >/dev/null
[[ "$(< "$counter")" == 2 && "$(< "$pauses")" == 5 ]]
fail_count=99
echo 0 > "$counter"
: > "$pauses"
if pull_supabase_images >/dev/null 2>&1; then exit 1; fi
[[ "$(< "$counter")" == 3 && "$(wc -l < "$pauses")" -eq 2 ]]
for error_message in 'permission denied' 'no space left on device' 'manifest unknown'; do
    echo 0 > "$counter"
    : > "$pauses"
    if pull_supabase_images >/dev/null 2>&1; then exit 1; fi
    [[ "$(< "$counter")" == 1 && ! -s "$pauses" ]]
done
fail_count=0
echo 0 > "$counter"
pull_supabase_images >/dev/null
[[ "$(< "$counter")" == 1 ]]
echo 'PASS: serial pull, bounded network retries, immediate non-network failure and successful recovery.'
