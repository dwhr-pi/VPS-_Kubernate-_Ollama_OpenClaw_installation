#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/helpers/docker_compose_tool_common.sh"

init_tool_tracking "OpenTelemetry"
ensure_docker_compose

TOOL_DIR="/opt/opentelemetry"
sudo mkdir -p "$TOOL_DIR"
sudo chown -R "$USER:$USER" "$TOOL_DIR"

cat > "$TOOL_DIR/config.yaml" <<EOF
receivers:
  otlp:
    protocols:
      grpc:
      http:
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

cat > "$TOOL_DIR/docker-compose.yml" <<EOF
services:
  otel-collector:
    image: otel/opentelemetry-collector:0.100.0
    command: ["--config=/etc/otelcol/config.yaml"]
    ports:
      - "4317:4317"
      - "4318:4318"
    volumes:
      - ./config.yaml:/etc/otelcol/config.yaml:ro
EOF

docker compose -f "$TOOL_DIR/docker-compose.yml" up -d
mark_current_tool_installed
echo "OpenTelemetry wurde erfolgreich installiert."
