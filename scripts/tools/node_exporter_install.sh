#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
node_exporter_compose() {
    local mount_mode="${NODE_EXPORTER_MOUNT_MODE:-limited}"
    case "$mount_mode" in limited|root) ;; *)
        echo 'Fehler: NODE_EXPORTER_MOUNT_MODE muss limited oder root sein.' >&2
        return 2 ;;
    esac
    if [[ -n "${NODE_EXPORTER_MOUNT_PROPAGATION:-}" && "${NODE_EXPORTER_MOUNT_PROPAGATION}" != rslave ]]; then
        echo 'Fehler: rprivate fuer Root-Mounts wird nicht mehr unterstuetzt. Standard limited verwenden oder root mit rslave bewusst waehlen.' >&2
        return 2
    fi
    if [[ -n "${NODE_EXPORTER_MOUNT_PROPAGATION:-}" && "$mount_mode" != root ]]; then
        echo 'Fehler: Fuer Root-Mount ausdruecklich NODE_EXPORTER_MOUNT_MODE=root setzen.' >&2; return 2
    fi
    cat <<EOF
services:
  node-exporter:
    image: prom/node-exporter:latest
    network_mode: host
    restart: unless-stopped
    pid: host
EOF
    if [[ "$mount_mode" == root ]]; then
        cat <<EOF
    volumes:
      - /:/host:ro,rslave
    command:
      - --path.rootfs=/host
      - --web.listen-address=127.0.0.1:9100
EOF
    else
        cat <<EOF
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
    command:
      - --path.procfs=/host/proc
      - --path.sysfs=/host/sys
      - --collector.disable-defaults
      - --collector.cpu
      - --collector.meminfo
      - --collector.loadavg
      - --collector.stat
      - --collector.vmstat
      - --collector.netdev
      - --collector.netstat
      - --collector.diskstats
      - --web.listen-address=127.0.0.1:9100
EOF
    fi
}

node_exporter_main() {
    local compose mode="${1:-install}"
    case "$mode" in install|--dry-run) ;; *) echo 'Aufruf: node_exporter_install.sh [--dry-run]' >&2; return 2 ;; esac
    compose="$(node_exporter_compose)" || return $?
    if [[ "$mode" == --dry-run ]]; then
        printf '%s\n' "$compose"
        return 0
    fi
    echo "Node Exporter: Mount-Profil ${NODE_EXPORTER_MOUNT_MODE:-limited}; localhost:9100. Keine Aenderung der Host-Mount-Propagation."
    if [[ "${NODE_EXPORTER_MOUNT_MODE:-limited}" == limited ]]; then
        echo 'Eingeschraenkte Host-Metriken aus /proc und /sys; keine Dateisystem-Kapazitaeten. Kein Root-Mount.'
    else
        echo 'Root-Mount mit rslave: nur fuer kompatible Hosts; kein automatischer Mount-Umbau bei Fehlern.'
    fi
    echo 'Docker/WSL-Metriken beziehen sich auf den Docker-Daemon-Host, nicht zwingend auf Windows oder diese WSL-Distro.'
    install_git_docker_tool "Node_Exporter" "https://github.com/prometheus/node_exporter.git" "/opt/node_exporter" "$compose"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    node_exporter_main "$@"
fi
