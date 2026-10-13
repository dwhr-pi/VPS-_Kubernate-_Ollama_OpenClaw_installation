#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Extract just this function: sourcing the complete menu would have side effects.
eval "$(sed -n '/^sync_ollama_tool_status() {/,/^}/p' "$repo_dir/setup_ultimate.sh")"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
TOOL_STATUS_FILE="$temp_dir/installed_tools.txt"
USER_STATUS_DIR="$temp_dir/status"
mkdir -p "$USER_STATUS_DIR"
test_binary=''
command() {
    if [[ "$*" == '-v ollama' ]]; then
        [[ -n "$test_binary" ]] || return 1
        printf '%s\n' "$test_binary"
    else builtin command "$@"; fi
}
append_unique_line() { printf '%s\n' "$2" >> "$1"; }
remove_exact_line() { sed -i '\|^Ollama$|d' "$1"; }
printf 'Ollama\nOpenClaw\n' > "$TOOL_STATUS_FILE"
printf 'Ollama\n' > "$USER_STATUS_DIR/installed_tools.txt"
sync_ollama_tool_status
[[ "$OLLAMA_STATUS_CHANGED" == 1 ]]
[[ "$(< "$TOOL_STATUS_FILE")" == OpenClaw ]]
[[ ! -s "$USER_STATUS_DIR/installed_tools.txt" ]]
sync_ollama_tool_status
[[ "$OLLAMA_STATUS_CHANGED" == 0 ]]
test_binary="$temp_dir/ollama"
printf '#!/usr/bin/env bash\nexit 0\n' > "$test_binary"
chmod +x "$test_binary"
sync_ollama_tool_status
grep -Fxq Ollama "$TOOL_STATUS_FILE"
[[ "$OLLAMA_STATUS_CHANGED" == 1 ]]
sync_ollama_tool_status
[[ "$OLLAMA_STATUS_CHANGED" == 0 ]]
rm "$test_binary"
sync_ollama_tool_status
if grep -Fxq Ollama "$TOOL_STATUS_FILE"; then exit 1; fi
test_binary=ollama
sync_ollama_tool_status
if grep -Fxq Ollama "$TOOL_STATUS_FILE"; then exit 1; fi
echo 'PASS: stale and mirrored status removed; binary detection, idempotence and missing executable.'
