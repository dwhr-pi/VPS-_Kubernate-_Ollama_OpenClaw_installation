#!/bin/bash
# ==============================================================================
# HUGINN_UNINSTALL.SH - Deinstallation von Huginn
# ==============================================================================

set -euo pipefail

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/lib/common.sh"
init_tool_tracking "Huginn"

HUGINN_DIR="${HUGINN_DIR:-/opt/huginn}"
HUGINN_SYSTEMD_WEB_SERVICE="${HUGINN_SYSTEMD_WEB_SERVICE:-huginn-web.service}"
HUGINN_SYSTEMD_WORKER_SERVICE="${HUGINN_SYSTEMD_WORKER_SERVICE:-huginn-worker.service}"
HUGINN_UNINSTALL_ASSUME_YES="${HUGINN_UNINSTALL_ASSUME_YES:-false}"
HUGINN_RBENV_ROOT="${HUGINN_RBENV_ROOT:-$HOME/.rbenv-openclaw-huginn}"
HUGINN_USER_CONFIG_DIR="${HOME}/.openclaw_ultimate_user_data/huginn"
HUGINN_BACKUP_ROOT="${HOME}/.openclaw_ultimate_user_data/backups/huginn"
HUGINN_DROP_DATABASE="${HUGINN_DROP_DATABASE:-prompt}"
HUGINN_BACKUP_DATABASE="${HUGINN_BACKUP_DATABASE:-prompt}"
HUGINN_REMOVE_ADDITIONAL_COMPONENTS="${HUGINN_REMOVE_ADDITIONAL_COMPONENTS:-prompt}"
HUGINN_REMOVE_USER_CONFIG="${HUGINN_REMOVE_USER_CONFIG:-prompt}"

prompt_yes_no() {
    local prompt_text="$1"
    local default_answer="${2:-no}"
    local normalized_default="Nein"
    local answer=""

    if [ "$default_answer" = "yes" ]; then
        normalized_default="Ja"
    fi

    if [ "$HUGINN_UNINSTALL_ASSUME_YES" = "true" ]; then
        return 0
    fi

    if [ ! -t 0 ]; then
        [ "$default_answer" = "yes" ]
        return
    fi

    read -r -p "$prompt_text [ja/Nein] (Standard: ${normalized_default}): " answer
    case "$answer" in
        ja|JA|j|J|yes|YES|y|Y) return 0 ;;
        nein|NEIN|n|N|no|NO) return 1 ;;
        "") [ "$default_answer" = "yes" ] ;;
        *) [ "$default_answer" = "yes" ] ;;
    esac
}

resolve_huginn_env_file() {
    local candidate
    for candidate in \
        "$HUGINN_DIR/.env" \
        "$HUGINN_USER_CONFIG_DIR/.env.template"
    do
        if [ -f "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

read_huginn_env_value() {
    local key="$1"
    local env_file="${2:-}"
    [ -n "$env_file" ] || return 1
    python3 - "$env_file" "$key" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
key = sys.argv[2]
if not path.exists():
    raise SystemExit(1)
for raw in path.read_text(encoding="utf-8").splitlines():
    line = raw.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    current_key, value = line.split("=", 1)
    if current_key.strip() != key:
        continue
    cleaned = value.strip().strip('"').strip("'")
    print(cleaned)
    raise SystemExit(0)
raise SystemExit(1)
PY
}

backup_huginn_database_if_requested() {
    local env_file="$1"
    local adapter db_name db_user db_host db_port timestamp target_file

    case "$HUGINN_BACKUP_DATABASE" in
        yes) ;;
        no) return 0 ;;
        *)
            if ! prompt_yes_no "Soll die installierte Huginn-Datenbank vor der Deinstallation gesichert werden?" "yes"; then
                return 0
            fi
            ;;
    esac

    adapter="$(read_huginn_env_value "DATABASE_ADAPTER" "$env_file" 2>/dev/null || true)"
    db_name="$(read_huginn_env_value "DATABASE_NAME" "$env_file" 2>/dev/null || true)"
    db_user="$(read_huginn_env_value "DATABASE_USERNAME" "$env_file" 2>/dev/null || true)"
    db_host="$(read_huginn_env_value "DATABASE_HOST" "$env_file" 2>/dev/null || true)"
    db_port="$(read_huginn_env_value "DATABASE_PORT" "$env_file" 2>/dev/null || true)"

    if [ -z "$adapter" ] || [ -z "$db_name" ]; then
        echo -e "${YELLOW}Hinweis: Keine vollstaendige Huginn-Datenbankkonfiguration gefunden. Datenbank-Backup wird uebersprungen.${NC}"
        return 0
    fi

    mkdir -p "$HUGINN_BACKUP_ROOT"
    timestamp="$(date +%Y%m%d_%H%M%S)"

    case "$adapter" in
        mysql2)
            target_file="${HUGINN_BACKUP_ROOT}/huginn_mysql_${db_name}_${timestamp}.sql.gz"
            if ! command -v mysqldump >/dev/null 2>&1; then
                echo -e "${YELLOW}Hinweis: mysqldump ist nicht verfuegbar. Datenbank-Backup wird uebersprungen.${NC}"
                return 0
            fi
            MYSQL_PWD="$(read_huginn_env_value "DATABASE_PASSWORD" "$env_file" 2>/dev/null || true)" \
                mysqldump \
                    --single-transaction \
                    --routines \
                    --triggers \
                    --host="${db_host:-localhost}" \
                    --port="${db_port:-3306}" \
                    --user="${db_user:-huginn}" \
                    "$db_name" | gzip -c > "$target_file"
            ;;
        postgresql)
            target_file="${HUGINN_BACKUP_ROOT}/huginn_postgresql_${db_name}_${timestamp}.sql.gz"
            if ! command -v pg_dump >/dev/null 2>&1; then
                echo -e "${YELLOW}Hinweis: pg_dump ist nicht verfuegbar. Datenbank-Backup wird uebersprungen.${NC}"
                return 0
            fi
            PGPASSWORD="$(read_huginn_env_value "DATABASE_PASSWORD" "$env_file" 2>/dev/null || true)" \
                pg_dump \
                    --host="${db_host:-127.0.0.1}" \
                    --port="${db_port:-5432}" \
                    --username="${db_user:-huginn}" \
                    --format=plain \
                    "$db_name" | gzip -c > "$target_file"
            ;;
        *)
            echo -e "${YELLOW}Hinweis: Datenbank-Backup fuer Adapter ${adapter} ist derzeit nicht automatisiert. Ueberspringe Backup.${NC}"
            return 0
            ;;
    esac

    echo -e "${GREEN}Datenbank-Backup erstellt: ${target_file}${NC}"
}

drop_huginn_database_if_requested() {
    local env_file="$1"
    local adapter db_name db_user db_host db_port db_password
    local safe_db_name

    case "$HUGINN_DROP_DATABASE" in
        yes) ;;
        no) return 0 ;;
        *)
            if ! prompt_yes_no "Soll die installierte Huginn-Datenbank zusaetzlich geloescht werden?" "no"; then
                return 0
            fi
            ;;
    esac

    adapter="$(read_huginn_env_value "DATABASE_ADAPTER" "$env_file" 2>/dev/null || true)"
    db_name="$(read_huginn_env_value "DATABASE_NAME" "$env_file" 2>/dev/null || true)"
    db_user="$(read_huginn_env_value "DATABASE_USERNAME" "$env_file" 2>/dev/null || true)"
    db_host="$(read_huginn_env_value "DATABASE_HOST" "$env_file" 2>/dev/null || true)"
    db_port="$(read_huginn_env_value "DATABASE_PORT" "$env_file" 2>/dev/null || true)"
    db_password="$(read_huginn_env_value "DATABASE_PASSWORD" "$env_file" 2>/dev/null || true)"

    if [ -z "$adapter" ] || [ -z "$db_name" ]; then
        echo -e "${YELLOW}Hinweis: Keine vollstaendige Huginn-Datenbankkonfiguration gefunden. Datenbank-Loeschung wird uebersprungen.${NC}"
        return 0
    fi

    safe_db_name="${db_name//\`/}"

    case "$adapter" in
        mysql2)
            if ! command -v mysql >/dev/null 2>&1; then
                echo -e "${YELLOW}Hinweis: mysql-Client ist nicht verfuegbar. Datenbank-Loeschung wird uebersprungen.${NC}"
                return 0
            fi
            MYSQL_PWD="$db_password" mysql \
                --host="${db_host:-localhost}" \
                --port="${db_port:-3306}" \
                --user="${db_user:-huginn}" \
                -e "DROP DATABASE IF EXISTS \`${safe_db_name}\`;"
            ;;
        postgresql)
            if ! command -v psql >/dev/null 2>&1; then
                echo -e "${YELLOW}Hinweis: psql ist nicht verfuegbar. Datenbank-Loeschung wird uebersprungen.${NC}"
                return 0
            fi
            PGPASSWORD="$db_password" psql \
                --host="${db_host:-127.0.0.1}" \
                --port="${db_port:-5432}" \
                --username="${db_user:-huginn}" \
                --dbname="postgres" \
                -v ON_ERROR_STOP=1 \
                -c "DROP DATABASE IF EXISTS \"${safe_db_name}\";"
            ;;
        *)
            echo -e "${YELLOW}Hinweis: Datenbank-Loeschung fuer Adapter ${adapter} ist derzeit nicht automatisiert. Ueberspringe Loeschung.${NC}"
            return 0
            ;;
    esac

    echo -e "${GREEN}Huginn-Datenbank ${db_name} wurde geloescht.${NC}"
}

remove_huginn_additional_components_if_requested() {
    case "$HUGINN_REMOVE_ADDITIONAL_COMPONENTS" in
        yes) ;;
        no) return 0 ;;
        *)
            if ! prompt_yes_no "Sollen zusaetzliche lokale Huginn-Komponenten (z.B. rbenv-Ruby und lokale PostgreSQL-Pakete) mit entfernt werden?" "no"; then
                return 0
            fi
            ;;
    esac

    if [ -d "$HUGINN_RBENV_ROOT" ]; then
        echo -e "${YELLOW}Entferne Huginn-rbenv unter ${HUGINN_RBENV_ROOT}...${NC}"
        rm -rf "$HUGINN_RBENV_ROOT"
    fi

    if command -v apt-get >/dev/null 2>&1; then
        if dpkg -s postgresql >/dev/null 2>&1; then
            echo -e "${YELLOW}Entferne lokale PostgreSQL-Zusatzpakete, die typischerweise fuer Huginn genutzt werden...${NC}"
            sudo apt-get remove -y postgresql postgresql-contrib libpq-dev || true
            sudo apt-get autoremove -y || true
        fi
    fi
}

remove_huginn_user_config_if_requested() {
    case "$HUGINN_REMOVE_USER_CONFIG" in
        yes) ;;
        no) return 0 ;;
        *)
            if ! prompt_yes_no "Soll auch die Huginn-Benutzerkonfiguration unter ${HUGINN_USER_CONFIG_DIR} entfernt werden?" "no"; then
                return 0
            fi
            ;;
    esac

    if [ -d "$HUGINN_USER_CONFIG_DIR" ]; then
        rm -rf "$HUGINN_USER_CONFIG_DIR"
        echo -e "${GREEN}Huginn-Benutzerkonfiguration entfernt.${NC}"
    fi
}

echo -e "${BLUE}Starte Deinstallation von Huginn...${NC}"

if [ -f "$INSTALL_DIR/scripts/huginn_status.sh" ]; then
    echo -e "${YELLOW}Vor dem Loeschen wird der aktuelle Huginn-Stand angezeigt.${NC}"
    bash "$INSTALL_DIR/scripts/huginn_status.sh" || true
fi

if [ "$HUGINN_UNINSTALL_ASSUME_YES" != "true" ] && [ -t 0 ]; then
    echo
    read -r -p "Huginn jetzt wirklich deinstallieren? [ja/Nein]: " confirm_uninstall
    case "$confirm_uninstall" in
        ja|JA|j|J|yes|YES|y|Y)
            ;;
        *)
            echo -e "${YELLOW}Huginn-Deinstallation abgebrochen. Es wurde nichts geloescht.${NC}"
            exit 1
            ;;
    esac
fi

env_file=""
if env_file="$(resolve_huginn_env_file 2>/dev/null)"; then
    backup_huginn_database_if_requested "$env_file"
fi

if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
    echo -e "${YELLOW}Stoppe und entferne lokale Huginn-Dienste...${NC}"
    sudo systemctl disable --now "$HUGINN_SYSTEMD_WEB_SERVICE" "$HUGINN_SYSTEMD_WORKER_SERVICE" 2>/dev/null || true
    sudo rm -f "/etc/systemd/system/${HUGINN_SYSTEMD_WEB_SERVICE}" "/etc/systemd/system/${HUGINN_SYSTEMD_WORKER_SERVICE}"
    sudo systemctl daemon-reload
fi

if [ -d "$HUGINN_DIR" ]; then
    echo -e "${YELLOW}Lösche Huginn Verzeichnis $HUGINN_DIR...${NC}"
    sudo rm -rf "$HUGINN_DIR"
    echo -e "${GREEN}Huginn erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Huginn ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

if [ -n "$env_file" ]; then
    drop_huginn_database_if_requested "$env_file"
fi

remove_huginn_additional_components_if_requested
remove_huginn_user_config_if_requested

echo -e "${GREEN}Huginn Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed
