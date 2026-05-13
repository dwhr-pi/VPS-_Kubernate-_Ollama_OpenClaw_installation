#!/bin/bash
# ==============================================================================
# HUGINN_CONFIG_MANAGER.SH - Verwaltet die Huginn-.env-Vorlage und Laufzeitdatei
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
HUGINN_INSTALL_DIR="/opt/huginn"
HUGINN_RUNTIME_ENV="$HUGINN_INSTALL_DIR/.env"
HUGINN_CONFIG_CHOICE_FILE="/tmp/huginn_config_choice"
HUGINN_REF_CHOICE_FILE="/tmp/huginn_ref_choice"
HUGINN_REF_INPUT_FILE="/tmp/huginn_ref_input"
HUGINN_DB_CHOICE_FILE="/tmp/huginn_db_choice"

ensure_user_workspace() {
    mkdir -p "$HUGINN_TEMPLATE_DIR"

    if [ ! -f "$HUGINN_TEMPLATE_FILE" ]; then
        if [ -f "$HUGINN_REPO_TEMPLATE_FILE" ]; then
            cp "$HUGINN_REPO_TEMPLATE_FILE" "$HUGINN_TEMPLATE_FILE"
        else
            touch "$HUGINN_TEMPLATE_FILE"
        fi
    fi

    if [ ! -f "$HUGINN_SETTINGS_FILE" ]; then
        cat > "$HUGINN_SETTINGS_FILE" <<'EOF'
HUGINN_REPO_REF=v2022.08.18
EOF
        chmod 600 "$HUGINN_SETTINGS_FILE" 2>/dev/null || true
    fi
}

cleanup_temp_files() {
    rm -f "$HUGINN_CONFIG_CHOICE_FILE"
    rm -f "$HUGINN_REF_CHOICE_FILE"
    rm -f "$HUGINN_REF_INPUT_FILE"
    rm -f "$HUGINN_DB_CHOICE_FILE"
}

pause_screen() {
    read -r -p "Druecken Sie Enter..."
}

reset_dialog_terminal_state() {
    # Windows Terminal/WSL hinterlaesst mit dialog gelegentlich Terminal-Modi.
    # Keine Escape-Sequenzen ausgeben: die landen sonst sichtbar im Dialog.
    tput sgr0 2>/dev/null || true
    stty sane 2>/dev/null || true
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

current_huginn_repo_ref() {
    ensure_user_workspace
    awk -F= '/^HUGINN_REPO_REF=/{print $2}' "$HUGINN_SETTINGS_FILE" 2>/dev/null | tail -n 1 | tr -d '\r\" '
}

current_huginn_database_adapter() {
    ensure_user_workspace
    awk -F= '/^DATABASE_ADAPTER=/{print $2}' "$HUGINN_TEMPLATE_FILE" 2>/dev/null | tail -n 1 | tr -d '\r\" '
}

save_huginn_repo_ref() {
    local repo_ref="$1"
    ensure_user_workspace
    python3 - "$repo_ref" "$HUGINN_SETTINGS_FILE" <<'PY'
from pathlib import Path
import sys

repo_ref = sys.argv[1].strip()
path = Path(sys.argv[2])
text = path.read_text(encoding="utf-8") if path.exists() else ""
new_line = f"HUGINN_REPO_REF={repo_ref}"

if "HUGINN_REPO_REF=" in text:
    lines = text.splitlines()
    for idx, line in enumerate(lines):
        if line.startswith("HUGINN_REPO_REF="):
            lines[idx] = new_line
            break
    text = "\n".join(lines)
else:
    text = (text.rstrip("\n") + "\n" if text else "") + new_line

path.write_text(text + ("\n" if not text.endswith("\n") else ""), encoding="utf-8")
PY
    chmod 600 "$HUGINN_SETTINGS_FILE" 2>/dev/null || true
}

save_huginn_setting() {
    local key="$1"
    local value="$2"
    ensure_user_workspace
    python3 - "$key" "$value" "$HUGINN_SETTINGS_FILE" <<'PY'
from pathlib import Path
import sys

key = sys.argv[1].strip()
value = sys.argv[2].strip()
path = Path(sys.argv[3])
text = path.read_text(encoding="utf-8") if path.exists() else ""
new_line = f"{key}={value}"

if f"{key}=" in text:
    lines = text.splitlines()
    replaced = False
    for idx, line in enumerate(lines):
        if line.startswith(f"{key}="):
            lines[idx] = new_line
            replaced = True
    text = "\n".join(lines)
    if not replaced:
        text = (text.rstrip("\n") + "\n" if text else "") + new_line
else:
    text = (text.rstrip("\n") + "\n" if text else "") + new_line

path.write_text(text + ("\n" if not text.endswith("\n") else ""), encoding="utf-8")
PY
    chmod 600 "$HUGINN_SETTINGS_FILE" 2>/dev/null || true
}

apply_huginn_database_template_preset() {
    local adapter="$1"
    ensure_user_workspace
    python3 - "$adapter" "$HUGINN_TEMPLATE_FILE" <<'PY'
from pathlib import Path
import sys

adapter = sys.argv[1].strip()
path = Path(sys.argv[2])
text = path.read_text(encoding="utf-8") if path.exists() else ""
lines = text.splitlines()
data = {}
other_lines = []

for line in lines:
    if "=" in line and not line.lstrip().startswith("#"):
        key, value = line.split("=", 1)
        key = key.strip()
        if key in {
            "DATABASE_ADAPTER",
            "DATABASE_NAME",
            "DATABASE_USERNAME",
            "DATABASE_PASSWORD",
            "DATABASE_HOST",
            "DATABASE_PORT",
        }:
            data[key] = value.strip()
            continue
    other_lines.append(line)

if adapter == "mysql2":
    data.update({
        "DATABASE_ADAPTER": "mysql2",
        "DATABASE_NAME": "huginn_production",
        "DATABASE_USERNAME": "huginn",
        "DATABASE_PASSWORD": "huginn_local_change_me",
        "DATABASE_HOST": "localhost",
        "DATABASE_PORT": "3306",
    })
elif adapter == "postgresql":
    data.update({
        "DATABASE_ADAPTER": "postgresql",
        "DATABASE_NAME": "huginn_production",
        "DATABASE_USERNAME": "huginn",
        "DATABASE_PASSWORD": "change-me",
        "DATABASE_HOST": "127.0.0.1",
        "DATABASE_PORT": "5432",
    })
else:
    raise SystemExit(f"Unsupported database adapter preset: {adapter}")

db_lines = [
    f"DATABASE_ADAPTER={data['DATABASE_ADAPTER']}",
    f"DATABASE_NAME={data['DATABASE_NAME']}",
    f"DATABASE_USERNAME={data['DATABASE_USERNAME']}",
    f"DATABASE_PASSWORD={data['DATABASE_PASSWORD']}",
    f"DATABASE_HOST={data['DATABASE_HOST']}",
    f"DATABASE_PORT={data['DATABASE_PORT']}",
]

result_lines = []
inserted = False
for line in other_lines:
    result_lines.append(line)
    if not inserted and line.strip() == "### Database":
        result_lines.extend(db_lines)
        inserted = True

if not inserted:
    if result_lines and result_lines[-1].strip():
        result_lines.append("")
    result_lines.append("### Database")
    result_lines.extend(db_lines)

path.write_text("\n".join(result_lines).rstrip() + "\n", encoding="utf-8")
PY
}

choose_huginn_repo_ref() {
    ensure_user_workspace
    local current_ref selected_ref custom_ref begin_row begin_col ref_v2022_state ref_master_state ref_custom_state
    current_ref="$(current_huginn_repo_ref)"
    [ -n "$current_ref" ] || current_ref="v2022.08.18"
    read -r begin_row begin_col <<<"$(dialog_begin_args 16 78)"

    ref_v2022_state="off"
    ref_master_state="off"
    ref_custom_state="off"
    case "$current_ref" in
        v2022.08.18) ref_v2022_state="on" ;;
        master) ref_master_state="on" ;;
        *) ref_custom_state="on" ;;
    esac

    rm -f "$HUGINN_REF_CHOICE_FILE"
    reset_dialog_terminal_state
    dialog --clear --no-mouse --backtitle "OpenClaw Ultimate Setup" \
        --begin "$begin_row" "$begin_col" \
        --cancel-label "Zurueck" \
        --title "HUGINN UPSTREAM-STAND" --radiolist \
        "Waehlen Sie den Huginn-Stand.\nEmpfohlen: v2022.08.18\nAktuell: ${current_ref}" \
        16 78 5 \
        "1" "v2022.08.18 (empfohlen, stabiler Stand)" "$ref_v2022_state" \
        "2" "GitHub master (aktueller Upstream, kann brechen)" "$ref_master_state" \
        "3" "Andere Referenz / Tag / Commit-SHA" "$ref_custom_state" \
        2> "$HUGINN_REF_CHOICE_FILE" || return 1
    reset_dialog_terminal_state

    selected_ref="$(cat "$HUGINN_REF_CHOICE_FILE" 2>/dev/null || true)"
    case "$selected_ref" in
        1)
            save_huginn_repo_ref "v2022.08.18"
            ;;
        2)
            save_huginn_repo_ref "master"
            ;;
        3)
            rm -f "$HUGINN_REF_INPUT_FILE"
            reset_dialog_terminal_state
            dialog --clear --no-mouse --backtitle "OpenClaw Ultimate Setup" \
                --begin "$begin_row" "$begin_col" \
                --cancel-label "Zurueck" \
                --title "HUGINN REPO REF" \
                --inputbox "Geben Sie eine Huginn-Referenz ein, z. B. Tag, Branch oder Commit-SHA:" \
                10 100 "$current_ref" 2> "$HUGINN_REF_INPUT_FILE" || return 1
            reset_dialog_terminal_state
            custom_ref="$(tr -d '\r' < "$HUGINN_REF_INPUT_FILE")"
            if [ -z "$custom_ref" ]; then
                echo -e "${RED}Fehler: Die Huginn-Referenz darf nicht leer sein.${NC}"
                pause_screen
                return 1
            fi
            save_huginn_repo_ref "$custom_ref"
            ;;
        *)
            return 1
            ;;
    esac

    echo -e "${GREEN}Aktiver Huginn-Upstream-Stand: $(current_huginn_repo_ref)${NC}"
    return 0
}

choose_huginn_database_adapter() {
    ensure_user_workspace
    local current_adapter selected_adapter begin_row begin_col mysql_state postgres_state
    current_adapter="$(current_huginn_database_adapter)"
    [ -n "$current_adapter" ] || current_adapter="mysql2"
    read -r begin_row begin_col <<<"$(dialog_begin_args 15 78)"

    mysql_state="off"
    postgres_state="off"
    case "$current_adapter" in
        mysql2) mysql_state="on" ;;
        postgresql) postgres_state="on" ;;
        *) mysql_state="on" ;;
    esac

    rm -f "$HUGINN_DB_CHOICE_FILE"
    reset_dialog_terminal_state
    dialog --clear --no-mouse --backtitle "OpenClaw Ultimate Setup" \
        --begin "$begin_row" "$begin_col" \
        --cancel-label "Zurueck" \
        --title "HUGINN DATENBANK" --radiolist \
        "Waehlen Sie die Huginn-Datenbank.\nEmpfohlen: MySQL/MariaDB\nAktuell: ${current_adapter}" \
        15 78 5 \
        "1" "MySQL / MariaDB (empfohlen fuer diesen Huginn-Stand)" "$mysql_state" \
        "2" "PostgreSQL (optional, kann Zusatzfixes brauchen)" "$postgres_state" \
        2> "$HUGINN_DB_CHOICE_FILE" || return 1
    reset_dialog_terminal_state

    selected_adapter="$(cat "$HUGINN_DB_CHOICE_FILE" 2>/dev/null || true)"
    case "$selected_adapter" in
        1)
            apply_huginn_database_template_preset "mysql2"
            save_huginn_setting "HUGINN_DATABASE_ADAPTER" "mysql2"
            echo -e "${GREEN}Huginn wird jetzt mit MySQL/MariaDB vorbereitet.${NC}"
            ;;
        2)
            apply_huginn_database_template_preset "postgresql"
            save_huginn_setting "HUGINN_DATABASE_ADAPTER" "postgresql"
            echo -e "${GREEN}Huginn wird jetzt mit PostgreSQL vorbereitet.${NC}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
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
    echo -e "${YELLOW}Bearbeitbare Vorlage: ${HUGINN_TEMPLATE_FILE}${NC}"
    echo -e "${YELLOW}Laufzeitdatei in Huginn: ${HUGINN_RUNTIME_ENV}${NC}"
    if command -v nano >/dev/null 2>&1; then
        nano "$file_path"
    elif command -v vi >/dev/null 2>&1; then
        vi "$file_path"
    else
        echo -e "${RED}Kein geeigneter Texteditor (nano oder vi) gefunden. Bitte bearbeiten Sie die Datei manuell: ${file_path}${NC}"
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
    echo -e "${YELLOW}Bearbeitbare Vorlage: ${HUGINN_TEMPLATE_FILE}${NC}"
    echo -e "${YELLOW}Installationswerte: ${HUGINN_SETTINGS_FILE}${NC}"
    echo -e "${YELLOW}Laufzeitdatei: ${HUGINN_RUNTIME_ENV}${NC}"
    echo -e "${YELLOW}Aktiver HUGINN_REPO_REF: $(current_huginn_repo_ref)${NC}"
    echo -e "${YELLOW}Aktiver Datenbank-Adapter: $(current_huginn_database_adapter)${NC}"
    echo -e "${YELLOW}Guide: docs/HUGINN_ENV_GUIDE.md${NC}"
    echo -e "${YELLOW}Tipp: Oeffentliche Freigaben nur ueber Reverse Proxy, Cloudflare Tunnel oder Tailscale.${NC}"
    pause_screen
}

show_huginn_config_menu() {
    rm -f "$HUGINN_CONFIG_CHOICE_FILE"
    dialog --clear --backtitle "OpenClaw Ultimate Setup" \
        --cancel-label "Zurueck" \
        --title "HUGINN .env KONFIGURATION" --menu "Waehlen Sie eine Aktion fuer die Huginn-.env:" 22 100 10 \
        "1" "Huginn-.env-Vorlage bearbeiten" \
        "2" "Vorlage auf /opt/huginn/.env anwenden" \
        "3" "Aktuelle /opt/huginn/.env in Vorlage uebernehmen" \
        "4" "Huginn-Upstream-Stand (HUGINN_REPO_REF) auswaehlen" \
        "5" "Huginn-Datenbanktechnik auswaehlen" \
        "6" "Pfade und Hinweise anzeigen" \
        "7" "Beenden" 2> "$HUGINN_CONFIG_CHOICE_FILE"
}

main() {
    trap cleanup_temp_files EXIT
    ensure_user_workspace

    while true; do
        show_huginn_config_menu
        [ -f "$HUGINN_CONFIG_CHOICE_FILE" ] || break

        case "$(cat "$HUGINN_CONFIG_CHOICE_FILE")" in
            1)
                edit_file "$HUGINN_TEMPLATE_FILE"
                ;;
            2)
                apply_env_template
                pause_screen
                ;;
            3)
                import_runtime_env
                pause_screen
                ;;
            4)
                choose_huginn_repo_ref
                pause_screen
                ;;
            5)
                choose_huginn_database_adapter
                pause_screen
                ;;
            6)
                show_huginn_paths
                ;;
            7)
                break
                ;;
            *)
                break
                ;;
        esac
    done
}
if [ "${1:-}" = "--prepare-install" ]; then
    ensure_user_workspace
    if ! choose_huginn_repo_ref; then
        exit 1
    fi
    if ! choose_huginn_database_adapter; then
        exit 1
    fi
    exit 0
fi

main "$@"
