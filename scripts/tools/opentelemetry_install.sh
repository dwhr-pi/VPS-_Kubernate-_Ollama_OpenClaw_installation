#!/bin/bash

set -euo pipefail

OPENTELEMETRY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$OPENTELEMETRY_SCRIPT_DIR/../lib/resource_check.sh"
# shellcheck disable=SC1091
source "$OPENTELEMETRY_SCRIPT_DIR/../helpers/status_tracking.sh"
# shellcheck disable=SC1091
source "$OPENTELEMETRY_SCRIPT_DIR/helpers/docker_compose_tool_common.sh"

check_opentelemetry_disk() {
    local free_mb windows_mb
    free_mb="$(snapshot_disk_mb /opt)" || return 1
    if ! [[ "$free_mb" =~ ^[0-9]+$ ]] || ((free_mb < 2048)); then
        echo 'Fehler: OpenTelemetry benoetigt als Setup-Reserve mindestens 2048 MB frei auf /opt.' >&2
        return 1
    fi
    windows_mb="$(snapshot_windows_host_disk_mb 2>/dev/null || true)"
    if [[ -n "$windows_mb" ]] && { ! [[ "$windows_mb" =~ ^[0-9]+$ ]] || ((windows_mb < 10240)); }; then
        echo "Fehler: Windows-C:-Reserve fuer Docker/WSL zu niedrig: $windows_mb MB; mindestens 10240 MB einplanen." >&2
        return 1
    fi
}

start_opentelemetry_stack() {
    local compose_file="$1"
    run_docker_compose_tool -f "$compose_file" config --quiet || return 1
    if ! run_docker_compose_tool -f "$compose_file" up -d; then
        echo 'Fehler: OpenTelemetry-Start fehlgeschlagen. Docker-Daemon/sudo, Ports und Image-Pull pruefen; kein Installiert-Status gesetzt.' >&2
        return 1
    fi
    mark_current_tool_installed
    echo 'OpenTelemetry Compose-Start erfolgreich. Collector-Logs und OTLP-Empfang anschliessend pruefen.'
}

install_opentelemetry() {
    local mode="${1:-install}"
    case "$mode" in install|--check|--dry-run) ;; *) echo 'Aufruf: opentelemetry_install.sh [--check|--dry-run]' >&2; return 2 ;; esac
    check_opentelemetry_disk || return 1
    if ! command -v docker >/dev/null 2>&1; then
        echo 'Fehler: Docker fehlt. Docker bewusst separat einrichten; keine automatische Installation oder Gruppen-/Socket-Aenderung.' >&2
        return 1
    fi
    if [[ "$mode" != install ]]; then
        docker compose version || return 1
        echo 'Speicher/Compose-Pruefung bestanden. Kein Download oder Start; Daemon-Rechte werden beim echten Lauf geprueft.'
        return 0
    fi
    run_docker_compose_tool version || return 1
    AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking "OpenTelemetry"

    local TOOL_DIR="/opt/opentelemetry"
    if [[ -L "$TOOL_DIR" ]]; then echo 'Fehler: OpenTelemetry-Ziel ist ein Symlink.' >&2; return 1; fi
    sudo mkdir -p "$TOOL_DIR" || return 1
    sudo chown "$(id -un):$(id -gn)" "$TOOL_DIR" || return 1

if [[ ! -e "$TOOL_DIR/config.yaml" ]]; then
cat > "$TOOL_DIR/config.yaml" <<EOF
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
exporters:
  logging:
processors:
  batch:
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [logging]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [logging]
EOF
fi

if [[ ! -e "$TOOL_DIR/docker-compose.yml" ]]; then
cat > "$TOOL_DIR/docker-compose.yml" <<EOF
services:
  otel-collector:
    image: otel/opentelemetry-collector:0.100.0
    command: ["--config=/etc/otelcol/config.yaml"]
    ports:
      - "127.0.0.1:4317:4317"
      - "127.0.0.1:4318:4318"
    volumes:
      - ./config.yaml:/etc/otelcol/config.yaml:ro
EOF
else
    echo 'Vorhandene Compose-Datei bleibt unveraendert. Portbindungen bitte auf 127.0.0.1 pruefen.'
fi

    start_opentelemetry_stack "$TOOL_DIR/docker-compose.yml"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    install_opentelemetry "$@"
fi
