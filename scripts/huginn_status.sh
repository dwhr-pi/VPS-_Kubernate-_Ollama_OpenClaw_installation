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
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
HUGINN_USER_SETTINGS_FILE="${USER_WORKSPACE_DIR}/huginn/install_settings.env"
HUGINN_LATEST_INSTALL_LOG_PATTERN="${USER_WORKSPACE_DIR}/install_logs/*tool_install_Huginn.log"
HUGINN_LATEST_ANY_LOG_PATTERN="${USER_WORKSPACE_DIR}/install_logs/*Huginn*.log"

print_header() {
    echo
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

redact_sensitive_output() {
    sed -E \
        -e 's/(set-cookie:[[:space:]]*)[^[:space:];]+([^[:space:]]*)/\1[REDACTED_COOKIE]/Ig' \
        -e 's/(cookie:[[:space:]]*)[^[:space:]]+/\1[REDACTED_COOKIE]/Ig' \
        -e 's/([?&](token|key|secret|password|passwd|api_key)=)[^&[:space:]]+/\1[REDACTED]/Ig' \
        -e 's/((token|secret|password|passwd|api_key)[=:][[:space:]]*)[^[:space:]]+/\1[REDACTED]/Ig'
}

read_env_value() {
    local key="$1"
    local file_path="$2"
    awk -F= -v key="$key" '$1 == key {print $2}' "$file_path" 2>/dev/null | tail -n 1 | tr -d '\r" '
}

detect_huginn_git_ref() {
    if [ ! -d "$HUGINN_DIR/.git" ]; then
        echo "nicht installiert"
        return 0
    fi

    local branch exact_tag describe commit
    branch="$(git -C "$HUGINN_DIR" branch --show-current 2>/dev/null || true)"
    exact_tag="$(git -C "$HUGINN_DIR" describe --tags --exact-match 2>/dev/null || true)"
    describe="$(git -C "$HUGINN_DIR" describe --tags --always --dirty 2>/dev/null || true)"
    commit="$(git -C "$HUGINN_DIR" rev-parse --short HEAD 2>/dev/null || true)"

    if [ -n "$exact_tag" ]; then
        echo "$exact_tag"
    elif [ -n "$branch" ]; then
        echo "$branch (${commit})"
    elif [ -n "$describe" ]; then
        echo "$describe"
    else
        echo "unbekannt"
    fi
}

detect_latest_huginn_log() {
    # shellcheck disable=SC2086
    ls -1t $HUGINN_LATEST_INSTALL_LOG_PATTERN 2>/dev/null | head -n 1 || true
}

detect_latest_any_huginn_log() {
    # shellcheck disable=SC2086
    ls -1t $HUGINN_LATEST_ANY_LOG_PATTERN 2>/dev/null | head -n 1 || true
}

print_detected_problem_class() {
    local installed_ref="$1"
    local db_adapter="$2"
    local latest_log="$3"
    local planned_ref="${4:-}"
    local planned_adapter="${5:-}"

    echo
    echo -e "${YELLOW}Erkannte Problemklasse:${NC}"

    if [ "$installed_ref" = "v2022.08.18" ] && [ "$db_adapter" = "postgresql" ]; then
        echo -e "${RED}v2022.08.18 + PostgreSQL erkannt.${NC}"
        echo -e "${YELLOW}Dieser Pfad kann unter Ruby 3.2 am alten pg-Gem scheitern: pg_ext.so / rb_tainted_str_new.${NC}"
        echo -e "${YELLOW}Der Installer versucht diesen Pfad jetzt mit HUGINN_ENABLE_PG_RUBY32_COMPAT=true automatisch ueber einen neueren pg-Gem-Zweig zu reparieren.${NC}"
        echo -e "${YELLOW}Fuer unser stabiles Setup bleibt MySQL/MariaDB die Empfehlung; PostgreSQL ist hier ein bewusster Original-/Upstream-Test.${NC}"
        return 0
    fi

    if [ "$installed_ref" = "nicht installiert" ] && [ "$planned_ref" = "v2022.08.18" ] && [ "$planned_adapter" = "postgresql" ]; then
        echo -e "${YELLOW}Aktuell nicht installiert, aber geplante Benutzerkonfiguration ist v2022.08.18 + PostgreSQL.${NC}"
        echo -e "${YELLOW}Das passt zu deinem beschriebenen pg_ext/rb_tainted_str_new-Fehlerbild.${NC}"
        return 0
    fi

    if [ "$installed_ref" = "v2022.08.18" ] && [ "$db_adapter" = "mysql2" ]; then
        echo -e "${GREEN}v2022.08.18 + MySQL/MariaDB erkannt. Das ist die empfohlene stabile Setup-Kombination.${NC}"
        return 0
    fi

    if printf '%s' "$installed_ref" | grep -q '^master'; then
        echo -e "${YELLOW}master erkannt. Das ist der experimentellere Upstream-Pfad mit eigener Ruby-/Bundler-Dynamik.${NC}"
        echo -e "${YELLOW}Wenn PostgreSQL gesetzt ist, ist das ein sinnvoller Original-/Upstream-Testpfad.${NC}"
        return 0
    fi

    if [ -n "$latest_log" ] && grep -Eq 'pg_ext\.so: undefined symbol: rb_tainted_str_new|DATABASE_ADAPTER=postgresql' "$latest_log" 2>/dev/null; then
        echo -e "${YELLOW}Letzter Log enthaelt PostgreSQL/pg_ext-Hinweise. Bitte Logdetails pruefen: ${latest_log}${NC}"
        return 0
    fi

    echo "Keine bekannte Huginn-Problemklasse eindeutig erkannt."
}

print_header "Huginn Status"

if [ -d "$HUGINN_DIR/.git" ]; then
    echo -e "${GREEN}Repository:${NC} $HUGINN_DIR"
    git -C "$HUGINN_DIR" --no-pager log -1 --oneline || true
    installed_ref="$(detect_huginn_git_ref)"
    echo -e "${YELLOW}Aktiver Git-Ref:${NC} ${installed_ref}"
    echo -e "${YELLOW}Exakter Tag:${NC} $(git -C "$HUGINN_DIR" describe --tags --exact-match 2>/dev/null || echo 'kein exakter Tag / Branch oder Commit')"
else
    echo -e "${RED}Huginn Repository nicht gefunden:${NC} $HUGINN_DIR"
    installed_ref="nicht installiert"
fi

echo
echo -e "${YELLOW}Datenbankadapter:${NC}"
if [ -f "$HUGINN_DIR/.env" ]; then
    grep -E '^(DATABASE_ADAPTER|DATABASE_NAME|DATABASE_HOST|DATABASE_PORT)=' "$HUGINN_DIR/.env" || true
    db_adapter="$(read_env_value "DATABASE_ADAPTER" "$HUGINN_DIR/.env")"
else
    echo "Keine .env unter $HUGINN_DIR gefunden."
    db_adapter=""
fi

echo
echo -e "${YELLOW}Geplante Benutzerkonfiguration:${NC}"
planned_ref=""
planned_adapter=""
if [ -f "$HUGINN_USER_SETTINGS_FILE" ]; then
    grep -E '^(HUGINN_REPO_REF|HUGINN_DATABASE_ADAPTER)=' "$HUGINN_USER_SETTINGS_FILE" || true
    planned_ref="$(read_env_value "HUGINN_REPO_REF" "$HUGINN_USER_SETTINGS_FILE")"
    planned_adapter="$(read_env_value "HUGINN_DATABASE_ADAPTER" "$HUGINN_USER_SETTINGS_FILE")"
else
    echo "Keine Benutzer-Installationswerte gefunden: $HUGINN_USER_SETTINGS_FILE"
fi

latest_log="$(detect_latest_huginn_log)"
latest_any_log="$(detect_latest_any_huginn_log)"
echo
echo -e "${YELLOW}Neuester Huginn-Installationslog:${NC} ${latest_log:-keiner gefunden}"
echo -e "${YELLOW}Neuester Huginn-Log gesamt:${NC} ${latest_any_log:-keiner gefunden}"
if [ -n "$latest_log" ]; then
    grep -nE 'Standard-Referenz:|Huginn Datenbankauswahl|Huginn Debug: DB_ADAPTER|pg_ext\.so|rb_tainted_str_new|DATABASE_ADAPTER=postgresql|DATABASE_ADAPTER=mysql2|Fehler:|LoadError:' "$latest_log" 2>/dev/null | tail -n 30 || true
fi

print_detected_problem_class "$installed_ref" "$db_adapter" "$latest_log" "$planned_ref" "$planned_adapter"

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
        redact_sensitive_output < /tmp/huginn_status_headers
    else
        echo -e "${YELLOW}Noch keine erfolgreiche HTTP-Antwort auf Port ${HUGINN_WEB_PORT}.${NC}"
        redact_sensitive_output < /tmp/huginn_status_error 2>/dev/null || true
    fi
else
    echo "curl ist nicht installiert."
fi

rm -f /tmp/huginn_status_headers /tmp/huginn_status_error
