#!/bin/bash
# ==============================================================================
# HUGINN_CONFIG_MANAGER.SH - Verwaltet Huginn-.env und Installationsauswahl
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
HUGINN_TEMPLATE_DIR="$USER_WORKSPACE_DIR/huginn"
HUGINN_TEMPLATE_FILE="$HUGINN_TEMPLATE_DIR/.env.template"
HUGINN_SETTINGS_FILE="$HUGINN_TEMPLATE_DIR/install_settings.env"
HUGINN_REPO_TEMPLATE_FILE="$INSTALL_DIR/scripts/config_templates/huginn/.env.template"
HUGINN_INSTALL_DIR="${HUGINN_INSTALL_DIR:-/opt/huginn}"
HUGINN_RUNTIME_ENV="$HUGINN_INSTALL_DIR/.env"

TMP_PREFIX="${TMPDIR:-/tmp}/openclaw_huginn_config"
HUGINN_CONFIG_CHOICE_FILE="${TMP_PREFIX}_choice"
HUGINN_REF_CHOICE_FILE="${TMP_PREFIX}_ref_choice"
HUGINN_REF_INPUT_FILE="${TMP_PREFIX}_ref_input"
HUGINN_DB_CHOICE_FILE="${TMP_PREFIX}_db_choice"

ensure_user_workspace() {
    mkdir -p "$HUGINN_TEMPLATE_DIR"

    if [ ! -f "$HUGINN_TEMPLATE_FILE" ]; then
        if [ -f "$HUGINN_REPO_TEMPLATE_FILE" ]; then
            cp "$HUGINN_REPO_TEMPLATE_FILE" "$HUGINN_TEMPLATE_FILE"
        else
            cat > "$HUGINN_TEMPLATE_FILE" <<'EOF'
# Huginn .env.template
# Diese Datei liegt absichtlich im Benutzer-Workspace.
# Keine echten Secrets ins Git-Repository schreiben.

RAILS_ENV=production
DATABASE_ADAPTER=mysql2
DATABASE_NAME=huginn_production
DATABASE_USERNAME=huginn
DATABASE_PASSWORD=huginn_local_change_me
DATABASE_HOST=localhost
DATABASE_PORT=3306
INVITATION_CODE=change-me
APP_SECRET_TOKEN=change-me-generate-secure-token
EOF
        fi
        chmod 600 "$HUGINN_TEMPLATE_FILE" 2>/dev/null || true
    fi

    if [ ! -f "$HUGINN_SETTINGS_FILE" ]; then
        cat > "$HUGINN_SETTINGS_FILE" <<'EOF'
HUGINN_REPO_REF=v2022.08.18
HUGINN_DATABASE_ADAPTER=mysql2
EOF
        chmod 600 "$HUGINN_SETTINGS_FILE" 2>/dev/null || true
    fi
}

cleanup_temp_files() {
    rm -f "$HUGINN_CONFIG_CHOICE_FILE" "$HUGINN_REF_CHOICE_FILE" "$HUGINN_REF_INPUT_FILE" "$HUGINN_DB_CHOICE_FILE"
}

pause_screen() {
    read -r -p "Druecken Sie Enter..." || true
}

dialog_available() {
    command -v dialog >/dev/null 2>&1
}

dialog_has_no_mouse() {
    dialog_available && dialog --help 2>&1 | grep -q -- '--no-mouse'
}

dialog_common_args() {
    if dialog_has_no_mouse; then
        printf '%s\n' "--no-mouse"
    fi
}

reset_terminal_state() {
    tput sgr0 2>/dev/null || true
    if [ -t 0 ]; then
        stty sane 2>/dev/null || true
    fi
}

dialog_begin_args() {
    local height="$1"
    local width="$2"
    local lines cols row col

    lines="$(tput lines 2>/dev/null || printf '24')"
    cols="$(tput cols 2>/dev/null || printf '80')"
    case "$lines" in ''|*[!0-9]*) lines=24 ;; esac
    case "$cols" in ''|*[!0-9]*) cols=80 ;; esac

    row=$(( (lines - height) / 2 ))
    col=$(( (cols - width) / 2 ))
    [ "$row" -lt 0 ] && row=0
    [ "$col" -lt 0 ] && col=0

    printf '%s %s\n' "$row" "$col"
}

read_setting_value() {
    local key="$1"
    local file_path="$2"
    awk -F= -v key="$key" '$1 == key {print $2}' "$file_path" 2>/dev/null | tail -n 1 | tr -d '\r" '
}

current_huginn_repo_ref() {
    ensure_user_workspace
    read_setting_value "HUGINN_REPO_REF" "$HUGINN_SETTINGS_FILE"
}

current_huginn_database_adapter() {
    ensure_user_workspace
    read_setting_value "DATABASE_ADAPTER" "$HUGINN_TEMPLATE_FILE"
}

save_setting() {
    local key="$1"
    local value="$2"
    local file_path="$3"

    ensure_user_workspace
    python3 - "$key" "$value" "$file_path" <<'PY'
from pathlib import Path
import sys

key, value, raw_path = sys.argv[1], sys.argv[2], sys.argv[3]
path = Path(raw_path)
text = path.read_text(encoding="utf-8") if path.exists() else ""
lines = text.splitlines()
new_line = f"{key}={value}"
updated = False

for index, line in enumerate(lines):
    if line.startswith(f"{key}="):
        lines[index] = new_line
        updated = True

if not updated:
    lines.append(new_line)

path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
PY
    chmod 600 "$file_path" 2>/dev/null || true
}

save_huginn_repo_ref() {
    save_setting "HUGINN_REPO_REF" "$1" "$HUGINN_SETTINGS_FILE"
}

save_huginn_install_setting() {
    save_setting "$1" "$2" "$HUGINN_SETTINGS_FILE"
}

apply_huginn_database_template_preset() {
    local adapter="$1"

    ensure_user_workspace
    python3 - "$adapter" "$HUGINN_TEMPLATE_FILE" <<'PY'
from pathlib import Path
import sys

adapter = sys.argv[1]
path = Path(sys.argv[2])
text = path.read_text(encoding="utf-8") if path.exists() else ""
db_keys = {
    "DATABASE_ADAPTER",
    "DATABASE_NAME",
    "DATABASE_USERNAME",
    "DATABASE_PASSWORD",
    "DATABASE_HOST",
    "DATABASE_PORT",
}

presets = {
    "mysql2": {
        "DATABASE_ADAPTER": "mysql2",
        "DATABASE_NAME": "huginn_production",
        "DATABASE_USERNAME": "huginn",
        "DATABASE_PASSWORD": "huginn_local_change_me",
        "DATABASE_HOST": "localhost",
        "DATABASE_PORT": "3306",
    },
    "postgresql": {
        "DATABASE_ADAPTER": "postgresql",
        "DATABASE_NAME": "huginn_production",
        "DATABASE_USERNAME": "huginn",
        "DATABASE_PASSWORD": "change-me",
        "DATABASE_HOST": "127.0.0.1",
        "DATABASE_PORT": "5432",
    },
}

if adapter not in presets:
    raise SystemExit(f"Unsupported database adapter preset: {adapter}")

kept_lines = []
for line in text.splitlines():
    if line.strip() == "### Database":
        continue
    if "=" in line and not line.lstrip().startswith("#"):
        key = line.split("=", 1)[0].strip()
        if key in db_keys:
            continue
    kept_lines.append(line)

if kept_lines and kept_lines[-1].strip():
    kept_lines.append("")
kept_lines.append("### Database")
for key, value in presets[adapter].items():
    kept_lines.append(f"{key}={value}")

path.write_text("\n".join(kept_lines).rstrip() + "\n", encoding="utf-8")
PY
    chmod 600 "$HUGINN_TEMPLATE_FILE" 2>/dev/null || true
}

choose_huginn_repo_ref_cli() {
    local selected_ref

    echo
    echo "Huginn-Upstream-Stand"
    echo "1) v2022.08.18 (empfohlen)"
    echo "2) GitHub master (aktueller Upstream, kann brechen)"
    echo "3) Andere Referenz / Tag / Commit-SHA"
    read -r -p "Auswahl [1-3]: " selected_ref

    case "$selected_ref" in
        1|"") save_huginn_repo_ref "v2022.08.18" ;;
        2) save_huginn_repo_ref "master" ;;
        3)
            read -r -p "Huginn-Referenz: " selected_ref
            if [ -z "$selected_ref" ]; then
                echo -e "${RED}Fehler: Die Huginn-Referenz darf nicht leer sein.${NC}"
                return 1
            fi
            save_huginn_repo_ref "$selected_ref"
            ;;
        *) return 1 ;;
    esac
}

choose_huginn_repo_ref() {
    ensure_user_workspace

    if ! dialog_available; then
        choose_huginn_repo_ref_cli
        return $?
    fi

    local current_ref selected_ref custom_ref begin_row begin_col ref_v2022_state ref_master_state ref_custom_state
    local dialog_mouse_args=()

    current_ref="$(current_huginn_repo_ref)"
    [ -n "$current_ref" ] || current_ref="v2022.08.18"

    ref_v2022_state="off"
    ref_master_state="off"
    ref_custom_state="off"
    case "$current_ref" in
        v2022.08.18) ref_v2022_state="on" ;;
        master) ref_master_state="on" ;;
        *) ref_custom_state="on" ;;
    esac

    read -r begin_row begin_col <<<"$(dialog_begin_args 16 82)"
    mapfile -t dialog_mouse_args < <(dialog_common_args)

    rm -f "$HUGINN_REF_CHOICE_FILE"
    reset_terminal_state
    if ! dialog --clear "${dialog_mouse_args[@]}" --backtitle "OpenClaw Ultimate Setup" \
        --begin "$begin_row" "$begin_col" \
        --cancel-label "Zurueck" \
        --title "HUGINN UPSTREAM-STAND" --radiolist \
        "Waehlen Sie den Huginn-Stand.\n\nEmpfohlen: v2022.08.18\nAktuell: ${current_ref}" \
        16 82 5 \
        "1" "v2022.08.18 (empfohlen, stabiler Stand)" "$ref_v2022_state" \
        "2" "GitHub master (aktueller Upstream, kann brechen)" "$ref_master_state" \
        "3" "Andere Referenz / Tag / Commit-SHA" "$ref_custom_state" \
        2> "$HUGINN_REF_CHOICE_FILE"; then
        reset_terminal_state
        return 1
    fi
    reset_terminal_state

    selected_ref="$(tr -d '\r" ' < "$HUGINN_REF_CHOICE_FILE" 2>/dev/null || true)"
    case "$selected_ref" in
        1) save_huginn_repo_ref "v2022.08.18" ;;
        2) save_huginn_repo_ref "master" ;;
        3)
            rm -f "$HUGINN_REF_INPUT_FILE"
            if ! dialog --clear "${dialog_mouse_args[@]}" --backtitle "OpenClaw Ultimate Setup" \
                --begin "$begin_row" "$begin_col" \
                --cancel-label "Zurueck" \
                --title "HUGINN REPO REF" \
                --inputbox "Geben Sie eine Huginn-Referenz ein, z. B. Tag, Branch oder Commit-SHA:" \
                10 100 "$current_ref" 2> "$HUGINN_REF_INPUT_FILE"; then
                reset_terminal_state
                return 1
            fi
            reset_terminal_state
            custom_ref="$(tr -d '\r' < "$HUGINN_REF_INPUT_FILE" 2>/dev/null || true)"
            if [ -z "$custom_ref" ]; then
                echo -e "${RED}Fehler: Die Huginn-Referenz darf nicht leer sein.${NC}"
                pause_screen
                return 1
            fi
            save_huginn_repo_ref "$custom_ref"
            ;;
        *) return 1 ;;
    esac

    echo -e "${GREEN}Aktiver Huginn-Upstream-Stand: $(current_huginn_repo_ref)${NC}"
}

choose_huginn_database_adapter_cli() {
    local selected_adapter

    echo
    echo "Huginn-Datenbank"
    echo "1) MySQL / MariaDB (empfohlen)"
    echo "2) PostgreSQL"
    read -r -p "Auswahl [1-2]: " selected_adapter

    case "$selected_adapter" in
        1|"")
            apply_huginn_database_template_preset "mysql2"
            save_huginn_install_setting "HUGINN_DATABASE_ADAPTER" "mysql2"
            ;;
        2)
            apply_huginn_database_template_preset "postgresql"
            save_huginn_install_setting "HUGINN_DATABASE_ADAPTER" "postgresql"
            ;;
        *) return 1 ;;
    esac
}

choose_huginn_database_adapter() {
    ensure_user_workspace

    if ! dialog_available; then
        choose_huginn_database_adapter_cli
        return $?
    fi

    local current_adapter selected_adapter begin_row begin_col mysql_state postgres_state
    local dialog_mouse_args=()

    current_adapter="$(current_huginn_database_adapter)"
    [ -n "$current_adapter" ] || current_adapter="mysql2"

    mysql_state="off"
    postgres_state="off"
    case "$current_adapter" in
        mysql2) mysql_state="on" ;;
        postgresql) postgres_state="on" ;;
        *) mysql_state="on" ;;
    esac

    read -r begin_row begin_col <<<"$(dialog_begin_args 15 82)"
    mapfile -t dialog_mouse_args < <(dialog_common_args)

    rm -f "$HUGINN_DB_CHOICE_FILE"
    reset_terminal_state
    if ! dialog --clear "${dialog_mouse_args[@]}" --backtitle "OpenClaw Ultimate Setup" \
        --begin "$begin_row" "$begin_col" \
        --cancel-label "Zurueck" \
        --title "HUGINN DATENBANK" --radiolist \
        "Waehlen Sie die Huginn-Datenbank.\n\nEmpfohlen: MySQL/MariaDB\nAktuell: ${current_adapter}" \
        15 82 5 \
        "1" "MySQL / MariaDB (empfohlen fuer diesen Huginn-Stand)" "$mysql_state" \
        "2" "PostgreSQL (optional, kann Zusatzfixes brauchen)" "$postgres_state" \
        2> "$HUGINN_DB_CHOICE_FILE"; then
        reset_terminal_state
        return 1
    fi
    reset_terminal_state

    selected_adapter="$(tr -d '\r" ' < "$HUGINN_DB_CHOICE_FILE" 2>/dev/null || true)"
    case "$selected_adapter" in
        1)
            apply_huginn_database_template_preset "mysql2"
            save_huginn_install_setting "HUGINN_DATABASE_ADAPTER" "mysql2"
            echo -e "${GREEN}Huginn wird jetzt mit MySQL/MariaDB vorbereitet.${NC}"
            ;;
        2)
            apply_huginn_database_template_preset "postgresql"
            save_huginn_install_setting "HUGINN_DATABASE_ADAPTER" "postgresql"
            echo -e "${GREEN}Huginn wird jetzt mit PostgreSQL vorbereitet.${NC}"
            ;;
        *) return 1 ;;
    esac
}

edit_file() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        echo -e "${RED}Fehler: Datei nicht gefunden: ${file_path}${NC}"
        pause_screen
        return 1
    fi

    echo -e "${BLUE}Oeffne Datei zum Bearbeiten: ${file_path}${NC}"
    echo -e "${YELLOW}Hinweis: Die Huginn-Doku zur .env steht in docs/HUGINN_ENV_GUIDE.md${NC}"
    if command -v nano >/dev/null 2>&1; then
        nano "$file_path"
    elif command -v vi >/dev/null 2>&1; then
        vi "$file_path"
    else
        echo -e "${RED}Kein geeigneter Texteditor gefunden. Bitte manuell bearbeiten: ${file_path}${NC}"
        pause_screen
    fi
}

apply_env_template() {
    ensure_user_workspace

    if [ ! -f "$HUGINN_TEMPLATE_FILE" ]; then
        echo -e "${RED}Fehler: Vorlagendatei ${HUGINN_TEMPLATE_FILE} nicht gefunden.${NC}"
        return 1
    fi

    if [ ! -d "$HUGINN_INSTALL_DIR" ]; then
        echo -e "${YELLOW}Warnung: Huginn ist noch nicht unter ${HUGINN_INSTALL_DIR} installiert.${NC}"
        echo -e "${YELLOW}Die Vorlage wurde nicht angewendet, kann aber schon vorbereitet werden.${NC}"
        return 1
    fi

    echo -e "${BLUE}Wende Huginn-.env auf ${HUGINN_RUNTIME_ENV} an...${NC}"
    sudo cp "$HUGINN_TEMPLATE_FILE" "$HUGINN_RUNTIME_ENV"
    sudo chown "$USER:$USER" "$HUGINN_RUNTIME_ENV" 2>/dev/null || true
    sudo chmod 600 "$HUGINN_RUNTIME_ENV" 2>/dev/null || true
    echo -e "${GREEN}Huginn-.env erfolgreich angewendet.${NC}"
}

import_runtime_env() {
    ensure_user_workspace

    if [ ! -f "$HUGINN_RUNTIME_ENV" ]; then
        echo -e "${YELLOW}Es gibt aktuell keine Laufzeitdatei unter ${HUGINN_RUNTIME_ENV}.${NC}"
        echo -e "${YELLOW}Die Vorlage bleibt unveraendert.${NC}"
        return 1
    fi

    cp "$HUGINN_RUNTIME_ENV" "$HUGINN_TEMPLATE_FILE"
    chmod 600 "$HUGINN_TEMPLATE_FILE" 2>/dev/null || true
    echo -e "${GREEN}Die aktuelle Huginn-.env wurde in die bearbeitbare Vorlage uebernommen.${NC}"
}

show_huginn_paths() {
    echo -e "${BLUE}Huginn-Konfigurationspfade${NC}"
    echo -e "${YELLOW}Bearbeitbare Vorlage:${NC} ${HUGINN_TEMPLATE_FILE}"
    echo -e "${YELLOW}Installationswerte:${NC} ${HUGINN_SETTINGS_FILE}"
    echo -e "${YELLOW}Laufzeitdatei:${NC} ${HUGINN_RUNTIME_ENV}"
    echo -e "${YELLOW}Aktiver HUGINN_REPO_REF:${NC} $(current_huginn_repo_ref)"
    echo -e "${YELLOW}Aktiver Datenbank-Adapter:${NC} $(current_huginn_database_adapter)"
    echo -e "${YELLOW}Guide:${NC} docs/HUGINN_ENV_GUIDE.md"
    echo -e "${YELLOW}Tipp:${NC} Oeffentliche Freigaben nur ueber Reverse Proxy, Cloudflare Tunnel oder Tailscale."
    pause_screen
}

show_huginn_config_menu_cli() {
    local choice

    echo
    echo "HUGINN .env KONFIGURATION"
    echo "1) Huginn-.env-Vorlage bearbeiten"
    echo "2) Vorlage auf /opt/huginn/.env anwenden"
    echo "3) Aktuelle /opt/huginn/.env in Vorlage uebernehmen"
    echo "4) Huginn-Upstream-Stand auswaehlen"
    echo "5) Huginn-Datenbanktechnik auswaehlen"
    echo "6) Pfade und Hinweise anzeigen"
    echo "7) Beenden"
    read -r -p "Auswahl: " choice
    printf '%s' "$choice" > "$HUGINN_CONFIG_CHOICE_FILE"
}

show_huginn_config_menu() {
    ensure_user_workspace
    rm -f "$HUGINN_CONFIG_CHOICE_FILE"

    if ! dialog_available; then
        show_huginn_config_menu_cli
        return 0
    fi

    local dialog_mouse_args=()
    mapfile -t dialog_mouse_args < <(dialog_common_args)

    reset_terminal_state
    if ! dialog --clear "${dialog_mouse_args[@]}" --backtitle "OpenClaw Ultimate Setup" \
        --cancel-label "Zurueck" \
        --title "HUGINN .env KONFIGURATION" --menu "Waehlen Sie eine Aktion fuer die Huginn-.env:" 22 100 10 \
        "1" "Huginn-.env-Vorlage bearbeiten" \
        "2" "Vorlage auf /opt/huginn/.env anwenden" \
        "3" "Aktuelle /opt/huginn/.env in Vorlage uebernehmen" \
        "4" "Huginn-Upstream-Stand (HUGINN_REPO_REF) auswaehlen" \
        "5" "Huginn-Datenbanktechnik auswaehlen" \
        "6" "Pfade und Hinweise anzeigen" \
        "7" "Beenden" 2> "$HUGINN_CONFIG_CHOICE_FILE"; then
        reset_terminal_state
        rm -f "$HUGINN_CONFIG_CHOICE_FILE"
        return 1
    fi
    reset_terminal_state
}

main() {
    trap cleanup_temp_files EXIT
    ensure_user_workspace

    while true; do
        show_huginn_config_menu || break
        [ -f "$HUGINN_CONFIG_CHOICE_FILE" ] || break

        case "$(tr -d '\r" ' < "$HUGINN_CONFIG_CHOICE_FILE")" in
            1) edit_file "$HUGINN_TEMPLATE_FILE" ;;
            2) apply_env_template; pause_screen ;;
            3) import_runtime_env; pause_screen ;;
            4) choose_huginn_repo_ref; pause_screen ;;
            5) choose_huginn_database_adapter; pause_screen ;;
            6) show_huginn_paths ;;
            7) break ;;
            *) break ;;
        esac
    done
}

if [ "${1:-}" = "--prepare-install" ]; then
    trap cleanup_temp_files EXIT
    ensure_user_workspace
    choose_huginn_repo_ref || exit 1
    choose_huginn_database_adapter || exit 1
    exit 0
fi

main "$@"
