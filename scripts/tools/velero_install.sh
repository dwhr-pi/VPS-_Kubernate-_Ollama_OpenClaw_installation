#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
begin_measurement "tool_install_Velero" "Tool installieren: Velero"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
curl -fsSL "https://github.com/vmware-tanzu/velero/releases/latest/download/velero-linux-amd64.tar.gz" -o "$tmp_dir/velero.tgz"
tar -xzf "$tmp_dir/velero.tgz" -C "$tmp_dir"
sudo install -m 0755 "$(find "$tmp_dir" -type f -name velero | head -n 1)" /usr/local/bin/velero
mark_tool_installed "Velero"
end_measurement "success"
