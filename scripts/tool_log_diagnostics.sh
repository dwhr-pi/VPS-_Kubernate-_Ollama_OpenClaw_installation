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
MAIL_SETTINGS_FILE="${MAIL_SETTINGS_FILE:-$USER_WORKSPACE_DIR/mail/mail_settings.env}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/mail_crypto.sh"
load_secure_mail_settings
LINE_COUNT="${LINE_COUNT:-220}"
TOOL_NAME=""
LOG_FILE=""
EMAIL_TO=""
EMAIL_MODE="ask"
MAIL_FROM="${MAIL_FROM:-}"
NO_COLOR="false"

PATTERN='Hinweis:|Warnung:|Fehler:|ERROR:|Error:|error|failed|fatal|rake aborted!|Traceback|Exception|LoadError|ArgumentError|ConnectionError|ECONNRESET|EAI_AGAIN|ERR_SOCKET_TIMEOUT|ELIFECYCLE|npm ERR|pnpm|bunx|bundle|Bundler|Gemfile|mysql2|postgresql|pg_ext|grpc|net-imap|net-pop|assets:precompile|systemd|service|port|permission denied|Permission denied|No such file|not found|syntax error|ruby|rails|python|node|docker|kubernetes|helm'

usage() {
    cat <<EOF
Tool-Logdiagnose

Nutzung:
  bash scripts/tool_log_diagnostics.sh
  bash scripts/tool_log_diagnostics.sh --tool Huginn
  bash scripts/tool_log_diagnostics.sh --log /pfad/zum/log.log
  bash scripts/tool_log_diagnostics.sh --tool Huginn --email
  bash scripts/tool_log_diagnostics.sh --log /pfad/zum/log.log --email-now
  bash scripts/tool_log_diagnostics.sh --tool Huginn --no-email

Fuer mehrere Logs eines Installationslaufs:
  bash scripts/install_run_diagnostics.sh
  bash scripts/last_install_log.sh --failed
  bash scripts/last_install_log.sh --snapshot

Optionen:
  --tool NAME       Toolname im Lognamen, z. B. Huginn, Clawhub_CLI, OpenManus
  --log PFAD        konkreten Log auswerten
  --email [ADRESSE] nach Terminalausgabe E-Mail-Versand anbieten
  --email-now [ADRESSE]
                   Diagnosebericht ohne weitere Rueckfrage senden
                   Ohne ADRESSE wird die lokal verschluesselte Config genutzt.
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
                if [ "${2:-}" != "" ] && [[ "${2:-}" != --* ]]; then
                    EMAIL_TO="$2"
                    shift 2
                else
                    EMAIL_TO="${DEFAULT_EMAIL_TO:-}"
                    shift
                fi
                EMAIL_MODE="ask"
                ;;
            --email-now|--send-email)
                if [ "${2:-}" != "" ] && [[ "${2:-}" != --* ]]; then
                    EMAIL_TO="$2"
                    shift 2
                else
                    EMAIL_TO="${DEFAULT_EMAIL_TO:-}"
                    shift
                fi
                EMAIL_MODE="always"
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

redact_sensitive_output() {
    sed -E \
        -e 's/(set-cookie:[[:space:]]*)[^[:space:];]+([^[:space:]]*)/\1[REDACTED_COOKIE]/Ig' \
        -e 's/(cookie:[[:space:]]*)[^[:space:]]+/\1[REDACTED_COOKIE]/Ig' \
        -e 's/([?&](token|key|secret|password|passwd|api_key)=)[^&[:space:]]+/\1[REDACTED]/Ig' \
        -e 's/((token|secret|password|passwd|api_key)[=:][[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig'
}

create_report() {
    local log_file="$1"
    local report_file="$2"
    local report_id="$3"
    local found_matches="true"

    mkdir -p "$REPORT_DIR"

    {
        echo "# Tool-Logdiagnose"
        echo
        echo "- Datum: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "- Produkt: $OPENCLAW_PRODUCT_ID"
        echo "- Report-ID: $report_id"
        echo "- Tool: ${TOOL_NAME:-automatisch / alle Tools}"
        echo "- Log-Datei: $(basename "$log_file")"
        echo "- Log: $log_file"
        echo "- Install-Log-Verzeichnis: $INSTALL_LOG_DIR"
        echo
        echo "## Gefilterte Diagnose"
        echo
    } > "$report_file"

    if grep -nE "$PATTERN" "$log_file" | tail -n "$LINE_COUNT" | redact_sensitive_output >> "$report_file"; then
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
            tail -n "$LINE_COUNT" "$log_file" | redact_sensitive_output
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
    local report_id="$3"
    local subject
    local from_header=()

    subject="[OpenClaw Ultimate Setup][Tool:${TOOL_NAME:-all_tools}][Report:${report_id}] Tool-Logdiagnose $(date '+%Y-%m-%d %H:%M')"

    load_secure_mail_settings

    if [ -n "${MAIL_FROM:-}" ]; then
        from_header=("From: ${MAIL_FROM}")
    fi

    if command -v msmtp >/dev/null 2>&1 && [ -n "${MAIL_FROM:-}" ]; then
        {
            printf 'From: %s\n' "$MAIL_FROM"
            printf 'To: %s\n' "$recipient"
            printf 'Subject: %s\n' "$subject"
            printf 'Content-Type: text/plain; charset=UTF-8\n'
            printf '\n'
            cat "$report_file"
        } | msmtp -a "${MSMTP_ACCOUNT:-default}" -f "$MAIL_FROM" "$recipient"
        return $?
    fi

    if command -v mail >/dev/null 2>&1; then
        if [ -n "${MAIL_FROM:-}" ]; then
            mail -r "$MAIL_FROM" -s "$subject" "$recipient" < "$report_file"
        else
            mail -s "$subject" "$recipient" < "$report_file"
        fi
        return $?
    fi

    if command -v sendmail >/dev/null 2>&1; then
        {
            if [ ${#from_header[@]} -gt 0 ]; then
                echo "${from_header[0]}"
            fi
            echo "To: $recipient"
            echo "Subject: $subject"
            echo "Content-Type: text/plain; charset=UTF-8"
            echo
            cat "$report_file"
        } | sendmail -t
        return $?
    fi

    echo -e "${YELLOW}E-Mail-Versand nicht moeglich: weder 'msmtp', 'mail' noch 'sendmail' passend nutzbar.${NC}"
    echo -e "${YELLOW}Installiere Mail_Utils_MSMTP und setze lokal MAIL_FROM in ${MAIL_SETTINGS_FILE}.${NC}"
    return 1
}

maybe_send_email() {
    local report_file="$1"
    local report_id="$2"
    load_secure_mail_settings

    local recipient="${EMAIL_TO:-${DEFAULT_EMAIL_TO:-}}"
    local answer

    if [ "$EMAIL_MODE" = "never" ]; then
        return 0
    fi

    if [ -z "$recipient" ]; then
        echo -e "${YELLOW}Kein Diagnose-Empfaenger konfiguriert. Nutze 'E-Mail-Diagnose Konfiguration' im Setup-Menue.${NC}"
        echo -e "${YELLOW}Bericht bleibt lokal:${NC} $report_file"
        return 0
    fi

    if [ "$EMAIL_MODE" = "always" ]; then
        if send_report_email "$report_file" "$recipient" "$report_id"; then
            echo -e "${GREEN}Diagnosebericht wurde an ${recipient} uebergeben.${NC}"
        else
            echo -e "${YELLOW}Diagnosebericht konnte nicht per E-Mail versendet werden. Datei bleibt lokal erhalten:${NC} $report_file"
        fi
        return 0
    fi

    echo
    read -r -p "Diagnosebericht per E-Mail an ${recipient} senden? [j/N]: " answer || true
    case "$answer" in
        j|J|ja|JA|yes|YES|y|Y)
            if send_report_email "$report_file" "$recipient" "$report_id"; then
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
    local report_file timestamp safe_name inferred_tool report_id

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

    if [ -z "$TOOL_NAME" ]; then
        inferred_tool="$(infer_tool_name_from_log_path "$LOG_FILE")"
        TOOL_NAME="${inferred_tool:-}"
    fi

    timestamp="$(date '+%Y%m%d_%H%M%S')"
    safe_name="$(safe_report_name)"
    report_id="$(make_diagnostic_report_id "${TOOL_NAME:-all_tools}" "$timestamp")"
    report_file="$REPORT_DIR/${timestamp}_${safe_name}_diagnostics.md"

    echo -e "${GREEN}Ausgewerteter Log:${NC} $LOG_FILE"
    echo -e "${GREEN}Report-ID:${NC} $report_id"
    create_report "$LOG_FILE" "$report_file" "$report_id"
    print_report "$report_file"
    maybe_send_email "$report_file" "$report_id"
}

main "$@"
