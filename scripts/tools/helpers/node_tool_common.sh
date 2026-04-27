#!/bin/bash
# Gemeinsame Hilfsfunktionen für Node-basierte Tool-Installationen

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HELPER_DIR/../../helpers/status_tracking.sh"

install_node_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
    : "${TOOL_NPM_PACKAGES:?TOOL_NPM_PACKAGES ist erforderlich}"

    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
    init_tool_tracking "$TOOL_KEY"

    echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"

    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Node.js und npm werden für ${TOOL_NAME} benötigt.${NC}"
        exit 1
    fi

    sudo mkdir -p "$TOOL_DIR"
    sudo chown -R "$USER:$USER" "$TOOL_DIR"

    cd "$TOOL_DIR"
    if [ ! -f package.json ]; then
        npm init -y >/dev/null 2>&1
    fi
    npm install ${TOOL_NPM_PACKAGES}

    cat > "$TOOL_DIR/README.md" <<EOF
# ${TOOL_NAME}

${TOOL_DESCRIPTION:-Kein Beschreibungstext hinterlegt.}

## Installation

Pfad: ${TOOL_DIR}

## OpenClaw / Ollama Hinweis

${TOOL_OPENCLAW_NOTE:-Keine zusätzlichen Hinweise hinterlegt.}
EOF

    if [ -n "${TOOL_PROMPT_EXAMPLE:-}" ]; then
        cat > "$TOOL_DIR/PROMPT_EXAMPLES.md" <<EOF
${TOOL_PROMPT_EXAMPLE}
EOF
    fi

    mark_current_tool_installed
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_node_tool() {
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
