#!/bin/bash
# ==============================================================================
# BASE_INSTALL.SH - Gemeinsame Abhängigkeiten & OpenClaw Build
# Dieses Skript installiert grundlegende Abhängigkeiten und baut OpenClaw
# aus den GitHub-Quellen mit pnpm.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"
TTY_DEVICE="/dev/tty"

echo -e "${BLUE}Starte Basis-Installation: System-Updates, Node.js, pnpm, Python, Git...${NC}"

ensure_nodejs_22() {
    local current_major

    if command -v node >/dev/null 2>&1; then
        current_major="$(node -p "process.versions.node.split('.')[0]")"
        if [ "$current_major" -ge 22 ]; then
            echo -e "${GREEN}Node.js $(node -v) erfüllt bereits die Anforderung >= 22.${NC}"
            return 0
        fi
    fi

    echo -e "${YELLOW}Installiere bzw. aktualisiere Node.js auf Version 22.x...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs

    if ! command -v node >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Node.js konnte nicht installiert werden.${NC}"
        exit 1
    fi

    current_major="$(node -p "process.versions.node.split('.')[0]")"
    if [ "$current_major" -lt 22 ]; then
        echo -e "${RED}Fehler: Node.js $(node -v) ist weiterhin zu alt. Benötigt wird >= 22.${NC}"
        exit 1
    fi
}

prompt_yes_no() {
    local prompt="$1"
    local response

    if [ ! -e "$TTY_DEVICE" ]; then
        return 1
    fi

    read -r -p "$prompt" response < "$TTY_DEVICE"
    [[ "$response" =~ ^[JjYy]$ ]]
}

handle_ignored_build_scripts() {
    local ignored_output

    ignored_output="$(pnpm ignored-builds 2>/dev/null || true)"
    if [ -z "$ignored_output" ]; then
        return 0
    fi

    if ! printf '%s' "$ignored_output" | grep -Eq '@discordjs/opus|Ignored build scripts|ignored'; then
        return 0
    fi

    echo -e "${YELLOW}Hinweis: pnpm hat ignorierte Build-Skripte gemeldet.${NC}"
    echo "$ignored_output"

    if prompt_yes_no "Ich korrigiere jetzt das zuvor fehlende ignorierte Build-Skript, z.B. @discordjs/opus@0.10.0. Bitte bestätige die Korrektur mit (j/N): "; then
        pnpm approve-builds < "$TTY_DEVICE" > "$TTY_DEVICE" 2>&1 || {
            echo -e "${RED}Warnung: 'pnpm approve-builds' konnte nicht erfolgreich abgeschlossen werden.${NC}"
            return 1
        }
        echo -e "${GREEN}Die Freigabe der Build-Skripte wurde durchgeführt bzw. interaktiv bestätigt.${NC}"
    else
        echo -e "${YELLOW}Freigabe übersprungen. Du kannst sie später manuell mit 'pnpm approve-builds' im Projektordner ausführen.${NC}"
    fi
}

# 1. System aktualisieren
echo -e "${GREEN}1/5: System-Updates durchführen...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ca-certificates git python3 python3-pip build-essential zstd
ensure_nodejs_22

# 2. pnpm installieren (falls nicht vorhanden)
echo -e "${GREEN}2/5: pnpm installieren...${NC}"
if ! command -v pnpm >/dev/null 2>&1; then
    echo -e "${YELLOW}pnpm nicht gefunden, installiere global...${NC}"
    sudo npm install -g pnpm
    if ! command -v pnpm >/dev/null 2>&1; then
        echo -e "${RED}Fehler: pnpm konnte nicht installiert werden. Bitte manuell prüfen.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}pnpm ist bereits installiert.${NC}"
fi

# 3. OpenClaw aus GitHub klonen und bauen
echo -e "${GREEN}3/5: OpenClaw aus GitHub klonen und bauen...${NC}"
OPENCLAW_DIR="/opt/openclaw"
if [ -d "$OPENCLAW_DIR" ]; then
    echo -e "${YELLOW}OpenClaw Verzeichnis $OPENCLAW_DIR existiert bereits. Überspringe Klonen.${NC}"
    cd "$OPENCLAW_DIR"
    git pull --ff-only
else
    echo -e "${BLUE}Klone OpenClaw in $OPENCLAW_DIR...${NC}"
    sudo mkdir -p "$OPENCLAW_DIR"
    sudo chown -R $USER:$USER "$OPENCLAW_DIR"
    git clone https://github.com/openclaw/openclaw.git "$OPENCLAW_DIR"
    cd "$OPENCLAW_DIR"
fi

echo -e "${BLUE}Installiere OpenClaw Abhängigkeiten mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install fehlgeschlagen.${NC}"
    exit 1
fi

echo -e "${BLUE}Baue OpenClaw mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build fehlgeschlagen.${NC}"
    exit 1
fi

init_tool_tracking "OpenClaw"
mark_current_tool_installed

echo -e "${GREEN}OpenClaw Build abgeschlossen. Prüfe nun auf ignorierte pnpm-Build-Skripte...${NC}"
handle_ignored_build_scripts || true

# 4. .env Datei für OpenClaw vorbereiten
echo -e "${GREEN}4/5: OpenClaw .env Datei vorbereiten...${NC}"
if [ ! -f "$OPENCLAW_DIR/.env" ]; then
    cp "$OPENCLAW_DIR/.env.example" "$OPENCLAW_DIR/.env"
    echo -e "${YELLOW}OpenClaw .env Datei erstellt. Bitte bearbeiten Sie diese später.${NC}"
else
    echo -e "${GREEN}OpenClaw .env Datei existiert bereits.${NC}"
fi

# 5. Ollama installieren (falls nicht vorhanden)
echo -e "${GREEN}5/5: Ollama installieren...${NC}"
if ! command -v ollama >/dev/null 2>&1; then
    echo -e "${YELLOW}Ollama nicht gefunden, installiere...${NC}"
    curl -fsSL https://ollama.com/install.sh | sh
    if ! command -v ollama >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Ollama konnte nicht installiert werden. Bitte manuell prüfen.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Ollama ist bereits installiert.${NC}"
fi

init_tool_tracking "Ollama"
mark_current_tool_installed

echo -e "${GREEN}Basis-Installation abgeschlossen.${NC}"
