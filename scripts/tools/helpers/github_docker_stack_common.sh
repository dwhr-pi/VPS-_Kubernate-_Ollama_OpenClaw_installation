#!/bin/bash
# Gemeinsame Hilfsfunktionen für GitHub-basierte Docker-Stacks

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HELPER_DIR/../../helpers/status_tracking.sh"
# shellcheck disable=SC1091
source "$HELPER_DIR/docker_compose_tool_common.sh"

write_stack_optional_file() {
    local target_path="$1"
    local content="${2:-}"
    if [ -n "$content" ]; then
        mkdir -p "$(dirname "$target_path")"
        cat > "$target_path" <<EOF
$content
EOF
    fi
}

install_github_docker_stack_tool() {
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

    if [ -n "${TOOL_GIT_REPO:-}" ]; then
        mkdir -p "$TOOL_DIR/source"
        if [ -d "$TOOL_DIR/source/.git" ]; then
            git -C "$TOOL_DIR/source" pull --ff-only || true
        else
            rm -rf "$TOOL_DIR/source"
            git clone "$TOOL_GIT_REPO" "$TOOL_DIR/source"
        fi
    fi

    cat > "$TOOL_DIR/docker-compose.yml" <<EOF
${COMPOSE_YAML}
EOF

    write_stack_optional_file "$TOOL_DIR/.env" "${TOOL_ENV_FILE_CONTENT:-}"
    write_stack_optional_file "$TOOL_DIR/${TOOL_CONFIG_PATH_1:-}" "${TOOL_CONFIG_CONTENT_1:-}"
    write_stack_optional_file "$TOOL_DIR/${TOOL_CONFIG_PATH_2:-}" "${TOOL_CONFIG_CONTENT_2:-}"
    write_stack_optional_file "$TOOL_DIR/${TOOL_CONFIG_PATH_3:-}" "${TOOL_CONFIG_CONTENT_3:-}"
    write_stack_optional_file "$TOOL_DIR/README.md" "${TOOL_README_CONTENT:-}"

    if [ -n "${TOOL_POST_INSTALL:-}" ]; then
        bash -lc "cd '$TOOL_DIR' && ${TOOL_POST_INSTALL}"
    fi

    docker compose -f "$TOOL_DIR/docker-compose.yml" up -d
    mark_current_tool_installed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_github_docker_stack_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"

    init_tool_tracking "$TOOL_KEY"
    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"

    echo -e "${BLUE}Starte Deinstallation von ${TOOL_NAME}...${NC}"
    if [ -f "$TOOL_DIR/docker-compose.yml" ]; then
        docker compose -f "$TOOL_DIR/docker-compose.yml" down -v || true
    fi
    sudo rm -rf "$TOOL_DIR"
    mark_current_tool_removed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich entfernt.${NC}"
}
