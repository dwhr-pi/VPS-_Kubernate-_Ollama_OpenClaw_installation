#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"

init_tool_tracking "Penpot"

PENPOT_DIR="${PENPOT_DIR:-/opt/penpot}"
PENPOT_STACK_DIR="$INSTALL_DIR/stacks/penpot"
PENPOT_COMPOSE_SOURCE="$PENPOT_STACK_DIR/docker-compose.penpot.yml"
PENPOT_ENV_SOURCE="$PENPOT_STACK_DIR/penpot.env.example"
PENPOT_README_SOURCE="$PENPOT_STACK_DIR/README.md"
PENPOT_COMPOSE_TARGET="$PENPOT_DIR/docker-compose.penpot.yml"
PENPOT_ENV_TARGET="$PENPOT_DIR/.env"
PENPOT_README_TARGET="$PENPOT_DIR/README.md"
PENPOT_BIND_HOST="${PENPOT_BIND_HOST:-127.0.0.1}"
PENPOT_HOST_PORT="${PENPOT_HOST_PORT:-9011}"
PENPOT_MAILCATCH_PORT="${PENPOT_MAILCATCH_PORT:-1081}"
PENPOT_MIN_RAM_MB="${PENPOT_MIN_RAM_MB:-6144}"
PENPOT_MIN_DISK_MB="${PENPOT_MIN_DISK_MB:-8192}"

require_command() {
    local cmd="$1"
    local hint="$2"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Fehler: ${cmd} wurde nicht gefunden.${NC}"
        echo -e "${YELLOW}${hint}${NC}"
        exit 1
    fi
}

ensure_docker_available() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Docker ist nicht installiert.${NC}"
        echo -e "${YELLOW}Bitte zuerst den Tool-Eintrag 'Docker' installieren und danach Penpot erneut starten.${NC}"
        exit 1
    fi

    if ! docker compose version >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Docker Compose v2 ist nicht verfügbar.${NC}"
        echo -e "${YELLOW}Bitte zuerst das Docker-Compose-Plugin installieren und danach Penpot erneut starten.${NC}"
        exit 1
    fi
}

ensure_stack_files() {
    if [ ! -f "$PENPOT_COMPOSE_SOURCE" ] || [ ! -f "$PENPOT_ENV_SOURCE" ]; then
        echo -e "${RED}Fehler: Penpot-Stackdateien fehlen im Repository.${NC}"
        exit 1
    fi
}

check_free_port() {
    local port="$1"
    local label="$2"
    if ss -ltn "( sport = :$port )" 2>/dev/null | tail -n +2 | grep -q .; then
        echo -e "${RED}Fehler: Port ${port} ist bereits belegt (${label}).${NC}"
        echo -e "${YELLOW}Bitte passe die Penpot-Ports an oder pruefe bestehende Dienste mit:${NC}"
        echo "bash $INSTALL_DIR/scripts/operations/check_port_conflicts.sh"
        exit 1
    fi
}

check_resources() {
    local free_mb total_mb
    free_mb="$(df -Pm / | awk 'NR==2 {print $4}')"
    total_mb="$(awk '/MemTotal/ {printf \"%d\\n\", $2/1024}' /proc/meminfo)"

    if [ "$free_mb" -lt "$PENPOT_MIN_DISK_MB" ]; then
        echo -e "${RED}Fehler: Zu wenig freier Speicher fuer Penpot.${NC}"
        echo -e "${YELLOW}Erforderlich: ${PENPOT_MIN_DISK_MB} MB, verfuegbar: ${free_mb} MB.${NC}"
        exit 1
    fi

    if [ "$total_mb" -lt "$PENPOT_MIN_RAM_MB" ]; then
        echo -e "${RED}Fehler: Zu wenig RAM fuer Penpot.${NC}"
        echo -e "${YELLOW}Erforderlich: ${PENPOT_MIN_RAM_MB} MB, verfuegbar: ${total_mb} MB.${NC}"
        exit 1
    fi
}

generate_penpot_secret_key() {
    if grep -Eq '^PENPOT_SECRET_KEY=' "$PENPOT_ENV_TARGET" 2>/dev/null && ! grep -Eq '^PENPOT_SECRET_KEY=change-me$' "$PENPOT_ENV_TARGET" 2>/dev/null; then
        return 0
    fi

    local secret
    if command -v python3 >/dev/null 2>&1; then
        secret="$(python3 -c 'import secrets; print(secrets.token_urlsafe(64))')"
    elif command -v openssl >/dev/null 2>&1; then
        secret="$(openssl rand -base64 64 | tr -d '\n')"
    else
        secret="penpot-$(date +%s)-change-me"
    fi

    sed -i "s|^PENPOT_SECRET_KEY=.*$|PENPOT_SECRET_KEY=${secret}|" "$PENPOT_ENV_TARGET"
}

prepare_target_dir() {
    echo -e "${BLUE}Bereite Penpot-Verzeichnis vor...${NC}"
    sudo mkdir -p "$PENPOT_DIR"
    sudo chown -R "$USER:$USER" "$PENPOT_DIR"

    cp "$PENPOT_COMPOSE_SOURCE" "$PENPOT_COMPOSE_TARGET"
    if [ ! -f "$PENPOT_ENV_TARGET" ]; then
        cp "$PENPOT_ENV_SOURCE" "$PENPOT_ENV_TARGET"
    fi
    cp "$PENPOT_README_SOURCE" "$PENPOT_README_TARGET"

    sed -i "s|^PENPOT_BIND_HOST=.*$|PENPOT_BIND_HOST=${PENPOT_BIND_HOST}|" "$PENPOT_ENV_TARGET"
    sed -i "s|^PENPOT_HOST_PORT=.*$|PENPOT_HOST_PORT=${PENPOT_HOST_PORT}|" "$PENPOT_ENV_TARGET"
    sed -i "s|^PENPOT_MAILCATCH_PORT=.*$|PENPOT_MAILCATCH_PORT=${PENPOT_MAILCATCH_PORT}|" "$PENPOT_ENV_TARGET"
    sed -i "s|^PENPOT_PUBLIC_URI=.*$|PENPOT_PUBLIC_URI=http://${PENPOT_BIND_HOST}:${PENPOT_HOST_PORT}|" "$PENPOT_ENV_TARGET"
    generate_penpot_secret_key
}

start_penpot_stack() {
    echo -e "${BLUE}Starte Penpot per Docker Compose...${NC}"
    docker compose --env-file "$PENPOT_ENV_TARGET" -f "$PENPOT_COMPOSE_TARGET" up -d
}

print_next_steps() {
    echo -e "${GREEN}Penpot wurde als optionale UI/UX-Design-Plattform vorbereitet.${NC}"
    echo -e "${YELLOW}Web-UI:${NC} http://${PENPOT_BIND_HOST}:${PENPOT_HOST_PORT}"
    echo -e "${YELLOW}Mailcatch-Testoberflaeche:${NC} http://${PENPOT_BIND_HOST}:${PENPOT_MAILCATCH_PORT}"
    echo -e "${YELLOW}Konfiguration:${NC} $PENPOT_ENV_TARGET"
    echo -e "${YELLOW}Compose-Datei:${NC} $PENPOT_COMPOSE_TARGET"
    echo -e "${YELLOW}Hinweis:${NC} Wenn du Penpot spaeter ueber Reverse Proxy, Cloudflare Tunnel oder Tailscale freigibst, passe zuerst PENPOT_PUBLIC_URI in der .env an."
    echo -e "${YELLOW}Hinweis:${NC} Den Penpot MCP Server bitte zunaechst nur lokal oder ueber private/abgesicherte Zugriffswege betreiben."
}

echo -e "${BLUE}Starte Installation von Penpot UI/UX Design Plattform...${NC}"
echo -e "${YELLOW}Penpot wird in diesem Setup bewusst optional und standardmaessig nur lokal gebunden installiert.${NC}"

require_command ss "Das Paket iproute2 bzw. der Befehl 'ss' wird fuer Portpruefungen benoetigt."
ensure_docker_available
ensure_stack_files
check_resources
check_free_port "$PENPOT_HOST_PORT" "Penpot Web UI"
check_free_port "$PENPOT_MAILCATCH_PORT" "Penpot Mailcatch UI"
prepare_target_dir
start_penpot_stack
mark_current_tool_installed
print_next_steps
