#!/usr/bin/env bash
set -euo pipefail
QWEN_DESKTOP_DOWNLOAD_URL=https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest

qwen_desktop_open_download() {
    # Fixed official URL only; never execute a downloaded installer.
    if [[ -n "${WSL_DISTRO_NAME:-}" || "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == cygwin* ]] ||
        grep -qi microsoft /proc/version 2>/dev/null; then
        if command -v powershell.exe >/dev/null 2>&1; then
            powershell.exe -NoProfile -NonInteractive -Command \
                "Start-Process 'https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest'" && return 0
        fi
        if command -v cmd.exe >/dev/null 2>&1; then
            MSYS_NO_PATHCONV=1 cmd.exe /c start "" "$QWEN_DESKTOP_DOWNLOAD_URL" && return 0
        fi
    elif [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] && command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$QWEN_DESKTOP_DOWNLOAD_URL" && return 0
    fi
    printf 'Browser konnte nicht geoeffnet werden. Bitte diesen Link manuell oeffnen:\n%s\n' "$QWEN_DESKTOP_DOWNLOAD_URL" >&2
    return 1
}

qwen_desktop_can_prompt() { [[ -t 0 ]]; }

qwen_desktop_offer_download() {
    local answer
    if qwen_desktop_can_prompt; then
        printf 'Offizielle Windows-Downloadseite jetzt im Browser oeffnen? [(j)a/(N)ein]: ' >&2
        if IFS= read -r answer; then
            case "$answer" in
                j|J|ja|Ja|JA) qwen_desktop_open_download || true ;;
            esac
        fi
    else
        echo 'Browser manuell oeffnen: bash scripts/tools/qwen_desktop_install.sh --open-download' >&2
    fi
}

qwen_desktop_main() {
    case "${1:---dry-run}" in
        --dry-run|--plan|plan|check|--check|status|--status|doctor|--doctor)
            printf '%s\n' '{"status":"planned","installed":false,"platform":"windows-manual","network":false,"scope":"registration_only"}' ;;
        --open-download)
            printf 'Download: %s\n' "$QWEN_DESKTOP_DOWNLOAD_URL"
            qwen_desktop_open_download ;;
        install|update)
            printf '%s\n' 'Qwen Code Desktop wird nativ unter Windows manuell installiert, nicht in WSL.' "Download: $QWEN_DESKTOP_DOWNLOAD_URL" 'Anleitung: docs/tools/qwen-desktop-windows.md' >&2
            qwen_desktop_offer_download
            echo 'Keine Installation/Aktualisierung ausgefuehrt. Ein geoeffneter Browser ist kein Installationsnachweis.' >&2
            return 2 ;;
        *)
            printf '%s\n' 'Qwen Code Desktop wird nativ unter Windows manuell installiert, nicht in WSL.' 'Download: https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest' 'Anleitung: docs/tools/qwen-desktop-windows.md' 'Keine Installation, Aktualisierung, Deinstallation oder Datenloeschung ausgefuehrt.' >&2
            return 2 ;;
    esac
}
