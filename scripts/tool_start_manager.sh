#!/bin/bash
# ==============================================================================
# TOOL_START_MANAGER.SH - Startet installierte Dienste gesammelt oder gezielt
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
TOOL_STATUS_FILE="$USER_WORKSPACE_DIR/installed_tools.txt"
AUTOSTART_DIR="$USER_WORKSPACE_DIR/autostart"
AUTOSTART_SCRIPT="$AUTOSTART_DIR/start_selected_tools.sh"
RUNTIME_LOG_DIR="$USER_WORKSPACE_DIR/runtime_logs"
SELECTION_FILE="/tmp/tool_start_selection"
MENU_FILE="/tmp/tool_start_menu"

declare -a INSTALLED_TOOLS=()
declare -a STARTABLE_TOOLS=()
declare -a UNSUPPORTED_TOOLS=()
declare -A START_LABELS=()
declare -A START_HINTS=()
declare -A START_KIND=()

START_ORDER=("Huginn" "Ollama" "Home_Assistant" "OpenClaw")

START_LABELS["Huginn"]="Huginn"
START_HINTS["Huginn"]="Web + Worker, bevorzugt per systemd"
START_KIND["Huginn"]="service"

START_LABELS["Ollama"]="Ollama"
START_HINTS["Ollama"]="lokales Modell-Backend per systemd"
START_KIND["Ollama"]="service"

START_LABELS["Home_Assistant"]="Home Assistant"
START_HINTS["Home_Assistant"]="Smart-Home-Dienst per systemd"
START_KIND["Home_Assistant"]="service"

START_LABELS["OpenClaw"]="OpenClaw"
START_HINTS["OpenClaw"]="Dev-Modus im Hintergrund, Logs im Benutzer-Workspace"
START_KIND["OpenClaw"]="background"

cleanup_temp_files() {
    rm -f "$SELECTION_FILE" "$MENU_FILE"
}

print_header() {
    echo
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

pause_screen() {
    read -r -p "Druecken Sie Enter..."
}

load_installed_tools() {
    INSTALLED_TOOLS=()
    [ -f "$TOOL_STATUS_FILE" ] || return 0

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%$'\r'}"
        line="${line//\"/}"
        [ -n "$line" ] || continue
        INSTALLED_TOOLS+=("$line")
    done < "$TOOL_STATUS_FILE"
}

is_installed_tool() {
    local needle="$1"
    local item
    for item in "${INSTALLED_TOOLS[@]}"; do
        if [ "$item" = "$needle" ]; then
            return 0
        fi
    done
    return 1
}

detect_startable_tools() {
    local tool
    STARTABLE_TOOLS=()
    UNSUPPORTED_TOOLS=()

    load_installed_tools

    for tool in "${INSTALLED_TOOLS[@]}"; do
        case "$tool" in
            Huginn|Ollama|Home_Assistant|OpenClaw)
                STARTABLE_TOOLS+=("$tool")
                ;;
            *)
                UNSUPPORTED_TOOLS+=("$tool")
                ;;
        esac
    done
}

append_checklist_items() {
    local tool
    local default_state="${1:-off}"
    shift || true

    for tool in "${START_ORDER[@]}"; do
        if is_installed_tool "$tool"; then
            printf '%s\n' "$tool" >> "$SELECTION_FILE.items"
            CHECKLIST_ARGS+=("$tool" "${START_LABELS[$tool]} - ${START_HINTS[$tool]}" "$default_state")
        fi
    done
}

show_supported_summary() {
    local tool

    print_header "Installierte Startziele"
    if [ "${#STARTABLE_TOOLS[@]}" -eq 0 ]; then
        echo -e "${YELLOW}Aktuell wurden keine installierten Tools mit hinterlegter Startroutine erkannt.${NC}"
    else
        echo -e "${GREEN}Startbar und im Setup hinterlegt:${NC}"
        for tool in "${START_ORDER[@]}"; do
            if is_installed_tool "$tool"; then
                echo " - ${START_LABELS[$tool]}: ${START_HINTS[$tool]}"
            fi
        done
    fi

    if [ "${#UNSUPPORTED_TOOLS[@]}" -gt 0 ]; then
        echo
        echo -e "${YELLOW}Installiert, aber noch ohne zentrale Startroutine im Start-Manager:${NC}"
        for tool in "${UNSUPPORTED_TOOLS[@]}"; do
            echo " - $tool"
        done
    fi
}

ensure_runtime_dirs() {
    mkdir -p "$AUTOSTART_DIR" "$RUNTIME_LOG_DIR"
}

start_huginn() {
    ensure_runtime_dirs
    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files 2>/dev/null | grep -q '^huginn-web\.service'; then
        sudo systemctl start huginn-web.service huginn-worker.service
        echo -e "${GREEN}Huginn gestartet: systemd-Dienste huginn-web.service + huginn-worker.service${NC}"
        return 0
    fi

    nohup bash -lc 'cd /opt/huginn && RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 bundle exec rails server -b 127.0.0.1 -p 3002' > "$RUNTIME_LOG_DIR/huginn_web.log" 2>&1 &
    nohup bash -lc 'cd /opt/huginn && RAILS_ENV=production bundle exec rails runner bin/threaded.rb' > "$RUNTIME_LOG_DIR/huginn_worker.log" 2>&1 &
    echo -e "${YELLOW}Huginn ohne systemd im Hintergrund gestartet.${NC}"
    echo "  Web-Log: $RUNTIME_LOG_DIR/huginn_web.log"
    echo "  Worker-Log: $RUNTIME_LOG_DIR/huginn_worker.log"
}

start_ollama() {
    sudo systemctl start ollama
    echo -e "${GREEN}Ollama gestartet.${NC}"
}

start_home_assistant() {
    sudo systemctl start homeassistant@homeassistant
    echo -e "${GREEN}Home Assistant gestartet.${NC}"
}

start_openclaw() {
    ensure_runtime_dirs
    nohup bash -lc 'cd /opt/openclaw && pnpm dev' > "$RUNTIME_LOG_DIR/openclaw_dev.log" 2>&1 &
    echo -e "${GREEN}OpenClaw im Hintergrund gestartet.${NC}"
    echo "  Log: $RUNTIME_LOG_DIR/openclaw_dev.log"
    echo "  Hinweis: OpenClaw nutzt in diesem Setup weiterhin Port 3000."
}

start_tool() {
    local tool="$1"
    case "$tool" in
        Huginn) start_huginn ;;
        Ollama) start_ollama ;;
        Home_Assistant) start_home_assistant ;;
        OpenClaw) start_openclaw ;;
        *)
            echo -e "${RED}Fehler: Fuer $tool ist noch keine Startroutine hinterlegt.${NC}"
            return 1
            ;;
    esac
}

start_tools_now() {
    local selected_tools=("$@")
    local tool failures=0

    if [ "${#selected_tools[@]}" -eq 0 ]; then
        echo -e "${YELLOW}Es wurden keine Tools zum Starten ausgewaehlt.${NC}"
        return 0
    fi

    print_header "Starte ausgewaehlte Tools"
    for tool in "${selected_tools[@]}"; do
        echo -e "${BLUE}Starte ${START_LABELS[$tool]:-$tool}...${NC}"
        if ! start_tool "$tool"; then
            failures=$((failures + 1))
        fi
    done

    echo
    if [ "$failures" -eq 0 ]; then
        echo -e "${GREEN}Alle ausgewaehlten Startziele wurden angestossen.${NC}"
    else
        echo -e "${YELLOW}$failures Startziel(e) konnten nicht erfolgreich angestossen werden.${NC}"
    fi
}

generate_autostart_script() {
    local selected_tools=("$@")
    local tool
    ensure_runtime_dirs

    if [ "${#selected_tools[@]}" -eq 0 ]; then
        echo -e "${YELLOW}Es wurden keine Tools fuer das Autostart-Skript ausgewaehlt.${NC}"
        return 1
    fi

    cat > "$AUTOSTART_SCRIPT" <<EOF
#!/bin/bash
set -euo pipefail

INSTALL_DIR="$INSTALL_DIR"
SELECTED_TOOLS=(
EOF
    for tool in "${selected_tools[@]}"; do
        printf '  "%s"\n' "$tool" >> "$AUTOSTART_SCRIPT"
    done
    cat >> "$AUTOSTART_SCRIPT" <<'EOF'
)

echo "OpenClaw Ultimate Autostart"
echo "Ausgewaehlte Startziele:"
for tool in "${SELECTED_TOOLS[@]}"; do
  echo " - $tool"
done
echo
echo "Autostart startet in 12 Sekunden."
echo "Taste [s] oeffnet stattdessen das Setup."
echo "Taste [x] bricht den Autostart komplett ab."

if read -r -t 12 -n 1 autostart_choice; then
  echo
  case "$autostart_choice" in
    s|S)
      exec bash "$INSTALL_DIR/setup_ultimate.sh"
      ;;
    x|X|q|Q)
      echo "Autostart abgebrochen."
      exit 0
      ;;
  esac
fi

exec bash "$INSTALL_DIR/scripts/tool_start_manager.sh" --run-tools "${SELECTED_TOOLS[@]}"
EOF

    chmod +x "$AUTOSTART_SCRIPT"
    echo -e "${GREEN}Autostart-Skript aktualisiert:${NC} $AUTOSTART_SCRIPT"
    echo -e "${YELLOW}Du kannst die Liste der SELECTED_TOOLS dort spaeter manuell anpassen.${NC}"
    return 0
}

choose_tools_with_dialog() {
    local title="$1"
    local prompt="$2"
    local default_state="${3:-off}"
    local raw
    CHECKLIST_ARGS=()
    rm -f "$SELECTION_FILE" "$SELECTION_FILE.items"
    append_checklist_items "$default_state"

    if [ "${#CHECKLIST_ARGS[@]}" -eq 0 ]; then
        echo -e "${YELLOW}Es stehen aktuell keine installierten Startziele zur Auswahl.${NC}"
        return 1
    fi

    dialog --clear --backtitle "OpenClaw Ultimate Setup" \
        --title "$title" --checklist "$prompt" 20 100 10 \
        "${CHECKLIST_ARGS[@]}" 2> "$SELECTION_FILE" || return 1

    raw="$(cat "$SELECTION_FILE" 2>/dev/null || true)"
    raw="${raw//\"/}"
    SELECTED_DIALOG_TOOLS=()
    for tool in $raw; do
        [ -n "$tool" ] || continue
        SELECTED_DIALOG_TOOLS+=("$tool")
    done

    if [ "${#SELECTED_DIALOG_TOOLS[@]}" -eq 0 ]; then
        echo -e "${YELLOW}Es wurde nichts ausgewaehlt.${NC}"
        return 1
    fi

    return 0
}

run_selected_from_cli() {
    local selected_tools=("$@")
    detect_startable_tools
    start_tools_now "${selected_tools[@]}"
}

show_start_manager_menu() {
    local choice

    while true; do
        detect_startable_tools
        dialog --clear --backtitle "OpenClaw Ultimate Setup" \
            --title "START-MANAGER" --menu \
            "Starte installierte Dienste gesammelt, gezielt oder erzeuge ein Autostart-Skript." \
            20 96 8 \
            "1" "Alle startbaren installierten Tools jetzt starten" \
            "2" "Ausgewaehlte installierte Tools jetzt starten" \
            "3" "Autostart-Skript fuer ausgewaehlte Tools erzeugen" \
            "4" "Autostart-Skript mit Editor oeffnen" \
            "5" "Aktuelle Startziele anzeigen" \
            "6" "Zurueck" 2> "$MENU_FILE" || return 0

        choice="$(cat "$MENU_FILE" 2>/dev/null || true)"
        clear

        case "$choice" in
            1)
                if [ "${#STARTABLE_TOOLS[@]}" -eq 0 ]; then
                    echo -e "${YELLOW}Es wurden keine startbaren installierten Tools erkannt.${NC}"
                else
                    start_tools_now "${STARTABLE_TOOLS[@]}"
                fi
                pause_screen
                ;;
            2)
                if choose_tools_with_dialog "TOOLS STARTEN" "Waehlen Sie die installierten Tools, die jetzt gestartet werden sollen:" "off"; then
                    clear
                    start_tools_now "${SELECTED_DIALOG_TOOLS[@]}"
                fi
                pause_screen
                ;;
            3)
                if choose_tools_with_dialog "AUTOSTART-SKRIPT" "Waehlen Sie die Tools fuer den kuenftigen Autostart:" "on"; then
                    clear
                    generate_autostart_script "${SELECTED_DIALOG_TOOLS[@]}"
                fi
                pause_screen
                ;;
            4)
                ensure_runtime_dirs
                if [ ! -f "$AUTOSTART_SCRIPT" ]; then
                    echo -e "${YELLOW}Es gibt noch kein Autostart-Skript. Erzeuge zuerst eines ueber Punkt 3.${NC}"
                    pause_screen
                    continue
                fi
                "${EDITOR:-nano}" "$AUTOSTART_SCRIPT"
                ;;
            5)
                show_supported_summary
                echo
                echo "Autostart-Skript: $AUTOSTART_SCRIPT"
                pause_screen
                ;;
            6)
                return 0
                ;;
        esac
    done
}

main() {
    trap cleanup_temp_files EXIT

    if [ "${1:-}" = "--run-tools" ]; then
        shift
        run_selected_from_cli "$@"
        return 0
    fi

    show_start_manager_menu
}

main "$@"
