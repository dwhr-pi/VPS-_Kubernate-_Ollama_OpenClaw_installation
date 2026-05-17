#!/bin/bash
TOOL_NAME="Prometheus"
TOOL_KEY="Prometheus"
TOOL_SLUG="prometheus"
COMPOSE_YAML='services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./data:/prometheus'
TOOL_ENV_FILE_CONTENT=''

prometheus_prepare_config() {
    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"

    sudo mkdir -p "$TOOL_DIR/data"
    sudo chown -R "$USER:$USER" "$TOOL_DIR"

    if [ -d "$TOOL_DIR/prometheus.yml" ]; then
        backup_dir="$TOOL_DIR/prometheus.yml.bak.$(date +%Y%m%d_%H%M%S)"
        echo "Hinweis: $TOOL_DIR/prometheus.yml war ein Verzeichnis. Verschiebe nach $backup_dir und erstelle eine echte Datei."
        mv "$TOOL_DIR/prometheus.yml" "$backup_dir"
    fi

    if [ ! -f "$TOOL_DIR/prometheus.yml" ]; then
        cat > "$TOOL_DIR/prometheus.yml" <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets:
          - 127.0.0.1:9090
EOF
    fi

    if [ ! -f "$TOOL_DIR/prometheus.yml" ]; then
        echo "Fehler: $TOOL_DIR/prometheus.yml konnte nicht als Datei erstellt werden." >&2
        exit 1
    fi
}

source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
prometheus_prepare_config
install_docker_compose_tool
