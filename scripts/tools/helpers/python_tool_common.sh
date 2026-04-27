#!/bin/bash
# Gemeinsame Hilfsfunktionen für Python-basierte Tool-Installationen

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

install_python_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
    : "${TOOL_PACKAGES:?TOOL_PACKAGES ist erforderlich}"

    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
    TOOL_PYTHON="${TOOL_PYTHON:-python3}"

    echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"

    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Dieses Skript unterstützt aktuell nur apt-basierte Systeme.${NC}"
        exit 1
    fi

    sudo apt-get update
    sudo apt-get install -y python3 python3-venv python3-pip build-essential git curl

    sudo mkdir -p "${TOOL_DIR}"
    sudo chown -R "$USER:$USER" "${TOOL_DIR}"

    if [ ! -d "${TOOL_DIR}/venv" ]; then
        "${TOOL_PYTHON}" -m venv "${TOOL_DIR}/venv"
    fi

    # shellcheck disable=SC1091
    source "${TOOL_DIR}/venv/bin/activate"
    pip install --upgrade pip setuptools wheel
    pip install ${TOOL_PACKAGES}

    if [ -n "${TOOL_POST_INSTALL:-}" ]; then
        bash -lc "source '${TOOL_DIR}/venv/bin/activate' && ${TOOL_POST_INSTALL}"
    fi

    cat > "${TOOL_DIR}/README.md" <<EOF
# ${TOOL_NAME}

${TOOL_DESCRIPTION:-Kein Beschreibungstext hinterlegt.}

## Installation

Pfad: ${TOOL_DIR}

## OpenClaw / Ollama Hinweis

${TOOL_OPENCLAW_NOTE:-Keine zusätzlichen Hinweise hinterlegt.}
EOF

    if [ -n "${TOOL_PROMPT_EXAMPLE:-}" ]; then
        cat > "${TOOL_DIR}/PROMPT_EXAMPLES.md" <<EOF
# Beispielprompts für ${TOOL_NAME}

${TOOL_PROMPT_EXAMPLE}
EOF
    fi

    deactivate
    echo -e "${GREEN}${TOOL_NAME} wurde erfolgreich installiert.${NC}"
}

uninstall_python_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"

    echo -e "${BLUE}Starte Deinstallation von ${TOOL_NAME}...${NC}"
    sudo rm -rf "${TOOL_DIR}"
    echo -e "${GREEN}${TOOL_NAME} wurde entfernt.${NC}"
}
