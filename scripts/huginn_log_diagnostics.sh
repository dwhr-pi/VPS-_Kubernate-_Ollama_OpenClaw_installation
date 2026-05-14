#!/bin/bash
# ==============================================================================
# HUGINN_LOG_DIAGNOSTICS.SH - Findet und filtert den neuesten Huginn-Installlog
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-$HOME/.openclaw_ultimate_user_data}"
INSTALL_LOG_DIR="${INSTALL_LOG_DIR:-$USER_WORKSPACE_DIR/install_logs}"
LOG_PATTERN="${LOG_PATTERN:-*Huginn*.log}"
LINE_COUNT="${LINE_COUNT:-220}"

PATTERN='Hinweis:|Fehler:|rake aborted!|LoadError|ArgumentError|ConnectionError|mysql2|pg_ext|grpc|net-imap|net-pop|assets:precompile|systemd|huginn-web|huginn-worker|bundle|Bundler|Gemfile|master|v2022|ruby|rails|fatal|error'

find_latest_huginn_log() {
    find "$INSTALL_LOG_DIR" -maxdepth 1 -type f -name "$LOG_PATTERN" -printf '%T@ %p\n' 2>/dev/null |
        sort -nr |
        awk 'NR == 1 {sub(/^[^ ]+ /, ""); print}'
}

main() {
    local log_file="${1:-}"

    if [ -z "$log_file" ]; then
        log_file="$(find_latest_huginn_log)"
    fi

    if [ -z "$log_file" ] || [ ! -f "$log_file" ]; then
        echo -e "${RED}Kein Huginn-Installationslog gefunden.${NC}"
        echo -e "${YELLOW}Gesucht in:${NC} $INSTALL_LOG_DIR"
        echo -e "${YELLOW}Pattern:${NC} $LOG_PATTERN"
        exit 1
    fi

    echo -e "${GREEN}Neuester Huginn-Log:${NC} $log_file"
    echo
    echo -e "${YELLOW}Gefilterte Diagnose, letzte ${LINE_COUNT} Treffer:${NC}"
    grep -nE "$PATTERN" "$log_file" | tail -n "$LINE_COUNT" || {
        echo -e "${YELLOW}Keine Treffer fuer das Diagnosemuster gefunden. Zeige stattdessen die letzten ${LINE_COUNT} Logzeilen:${NC}"
        tail -n "$LINE_COUNT" "$log_file"
    }
}

main "$@"
