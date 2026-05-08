#!/usr/bin/env bash
set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"

init_tool_tracking "Penpot"

PENPOT_DIR="${PENPOT_DIR:-/opt/penpot}"
PENPOT_COMPOSE_TARGET="$PENPOT_DIR/docker-compose.penpot.yml"
PENPOT_ENV_TARGET="$PENPOT_DIR/.env"

echo -e "${BLUE}Starte Deinstallation von Penpot...${NC}"

if [ -f "$PENPOT_COMPOSE_TARGET" ] && command -v docker >/dev/null 2>&1; then
    if [ -f "$PENPOT_ENV_TARGET" ]; then
        docker compose --env-file "$PENPOT_ENV_TARGET" -f "$PENPOT_COMPOSE_TARGET" down -v || true
    else
        docker compose -f "$PENPOT_COMPOSE_TARGET" down -v || true
    fi
fi

sudo rm -rf "$PENPOT_DIR"
mark_current_tool_removed
echo -e "${GREEN}Penpot wurde entfernt.${NC}"
echo -e "${YELLOW}Hinweis:${NC} Falls du spaeter wieder installierst, wird eine neue lokale Standardkonfiguration erzeugt."
