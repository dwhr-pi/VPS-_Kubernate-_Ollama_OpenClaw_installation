#!/bin/bash
# ==============================================================================
# RUFLO_INSTALL.SH - Ruflo Installation & Management
# Installiert Ruflo von GitHub, stellt Node/pnpm sicher und verlinkt die CLI.
# ==============================================================================

set -euo pipefail

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

RUFLO_DIR="/opt/ruflo"
RUFLO_REPOS=(
    "${RUFLO_REPO_URL:-}"
    "https://github.com/ruvnet/ruflo.git"
    "https://github.com/dwhr-pi/ruflo.git"
)

run_sudo() {
    if [ "${EUID}" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

ensure_base_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Dieses Skript unterstuetzt aktuell nur apt-basierte Systeme.${NC}"
        exit 1
    fi

    run_sudo apt-get update
    run_sudo apt-get install -y curl ca-certificates git
}

ensure_nodejs_22() {
    local current_major

    if command -v node >/dev/null 2>&1; then
        current_major="$(node -p 'process.versions.node.split(".")[0]')"
        if [ "${current_major}" -ge 22 ]; then
            return
        fi
        echo -e "${YELLOW}Gefundene Node.js Version $(node -v) ist zu alt. Aktualisiere auf Node.js 22.x...${NC}"
    else
        echo -e "${BLUE}Node.js ist nicht installiert. Installiere Node.js 22.x...${NC}"
    fi

    curl -fsSL https://deb.nodesource.com/setup_22.x | run_sudo bash -
    run_sudo apt-get install -y nodejs
}

ensure_pnpm() {
    if ! command -v corepack >/dev/null 2>&1; then
        echo -e "${RED}Fehler: corepack ist nicht verfuegbar, obwohl Node.js installiert sein sollte.${NC}"
        exit 1
    fi

    run_sudo env PATH="$PATH" corepack enable
    run_sudo env PATH="$PATH" corepack prepare pnpm@latest --activate
}

detect_ruflo_repo() {
    local repo
    for repo in "${RUFLO_REPOS[@]}"; do
        [ -z "$repo" ] && continue
        if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
            echo "$repo"
            return 0
        fi
    done
    return 1
}

clone_or_update_repo() {
    local repo_url="$1"

    if [ -d "$RUFLO_DIR/.git" ]; then
        echo -e "${YELLOW}Ruflo-Verzeichnis $RUFLO_DIR existiert bereits. Aktualisiere Repository...${NC}"
        cd "$RUFLO_DIR"
        git pull --ff-only
        return
    fi

    if [ -d "$RUFLO_DIR" ] && [ ! -d "$RUFLO_DIR/.git" ]; then
        echo -e "${RED}Fehler: $RUFLO_DIR existiert, ist aber kein Git-Repository.${NC}"
        echo -e "${YELLOW}Bitte sichern oder entfernen Sie das Verzeichnis und starten Sie das Skript erneut.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Klone Ruflo in $RUFLO_DIR...${NC}"
    run_sudo mkdir -p "$RUFLO_DIR"
    run_sudo chown -R "$USER:$USER" "$RUFLO_DIR"
    git clone "$repo_url" "$RUFLO_DIR"
    cd "$RUFLO_DIR"
}

install_ruflo() {
    if [ ! -f package.json ]; then
        echo -e "${RED}Fehler: Im Ruflo-Repository wurde keine package.json gefunden.${NC}"
        exit 1
    fi

    echo -e "${BLUE}Installiere Ruflo-Abhaengigkeiten mit pnpm...${NC}"
    pnpm install --no-frozen-lockfile

    echo -e "${BLUE}Baue Ruflo mit pnpm...${NC}"
    pnpm build
}

link_ruflo_cli() {
    local cli_path="$RUFLO_DIR/bin/cli.js"

    if [ ! -f "$cli_path" ]; then
        echo -e "${YELLOW}Warnung: Ruflo CLI-Datei wurde nicht gefunden. Ueberspringe globale Verlinkung.${NC}"
        return
    fi

    chmod +x "$cli_path"
    run_sudo ln -sf "$cli_path" /usr/local/bin/ruflo
    run_sudo ln -sf "$cli_path" /usr/local/bin/claude-flow
}

print_summary() {
    echo -e "${GREEN}Ruflo wurde erfolgreich vorbereitet.${NC}"
    echo -e "${YELLOW}Hinweis:${NC} Das Upstream-Paket heisst derzeit intern 'claude-flow', obwohl das Projekt als Ruflo gebrandet ist."
    echo -e "${BLUE}Verfuegbare CLI-Befehle:${NC}"
    echo "  ruflo --help"
    echo "  claude-flow --help"
}

echo -e "${BLUE}Starte Ruflo Installation & Management...${NC}"

RUFLO_REPO_URL="$(detect_ruflo_repo || true)"
if [ -z "$RUFLO_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Ruflo Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprueft wurden ruvnet/ruflo und dwhr-pi/ruflo.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf RUFLO_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

echo -e "${GREEN}1/4: Installiere Grundabhaengigkeiten fuer Ruflo...${NC}"
ensure_base_packages
ensure_nodejs_22
ensure_pnpm

echo -e "${GREEN}2/4: Hole Ruflo aus GitHub...${NC}"
clone_or_update_repo "$RUFLO_REPO_URL"

echo -e "${GREEN}3/4: Installiere und baue Ruflo...${NC}"
install_ruflo

echo -e "${GREEN}4/4: Richte Ruflo CLI ein...${NC}"
link_ruflo_cli
print_summary
