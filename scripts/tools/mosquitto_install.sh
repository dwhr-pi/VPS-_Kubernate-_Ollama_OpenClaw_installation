#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
mosquitto_compose() {
    local port="${MOSQUITTO_HOST_PORT:-1883}"
    if ! [[ "$port" =~ ^[1-9][0-9]{0,4}$ ]] || ((10#$port > 65535)); then
        echo 'Fehler: MOSQUITTO_HOST_PORT muss zwischen 1 und 65535 liegen.' >&2; return 2
    fi
    cat <<EOF
services:
  mosquitto:
    image: eclipse-mosquitto:2
    ports:
      - "127.0.0.1:${port}:1883"
    restart: unless-stopped
    volumes:
      - ./config:/mosquitto/config:ro
      - ./data:/mosquitto/data
      - ./log:/mosquitto/log
EOF
}

mosquitto_prepare_config() {
    local dir="$1"
    if [[ -L "$dir" || -L "$dir/config" || -L "$dir/config/mosquitto.conf" ]]; then
        echo 'Fehler: Mosquitto-Konfigurationspfad ist ein Symlink; manuell pruefen.' >&2; return 1
    fi
    sudo mkdir -p "$dir/config" || return 1
    sudo chown "$(id -un):$(id -gn)" "$dir/config" || return 1
    if [[ ! -e "$dir/config/mosquitto.conf" ]]; then
        # Fail closed until the operator adds credentials/ACLs.
        printf '%s\n' 'listener 1883' 'allow_anonymous false' 'persistence false' 'log_dest stdout' > "$dir/config/mosquitto.conf" || return 1
        chmod 644 "$dir/config/mosquitto.conf" || return 1
    fi
}

mosquitto_main() {
    local compose mode="${1:-install}"
    case "$mode" in install|--dry-run) ;; *) echo 'Aufruf: mosquitto_install.sh [--dry-run]' >&2; return 2 ;; esac
    compose="$(mosquitto_compose)" || return $?
    if [[ "$mode" == --dry-run ]]; then printf '%s\n' "$compose"; return 0; fi
    echo 'Mosquitto: MQTT nur auf localhost; WebSocket-Port 9001 wird nicht veroeffentlicht.'
    echo 'Neue Konfiguration verweigert anonyme Clients. Passwortdatei/ACL bewusst einrichten; keine Passwoerter generiert.'
    mosquitto_prepare_config /opt/mosquitto || return 1
    install_git_docker_tool "Mosquitto" "https://github.com/eclipse-mosquitto/mosquitto.git" "/opt/mosquitto" "$compose"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then mosquitto_main "$@"; fi
