#!/bin/bash
# ==============================================================================
# TOOL_LOG_DIAGNOSTICS.SH - Generische Diagnose fuer Tool-Installationslogs
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-$HOME/.openclaw_ultimate_user_data}"
INSTALL_LOG_DIR="${INSTALL_LOG_DIR:-$USER_WORKSPACE_DIR/install_logs}"
REPORT_DIR="${REPORT_DIR:-$USER_WORKSPACE_DIR/diagnostic_reports}"
DEFAULT_EMAIL_TO="${DEFAULT_EMAIL_TO:-ai-chat-to-markdown@web.de}"
LINE_COUNT="${LINE_COUNT:-220}"
TOOL_NAME=""
LOG_FILE=""
EMAIL_TO=""
EMAIL_MODE="ask"
NO_COLOR="false"

PATTERN='Hinweis:|Warnung:|Fehler:|ERROR:|Error:|error|failed|fatal|rake aborted!|Traceback|Exception|LoadError|ArgumentError|ConnectionError|ECONNRESET|EAI_AGAIN|ERR_SOCKET_TIMEOUT|ELIFECYCLE|npm ERR|pnpm|bunx|bundle|Bundler|Gemfile|mysql2|postgresql|pg_ext|grpc|net-imap|net-pop|assets:precompile|systemd|service|port|permission denied|Permission denied|No such file|not found|syntax error|ruby|rails|python|node|docker|kubernetes|helm'

usage() {
    cat <<EOF
Tool-Logdiagnose

Nutzung:
  bash scripts/tool_log_diagnostics.sh
  bash scripts/tool_log_diagnostics.sh --tool Huginn
  bash scripts/tool_log_diagnostics.sh --log /pfad/zum/log.log
  bash scripts/tool_log_diagnostics.sh --tool Huginn --email ai-chat-to-markdown@web.de
  bash scripts/tool_log_diagnostics.sh --tool Huginn --no-email

Optionen:
  --tool NAME       Toolname im Lognamen, z. B. Huginn, Clawhub_CLI, OpenManus
  --log PFAD        konkreten Log auswerten
  --email ADRESSE   nach Terminalausgabe E-Mail-Versand an Adresse anbieten
  --no-email        keine E-Mail-Abfrage
  --lines ZAHL      Anzahl gefilterter Treffer
  --no-color        Ausgabe ohne ANSI-Farben
  --help            Hilfe anzeigen
EOF
}

strip_colors_if_needed() {
    if [ "$NO_COLOR" = "true" ]; then
        GREEN=""
        YELLOW=""
        RED=""
        NC=""
    fi
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --tool)
                TOOL_NAME="${2:-}"
                shift 2
                ;;
            --log)
                LOG_FILE="${2:-}"
                shift 2
                ;;
            --email)
                EMAIL_TO="${2:-$DEFAULT_EMAIL_TO}"
                EMAIL_MODE="ask"
                shift 2
                ;;
            --no-email)
                EMAIL_MODE="never"
                shift
                ;;
            --lines)
                LINE_COUNT="${2:-220}"
                shift 2
                ;;
            --no-color)
                NO_COLOR="true"
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                if [ -z "$LOG_FILE" ] && { [ -f "$1" ] || [[ "$1" == *.log ]]; }; then
                    LOG_FILE="$1"
                elif [ -z "$TOOL_NAME" ]; then
                    TOOL_NAME="$1"
                else
                    echo -e "${RED}Unbekanntes Argument:${NC} $1"
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

find_latest_log() {
    local pattern

    if [ -n "$TOOL_NAME" ]; then
        pattern="*${TOOL_NAME}*.log"
    else
        pattern="*.log"
    fi

    find "$INSTALL_LOG_DIR" -maxdepth 1 -type f -name "$pattern" -printf '%T@ %p\n' 2>/dev/null |
        sort -nr |
        awk 'NR == 1 {sub(/^[^ ]+ /, ""); print}'
}

safe_report_name() {
    local base
    base="${TOOL_NAME:-all_tools}"
    printf '%s' "$base" | tr -cs '[:alnum:]_.-' '_'
}

create_report() {
    local log_file="$1"
    local report_file="$2"
    local found_matches="true"

    mkdir -p "$REPORT_DIR"

    {
        echo "# Tool-Logdiagnose"
        echo
        echo "- Datum: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "- Tool: ${TOOL_NAME:-automatisch / alle Tools}"
        echo "- Log: $log_file"
        echo "- Install-Log-Verzeichnis: $INSTALL_LOG_DIR"
        echo
        echo "## Gefilterte Diagnose"
        echo
    } > "$report_file"

    if grep -nE "$PATTERN" "$log_file" | tail -n "$LINE_COUNT" >> "$report_file"; then
        found_matches="true"
    else
        found_matches="false"
    fi

    if [ "$found_matches" != "true" ] || ! grep -q '[^[:space:]]' "$report_file"; then
        {
            echo
            echo "Keine Treffer fuer das Diagnosemuster gefunden."
            echo
            echo "## Letzte Logzeilen"
            echo
            tail -n "$LINE_COUNT" "$log_file"
        } >> "$report_file"
    fi
}

print_report() {
    local report_file="$1"
    echo -e "${YELLOW}Diagnosebericht:${NC} $report_file"
    echo
    sed -n '/^## Gefilterte Diagnose/,$p' "$report_file"
}

send_report_email() {
    local report_file="$1"
    local recipient="$2"
    local subject

    subject="[OpenClaw Setup] Tool-Logdiagnose ${TOOL_NAME:-all_tools} $(date '+%Y-%m-%d %H:%M')"

    if command -v mail >/dev/null 2>&1; then
        mail -s "$subject" "$recipient" < "$report_file"
        return $?
    fi

    if command -v sendmail >/dev/null 2>&1; then
        {
            echo "To: $recipient"
            echo "Subject: $subject"
            echo "Content-Type: text/plain; charset=UTF-8"
            echo
            cat "$report_file"
        } | sendmail -t
        return $?
    fi

    echo -e "${YELLOW}E-Mail-Versand nicht moeglich: weder 'mail' noch 'sendmail' gefunden.${NC}"
    echo -e "${YELLOW}Installiere und konfiguriere z. B. mailutils/msmtp, ohne Zugangsdaten ins Repo zu schreiben.${NC}"
    return 1
}

maybe_send_email() {
    local report_file="$1"
    local recipient="${EMAIL_TO:-$DEFAULT_EMAIL_TO}"
    local answer

    if [ "$EMAIL_MODE" = "never" ]; then
        return 0
    fi

    echo
    read -r -p "Diagnosebericht per E-Mail an ${recipient} senden? [j/N]: " answer || true
    case "$answer" in
        j|J|ja|JA|yes|YES|y|Y)
            if send_report_email "$report_file" "$recipient"; then
                echo -e "${GREEN}Diagnosebericht wurde an ${recipient} uebergeben.${NC}"
            else
                echo -e "${YELLOW}Diagnosebericht konnte nicht per E-Mail versendet werden. Datei bleibt lokal erhalten:${NC} $report_file"
            fi
            ;;
        *)
            echo -e "${YELLOW}E-Mail-Versand uebersprungen. Bericht bleibt lokal:${NC} $report_file"
            ;;
    esac
}

main() {
    local report_file timestamp safe_name

    parse_args "$@"
    strip_colors_if_needed

    if [ -z "$LOG_FILE" ]; then
        LOG_FILE="$(find_latest_log)"
    fi

    if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
        if [ -n "${1:-}" ]; then
            echo -e "${YELLOW}Angegebener Log nicht gefunden oder kein passender Log vorhanden.${NC}"
            echo -e "${YELLOW}Versuche automatisch den neuesten passenden Log zu finden...${NC}"
            LOG_FILE="$(find_latest_log)"
        fi
    fi

    if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
        echo -e "${RED}Kein passender Installationslog gefunden.${NC}"
        echo -e "${YELLOW}Gesucht in:${NC} $INSTALL_LOG_DIR"
        echo -e "${YELLOW}Tool:${NC} ${TOOL_NAME:-alle}"
        exit 1
    fi

    timestamp="$(date '+%Y%m%d_%H%M%S')"
    safe_name="$(safe_report_name)"
    report_file="$REPORT_DIR/${timestamp}_${safe_name}_diagnostics.md"

    echo -e "${GREEN}Ausgewerteter Log:${NC} $LOG_FILE"
    create_report "$LOG_FILE" "$report_file"
    print_report "$report_file"
    maybe_send_email "$report_file"
}

main "$@"
