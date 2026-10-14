#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/node_exporter_install.sh"
unset NODE_EXPORTER_MOUNT_PROPAGATION NODE_EXPORTER_MOUNT_MODE
compose="$(node_exporter_main --dry-run)"
[[ "$compose" == *'/proc:/host/proc:ro'* && "$compose" == *'/sys:/host/sys:ro'* ]]
[[ "$compose" != *'/:/host:'* && "$compose" != *'--path.rootfs'* ]]
[[ "$compose" == *'--collector.disable-defaults'* && "$compose" != *'--collector.filesystem'* ]]
[[ "$compose" == *'--web.listen-address=127.0.0.1:9100'* ]]
[[ "$compose" != *rslave* && "$compose" != *privileged* ]]
NODE_EXPORTER_MOUNT_PROPAGATION=rslave
if node_exporter_compose >/dev/null 2>&1; then exit 1; fi
NODE_EXPORTER_MOUNT_MODE=root
[[ "$(node_exporter_compose)" == *'/:/host:ro,rslave'* ]]
NODE_EXPORTER_MOUNT_PROPAGATION=invalid
if node_exporter_main --dry-run >/dev/null 2>&1; then exit 1; fi
NODE_EXPORTER_MOUNT_PROPAGATION=rprivate
if node_exporter_main --dry-run >/dev/null 2>&1; then exit 1; fi
unset NODE_EXPORTER_MOUNT_PROPAGATION
NODE_EXPORTER_MOUNT_MODE=invalid
if node_exporter_main --dry-run >/dev/null 2>&1; then exit 1; fi
unset NODE_EXPORTER_MOUNT_MODE
install_git_docker_tool() {
    [[ "$1" == Node_Exporter && "$2" == https://github.com/prometheus/node_exporter.git ]]
    [[ "$3" == /opt/node_exporter && "$4" == *'/proc:/host/proc:ro'* && "$4" != *'/:/host:'* ]]
    return 17
}
if node_exporter_main >/dev/null; then exit 1; else [[ "$?" -eq 17 ]]; fi
echo 'PASS: no default root mount, limited collectors, loopback, explicit root opt-in, obsolete modes rejected.'
