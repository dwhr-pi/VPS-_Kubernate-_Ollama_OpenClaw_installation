#!/bin/bash
# ==============================================================================
# HUGINN_STATUS.SH - Kurzer Nachtest fuer Huginn-Dienste und lokalen Port
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m"

HUGINN_DIR="${HUGINN_DIR:-/opt/huginn}"
HUGINN_WEB_PORT="${HUGINN_WEB_PORT:-3002}"
HUGINN_WEB_SERVICE="${HUGINN_WEB_SERVICE:-huginn-web.service}"
HUGINN_WORKER_SERVICE="${HUGINN_WORKER_SERVICE:-huginn-worker.service}"

print_header() {
    echo
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

print_header "Huginn Status"

if [ -d "$HUGINN_DIR/.git" ]; then
    echo -e "${GREEN}Repository:${NC} $HUGINN_DIR"
    git -C "$HUGINN_DIR" --no-pager log -1 --oneline || true
    echo -e "${YELLOW}Aktiver Git-Ref:${NC} $(git -C "$HUGINN_DIR" branch --show-current 2>/dev/null || true)"
else
    echo -e "${RED}Huginn Repository nicht gefunden:${NC} $HUGINN_DIR"
fi

echo
echo -e "${YELLOW}Datenbankadapter:${NC}"
if [ -f "$HUGINN_DIR/.env" ]; then
    grep -E '^(DATABASE_ADAPTER|DATABASE_NAME|DATABASE_HOST|DATABASE_PORT)=' "$HUGINN_DIR/.env" || true
else
    echo "Keine .env unter $HUGINN_DIR gefunden."
fi

echo
echo -e "${YELLOW}Systemd-Dienste:${NC}"
if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
    systemctl --no-pager --full status "$HUGINN_WEB_SERVICE" "$HUGINN_WORKER_SERVICE" || true
else
    echo "systemd ist in dieser Umgebung nicht verfuegbar."
fi

echo
echo -e "${YELLOW}HTTP-Test auf 127.0.0.1:${HUGINN_WEB_PORT}:${NC}"
if command -v curl >/dev/null 2>&1; then
    if curl -fsS -I "http://127.0.0.1:${HUGINN_WEB_PORT}" >/tmp/huginn_status_headers 2>/tmp/huginn_status_error; then
        echo -e "${GREEN}Huginn antwortet auf Port ${HUGINN_WEB_PORT}.${NC}"
        cat /tmp/huginn_status_headers
    else
        echo -e "${YELLOW}Noch keine erfolgreiche HTTP-Antwort auf Port ${HUGINN_WEB_PORT}.${NC}"
        cat /tmp/huginn_status_error 2>/dev/null || true
    fi
else
    echo "curl ist nicht installiert."
fi

rm -f /tmp/huginn_status_headers /tmp/huginn_status_error
