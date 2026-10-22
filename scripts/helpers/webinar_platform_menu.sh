#!/usr/bin/env bash
# Sourced by the setup. Never auto-select Windows or start WSL/PowerShell.

run_webinar_platform_action() {
    local target="$1" tool="$2" action="$3"
    case "$tool" in marp|listmonk|mautic|qwen_desktop_build) ;; *) return 2 ;; esac
    case "$action" in plan|install|update|repair|uninstall|status|check|doctor) ;; *) return 2 ;; esac
    case "$target" in
        ubuntu)
            if [[ "$tool" == qwen_desktop_build ]]; then
                "${GAP_TOOLS_PYTHON_BIN:-python3}" -B "$INSTALL_DIR/scripts/tools/helpers/gap_tools.py" "$tool" "$action"
            else
                "${WEBINAR_PYTHON_BIN:-python3}" -B "$INSTALL_DIR/scripts/tools/helpers/webinar_releases.py" "$tool" "$action"
            fi
            ;;
        windows)
            if ! command -v powershell.exe >/dev/null 2>&1 || ! command -v wslpath >/dev/null 2>&1; then
                printf '%s\n' 'Windows-Interop nicht verfuegbar. Unter Windows direkt aus dem Setup-Verzeichnis starten:'
                if [[ "$tool" == qwen_desktop_build ]]; then
                    printf '.\\scripts\\windows\\qwen_desktop_build.ps1 -Action %s\n' "$action"
                else
                    printf '.\\scripts\\windows\\webinar_tools.ps1 -Tool %s -Action %s\n' "$tool" "$action"
                fi
                return 1
            fi
            local launcher
            if [[ "$tool" == qwen_desktop_build ]]; then
                launcher="$(wslpath -w "$INSTALL_DIR/scripts/windows/qwen_desktop_build.ps1")" || return 1
                powershell.exe -NoProfile -NonInteractive -File "$launcher" -Action "$action"
            else
                launcher="$(wslpath -w "$INSTALL_DIR/scripts/windows/webinar_tools.ps1")" || return 1
                powershell.exe -NoProfile -NonInteractive -File "$launcher" -Tool "$tool" -Action "$action"
            fi
            ;;
        *) return 2 ;;
    esac
}

show_webinar_platform_menu() {
    local target tool action result
    target="$(dialog --stdout --clear --backtitle "$APP_TITLE" --default-item ubuntu \
        --title 'Native GitHub-Tools: Setupauswahl' \
        --menu 'Wo sollen Marp, listmonk, Mautic oder Qwen Desktop Build eingerichtet werden? Die Ziele haben getrennte Statusdateien.' 17 86 3 \
        ubuntu 'Ubuntu / WSL: im Linux-Benutzerverzeichnis' \
        windows 'Windows: native Installation ohne Docker und ohne WSL-Start')" || return 0
    tool="$(dialog --stdout --clear --backtitle "$APP_TITLE" --title 'Webinar-Werkzeug / Qwen Desktop' \
        --menu "Ziel: $target. Welches Werkzeug?" 17 86 4 \
        marp 'Marp: Markdown-Praesentationen' listmonk 'listmonk: Newsletter; PostgreSQL/SMTP separat' \
        mautic 'Mautic: Anwendungspaket; PHP/DB/Webserver separat' \
        qwen_desktop_build 'Qwen Desktop: nativer GitHub/Tauri-Build, Node 22/Rust separat')" || return 0
    action="$(dialog --stdout --clear --backtitle "$APP_TITLE" --default-item plan --title 'Webinar-Aktion' \
        --menu 'Plan und Status zuerst pruefen. Kein Agenten-, GUI- oder Dienststart.' 20 80 6 \
        plan 'Nur Plan, kein Download' status 'Installationsstatus' install 'Installieren' \
        doctor 'Dateien vollstaendig pruefen' update 'Gleichen Release-Pin pruefen' \
        uninstall 'Unveraenderte Programmdateien entfernen')" || return 0
    if [[ "$action" = install || "$action" = update || "$action" = uninstall ]]; then
        dialog --stdout --defaultno --yes-label 'Ja' --no-label 'Nein' --title 'Ziel und Aktion bestaetigen' \
            --yesno "Werkzeug: $tool\nZiel: $target\nAktion: $action\n\nNur Programmdateien. Keine Datenbank-/Mail-/Diensteinrichtung. Fortfahren?" 15 80 || return 0
    fi
    clear
    result=0
    run_webinar_platform_action "$target" "$tool" "$action" || result=$?
    if [[ "$target" = ubuntu && "$result" -eq 0 ]]; then
        local tool_key
        case "$tool" in marp) tool_key=Marp ;; listmonk) tool_key=Listmonk ;; mautic) tool_key=Mautic ;; qwen_desktop_build) tool_key=Qwen_Desktop_Build ;; esac
        case "$action" in
            install|update|repair) append_unique_line "$TOOL_STATUS_FILE" "$tool_key" ;;
            uninstall)
                remove_exact_line "$TOOL_STATUS_FILE" "$tool_key"
                remove_exact_line "$USER_STATUS_DIR/installed_tools.txt" "$tool_key"
                ;;
        esac
    fi
    printf '\nZiel: %s | Werkzeug: %s | Aktion: %s | Exit-Code: %s\n' "$target" "$tool" "$action" "$result"
    printf '%s\n' 'Windows- und Ubuntu-Installationsstatus werden nicht miteinander vermischt.'
    read -r -p 'Aktion abgeschlossen. Druecken Sie Enter...' _
    return 0
}
