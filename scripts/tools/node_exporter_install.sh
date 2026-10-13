#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
node_exporter_compose() {
    local propagation="${NODE_EXPORTER_MOUNT_PROPAGATION:-rprivate}"
    case "$propagation" in rprivate|rslave) ;; *)
        echo 'Fehler: NODE_EXPORTER_MOUNT_PROPAGATION muss rprivate oder rslave sein.' >&2
        return 2 ;;
    esac
    cat <<EOF
services:
  node-exporter:
    image: prom/node-exporter:latest
    network_mode: host
    restart: unless-stopped
    pid: host
    volumes:
      - /:/host:ro,${propagation}
    command:
      - --path.rootfs=/host
      - --web.listen-address=127.0.0.1:9100
EOF
}

node_exporter_main() {
    local compose mode="${1:-install}"
    case "$mode" in install|--dry-run) ;; *) echo 'Aufruf: node_exporter_install.sh [--dry-run]' >&2; return 2 ;; esac
    compose="$(node_exporter_compose)" || return $?
    if [[ "$mode" == --dry-run ]]; then
        printf '%s\n' "$compose"
        return 0
    fi
    echo 'Node Exporter: read-only Root-Mount; localhost:9100. Keine Aenderung der Host-Mount-Propagation.'
    echo 'Docker/WSL-Metriken beziehen sich auf den Docker-Daemon-Host, nicht zwingend auf Windows oder diese WSL-Distro.'
    install_git_docker_tool "Node_Exporter" "https://github.com/prometheus/node_exporter.git" "/opt/node_exporter" "$compose"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    node_exporter_main "$@"
fi
