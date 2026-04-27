#!/bin/bash
# Gemeinsame Hilfsfunktionen für Connector-, Workflow- und Integrationsmodule

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HELPER_DIR/../../helpers/status_tracking.sh"

write_optional_file() {
    local target_path="$1"
    local content="${2:-}"

    if [ -n "$content" ]; then
        cat > "$target_path" <<EOF
$content
EOF
    fi
}

install_scaffold_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
    : "${TOOL_DESCRIPTION:?TOOL_DESCRIPTION ist erforderlich}"

    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
    init_tool_tracking "$TOOL_KEY"

    echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"

    if [ -n "${TOOL_APT_PACKAGES:-}" ]; then
        if ! command -v apt-get >/dev/null 2>&1; then
            echo -e "${RED}Fehler: Dieses Skript unterstützt aktuell nur apt-basierte Systeme.${NC}"
            exit 1
        fi
        sudo apt-get update
        sudo apt-get install -y ${TOOL_APT_PACKAGES}
    fi

    sudo mkdir -p "$TOOL_DIR"
    sudo chown -R "$USER:$USER" "$TOOL_DIR"

    if [ -n "${TOOL_GIT_REPO:-}" ]; then
        if [ -d "$TOOL_DIR/.git" ]; then
            git -C "$TOOL_DIR" pull --ff-only || true
        else
            rm -rf "$TOOL_DIR"
            git clone "$TOOL_GIT_REPO" "$TOOL_DIR"
        fi
    fi

    write_optional_file "$TOOL_DIR/.env.template" "${TOOL_ENV_TEMPLATE:-}"
    write_optional_file "$TOOL_DIR/config.json" "${TOOL_CONFIG_JSON:-}"
    write_optional_file "$TOOL_DIR/run.sh" "${TOOL_RUN_SCRIPT:-}"
    write_optional_file "$TOOL_DIR/PROMPT_EXAMPLES.md" "${TOOL_PROMPT_EXAMPLE:-}"
    write_optional_file "$TOOL_DIR/INTEGRATION_NOTES.md" "${TOOL_INTEGRATION_NOTES:-}"

    cat > "$TOOL_DIR/README.md" <<EOF
# ${TOOL_NAME}

${TOOL_DESCRIPTION}

## Installation

Pfad: ${TOOL_DIR}

## OpenClaw / Ollama Hinweis

${TOOL_OPENCLAW_NOTE:-Keine zusätzlichen Hinweise hinterlegt.}

## Art des Moduls

${TOOL_MODULE_TYPE:-Connector-/Workflow-Modul}
EOF

    if [ -f "$TOOL_DIR/run.sh" ]; then
        chmod +x "$TOOL_DIR/run.sh"
    fi

    if [ -n "${TOOL_POST_INSTALL:-}" ]; then
        bash -lc "cd '$TOOL_DIR' && ${TOOL_POST_INSTALL}"
    fi

    mark_current_tool_installed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_scaffold_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"

    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
    init_tool_tracking "$TOOL_KEY"

    echo -e "${BLUE}Starte Deinstallation von ${TOOL_NAME}...${NC}"
    sudo rm -rf "$TOOL_DIR"
    mark_current_tool_removed
    echo -e "${GREEN}${TOOL_NAME} wurde entfernt.${NC}"
}
