#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Actionlint" "Tool installieren: Actionlint"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
curl -fsSL "https://github.com/rhysd/actionlint/releases/latest/download/actionlint_linux_amd64.tar.gz" -o "$tmp_dir/actionlint.tgz"
tar -xzf "$tmp_dir/actionlint.tgz" -C "$tmp_dir"
sudo install -m 0755 "$tmp_dir/actionlint" /usr/local/bin/actionlint
mark_tool_installed "Actionlint"
end_measurement "success"
