#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="Airbyte"
INSTALL_ROOT="/opt/airbyte"
AIRBYTE_SOURCE_DIR="$INSTALL_ROOT/source"
ABCTL_SOURCE_DIR="$INSTALL_ROOT/abctl"
ABCTL_BIN_DIR="$INSTALL_ROOT/bin"
ABCTL_BIN="$ABCTL_BIN_DIR/abctl"
AIRBYTE_PORT="${AIRBYTE_PORT:-8003}"
AIRBYTE_HOST="${AIRBYTE_HOST:-localhost}"

begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"

if ! ensure_user_workspace || ! require_disk_mb 8192 /; then
  end_measurement "failed"
  exit 1
fi

log_info "Starte Installation von Airbyte ueber abctl."
log_warn "Der alte Docker-Compose-Pfad mit airbyte/webapp:latest ist veraltet und wird nicht mehr verwendet."
log_info "Primaerquellen:"
log_info "  Airbyte: https://github.com/airbytehq/airbyte.git"
log_info "  abctl:   https://github.com/airbytehq/abctl.git"

ensure_base_apt_packages git docker.io ca-certificates curl build-essential make golang-go
ensure_docker_compose_available
sudo systemctl enable --now docker || true

if ! docker info >/dev/null 2>&1 && ! sudo docker info >/dev/null 2>&1; then
  log_error "Docker-Daemon ist nicht erreichbar. Airbyte/abctl benoetigt Docker, weil abctl lokal einen kind/Kubernetes-Cluster startet."
  end_measurement "failed"
  exit 1
fi

sudo mkdir -p "$INSTALL_ROOT" "$ABCTL_BIN_DIR"
sudo chown -R "$USER":"$USER" "$INSTALL_ROOT"

clone_or_update_github_source "https://github.com/airbytehq/airbyte.git" "$AIRBYTE_SOURCE_DIR"
clone_or_update_github_source "https://github.com/airbytehq/abctl.git" "$ABCTL_SOURCE_DIR"

log_info "Baue abctl aus GitHub-Quelle..."
if (cd "$ABCTL_SOURCE_DIR" && make build >/dev/null 2>&1); then
  if [ -x "$ABCTL_SOURCE_DIR/build/abctl" ]; then
    cp "$ABCTL_SOURCE_DIR/build/abctl" "$ABCTL_BIN"
  elif [ -x "$ABCTL_SOURCE_DIR/build/abctl_linux_amd64/abctl" ]; then
    cp "$ABCTL_SOURCE_DIR/build/abctl_linux_amd64/abctl" "$ABCTL_BIN"
  fi
fi

if [ ! -x "$ABCTL_BIN" ]; then
  log_warn "make build hat kein abctl-Binary erzeugt. Versuche go build direkt."
  (cd "$ABCTL_SOURCE_DIR" && go build -o "$ABCTL_BIN" .)
fi

chmod +x "$ABCTL_BIN"
"$ABCTL_BIN" version || true

log_warn "Airbyte ist schwergewichtig: abctl startet lokal kind/Kubernetes-Container und benoetigt mehrere GB RAM/SSD."
log_info "Installiere/aktualisiere Airbyte lokal auf http://${AIRBYTE_HOST}:${AIRBYTE_PORT}"

ABCTL_CMD=("$ABCTL_BIN" local install --host "$AIRBYTE_HOST" --port "$AIRBYTE_PORT" --low-resource-mode --no-browser --insecure-cookies)

if docker info >/dev/null 2>&1; then
  "${ABCTL_CMD[@]}"
else
  log_warn "Docker-Daemon ist fuer den aktuellen User nicht direkt nutzbar. Verwende sudo fuer abctl."
  sudo "${ABCTL_CMD[@]}"
fi

log_info "Airbyte-Zugangsdaten koennen mit folgendem Befehl angezeigt werden:"
log_info "  $ABCTL_BIN local credentials"
log_warn "Die Zugangsdaten nicht ins Repository kopieren."

mark_tool_installed "$TOOL_NAME"
log_success "Airbyte wurde ueber abctl installiert oder aktualisiert."
end_measurement "success"
