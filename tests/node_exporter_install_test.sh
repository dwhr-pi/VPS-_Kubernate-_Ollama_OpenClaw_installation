#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/node_exporter_install.sh"
unset NODE_EXPORTER_MOUNT_PROPAGATION
compose="$(node_exporter_main --dry-run)"
[[ "$compose" == *'/:/host:ro,rprivate'* ]]
[[ "$compose" == *'--web.listen-address=127.0.0.1:9100'* ]]
[[ "$compose" != *rslave* && "$compose" != *privileged* ]]
NODE_EXPORTER_MOUNT_PROPAGATION=rslave
[[ "$(node_exporter_compose)" == *'/:/host:ro,rslave'* ]]
NODE_EXPORTER_MOUNT_PROPAGATION=invalid
if node_exporter_main --dry-run >/dev/null 2>&1; then exit 1; fi
unset NODE_EXPORTER_MOUNT_PROPAGATION
install_git_docker_tool() {
    [[ "$1" == Node_Exporter && "$2" == https://github.com/prometheus/node_exporter.git ]]
    [[ "$3" == /opt/node_exporter && "$4" == *'/:/host:ro,rprivate'* ]]
    return 17
}
if node_exporter_main >/dev/null; then exit 1; else [[ "$?" -eq 17 ]]; fi
echo 'PASS: private/read-only mount, loopback listener, opt-in, dry-run and failure propagation.'
