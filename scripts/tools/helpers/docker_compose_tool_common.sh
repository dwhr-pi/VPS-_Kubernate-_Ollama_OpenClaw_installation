#!/bin/bash
# Gemeinsame Hilfsfunktionen für docker-compose-basierte Tool-Stacks

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
DOCKER_COMPOSE_TOOL_HELPER_REVISION="2026-06-04-sudo-docker-compose-fallback"

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HELPER_DIR/../../helpers/status_tracking.sh"

ensure_docker_compose() {
    echo -e "${YELLOW}Docker-Compose-Helper-Revision:${NC} ${DOCKER_COMPOSE_TOOL_HELPER_REVISION}"

    if command -v docker >/dev/null 2>&1 && { docker compose version >/dev/null 2>&1 || sudo docker compose version >/dev/null 2>&1; }; then
        return 0
    fi

    echo -e "${YELLOW}Docker oder Docker Compose nicht gefunden. Installiere Docker Engine...${NC}"
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER" || true

    if ! command -v docker >/dev/null 2>&1 || ! { docker compose version >/dev/null 2>&1 || sudo docker compose version >/dev/null 2>&1; }; then
        echo -e "${RED}Fehler: Docker Compose konnte nicht bereitgestellt werden.${NC}"
        exit 1
    fi
}

run_docker_compose_tool() {
    if docker compose version >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        docker compose "$@"
        return $?
    fi

    if sudo docker compose version >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}Docker-Daemon ist fuer den aktuellen User nicht direkt nutzbar. Verwende sudo docker compose.${NC}"
        echo -e "${YELLOW}Hinweis:${NC} Nach 'sudo usermod -aG docker $USER' ist meist eine neue Shell/WSL-Sitzung noetig, bis Docker ohne sudo funktioniert."
        sudo docker compose "$@"
        return $?
    fi

    echo -e "${RED}Fehler: Docker-Daemon ist nicht erreichbar oder die Berechtigung auf /var/run/docker.sock fehlt.${NC}"
    echo -e "${YELLOW}Reparaturhinweis:${NC} Docker starten, User-Gruppe pruefen oder den Installer erneut aus einer neuen Shell starten."
    return 1
}

install_docker_compose_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
    : "${COMPOSE_YAML:?COMPOSE_YAML ist erforderlich}"

    init_tool_tracking "$TOOL_KEY"
    ensure_docker_compose

    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"

    echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"
    sudo mkdir -p "$TOOL_DIR"
    sudo chown -R "$USER:$USER" "$TOOL_DIR"

    cat > "$TOOL_DIR/docker-compose.yml" <<EOF
${COMPOSE_YAML}
EOF

    if [ -n "${TOOL_ENV_FILE_CONTENT:-}" ]; then
        cat > "$TOOL_DIR/.env" <<EOF
${TOOL_ENV_FILE_CONTENT}
EOF
    fi

    run_docker_compose_tool -f "$TOOL_DIR/docker-compose.yml" up -d

    if [ -n "${TOOL_PROMPT_EXAMPLE:-}" ]; then
        cat > "$TOOL_DIR/PROMPT_EXAMPLES.md" <<EOF
# Beispielprompts für ${TOOL_NAME}

${TOOL_PROMPT_EXAMPLE}
EOF
    fi

    mark_current_tool_installed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_docker_compose_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"

    init_tool_tracking "$TOOL_KEY"
    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"

    echo -e "${BLUE}Starte Deinstallation von ${TOOL_NAME}...${NC}"

    if [ -f "$TOOL_DIR/docker-compose.yml" ] && command -v docker >/dev/null 2>&1; then
        run_docker_compose_tool -f "$TOOL_DIR/docker-compose.yml" down -v || true
    fi

    sudo rm -rf "$TOOL_DIR"
    mark_current_tool_removed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich entfernt.${NC}"
}
