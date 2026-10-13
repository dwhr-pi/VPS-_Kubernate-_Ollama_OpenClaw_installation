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

check_node_tool_runtime() {
    local version required="${TOOL_NODE_MIN_VERSION:-}" node_major node_minor node_patch req_major req_minor req_patch
    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        echo "Fehler: Node und npm werden fuer ${TOOL_NAME} benoetigt." >&2; return 1
    fi
    [ -n "$required" ] || return 0
    version="$(node --version)" || return 1
    if ! [[ "$version" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then return 1; fi
    node_major="${BASH_REMATCH[1]}" node_minor="${BASH_REMATCH[2]}" node_patch="${BASH_REMATCH[3]}"
    if ! [[ "$required" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then return 2; fi
    req_major="${BASH_REMATCH[1]}" req_minor="${BASH_REMATCH[2]}" req_patch="${BASH_REMATCH[3]}"
    if ((node_major < req_major || (node_major == req_major && node_minor < req_minor) || (node_major == req_major && node_minor == req_minor && node_patch < req_patch))); then
        echo "Fehler: ${TOOL_NAME} benoetigt Node >=${required}; gefunden: ${version}. Passende Node-Version aktivieren und Installer erneut starten." >&2
        return 1
    fi
}

install_node_tool() {
    : "${TOOL_NAME:?TOOL_NAME ist erforderlich}"
    : "${TOOL_KEY:?TOOL_KEY ist erforderlich}"
    : "${TOOL_SLUG:?TOOL_SLUG ist erforderlich}"
    : "${TOOL_NPM_PACKAGES:?TOOL_NPM_PACKAGES ist erforderlich}"

    TOOL_DIR="${TOOL_DIR:-/opt/${TOOL_SLUG}}"
    check_node_tool_runtime || return 1
    AUTO_INSTALL_TOOL_BASE_DEPS=false init_tool_tracking "$TOOL_KEY"

    echo -e "${BLUE}Starte Installation von ${TOOL_NAME}...${NC}"

    if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Node.js und npm werden für ${TOOL_NAME} benötigt.${NC}"
        exit 1
    fi

    if [ -n "${TOOL_APT_PACKAGES:-}" ]; then
        local package_name
        local -a requested_packages missing_packages=()
        read -r -a requested_packages <<< "$TOOL_APT_PACKAGES"
        for package_name in "${requested_packages[@]}"; do
            if ! dpkg -s "$package_name" >/dev/null 2>&1; then missing_packages+=("$package_name"); fi
        done
        if [ "${#missing_packages[@]}" -gt 0 ]; then
            run_apt_with_lock_wait update || return 1
            run_apt_with_lock_wait install -y "${missing_packages[@]}" || return 1
        fi
    fi

    sudo mkdir -p "$TOOL_DIR"
    sudo chown -R "$USER:$USER" "$TOOL_DIR"

    cd "$TOOL_DIR"
    if [ ! -f package.json ]; then
        npm init -y >/dev/null 2>&1
    fi
    if ! npm install --engine-strict ${TOOL_NPM_PACKAGES}; then
        echo "Fehler: npm-Installation von ${TOOL_NAME} fehlgeschlagen." >&2
        return 1
    fi
    if [ -n "${TOOL_POST_INSTALL_FUNCTION:-}" ]; then
        if ! declare -F "$TOOL_POST_INSTALL_FUNCTION" >/dev/null || ! "$TOOL_POST_INSTALL_FUNCTION"; then
            echo "Fehler: Smoke-Test von ${TOOL_NAME} fehlgeschlagen." >&2
            return 1
        fi
    fi

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
