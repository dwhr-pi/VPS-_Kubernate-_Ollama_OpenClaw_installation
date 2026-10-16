#!/usr/bin/env bash
set -euo pipefail

PINOKIO_DOWNLOAD_URL=https://github.com/pinokiocomputer/pinokio/releases/tag/v8.2.0

pinokio_can_prompt() { [[ -t 0 ]]; }

pinokio_open_download() {
    # Only the fixed release page is opened; no downloaded executable is run.
    if [[ -n "${WSL_DISTRO_NAME:-}" || "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == cygwin* ]] ||
        grep -qi microsoft /proc/version 2>/dev/null; then
        if command -v powershell.exe >/dev/null 2>&1; then
            powershell.exe -NoProfile -NonInteractive -Command \
                "Start-Process 'https://github.com/pinokiocomputer/pinokio/releases/tag/v8.2.0'" && return 0
        fi
        if command -v cmd.exe >/dev/null 2>&1; then
            MSYS_NO_PATHCONV=1 cmd.exe /c start "" "$PINOKIO_DOWNLOAD_URL" && return 0
        fi
    elif [[ "${OSTYPE:-}" == darwin* ]] && command -v open >/dev/null 2>&1; then
        open "$PINOKIO_DOWNLOAD_URL" && return 0
    elif [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] && command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$PINOKIO_DOWNLOAD_URL" && return 0
    fi
    printf 'Browser nicht erreichbar. Link bitte manuell oeffnen:\n%s\n' "$PINOKIO_DOWNLOAD_URL" >&2
    return 1
}

pinokio_main() {
    local answer
    case "${1:---dry-run}" in
        --dry-run|--plan|plan|--check|check|status|--status|doctor|--doctor)
            printf '%s\n' '{"status":"planned","installed":false,"installation_verified":false,"version":"8.2.0","platform":"native-desktop-manual","network":false,"scope":"registration_only"}'
            ;;
        --open-download)
            printf 'Download: %s\n' "$PINOKIO_DOWNLOAD_URL"
            pinokio_open_download
            ;;
        install|update)
            printf '%s\n' \
                'Pinokio: nativer Desktop-Download aus GitHub v8.2.0, kein Docker.' \
                'Windows: Pinokio.exe unter Windows installieren, nicht in WSL.' \
                "Download: $PINOKIO_DOWNLOAD_URL" \
                'Anleitung und SHA256: docs/tools/pinokio.md' \
                'Keine App-Skripte/Modelle automatisch installieren; Pinokio ist keine Sandbox.' >&2
            if ! pinokio_can_prompt; then
                echo 'Manuelle Installation ausstehend. Interaktiv erneut starten oder --open-download verwenden.' >&2
                return 3
            fi
            printf 'Offizielle GitHub-Downloadseite im Browser oeffnen? [(j)a/(N)ein]: ' >&2
            IFS= read -r answer || return 3
            answer=${answer%$'\r'}
            case "$answer" in
                j|J|ja|Ja|JA) pinokio_open_download || return 1 ;;
                *) echo 'Kein Browser geoeffnet; Download ueber den obigen Link moeglich.' >&2 ;;
            esac
            echo 'Setup pausiert: passendes Desktop-Paket herunterladen, pruefen und manuell installieren.' >&2
            printf 'Wenn fertig oder spaeter fortfahren: Enter druecken ... ' >&2
            IFS= read -r answer || return 3
            printf 'Desktop-Installation/Aktualisierung erfolgreich abgeschlossen? [(j)a/(N)ein]: ' >&2
            IFS= read -r answer || return 3
            answer=${answer%$'\r'}
            case "$answer" in
                j|J|ja|Ja|JA)
                    echo 'Desktop-Installation vom Benutzer bestaetigt; nicht automatisch geprueft.' >&2 ;;
                *)
                    echo 'Installation verschoben/nicht bestaetigt. Kein Installationsfehler.' >&2
                    return 3 ;;
            esac
            ;;
        uninstall|--uninstall)
            echo 'Pinokio nativ ueber die Betriebssystem-Appverwaltung entfernen. App-/Modelldaten vorher sichern; keine automatische Datenloeschung.' >&2
            return 2
            ;;
        *)
            echo 'Nutzung: install|update|status|doctor|check|--dry-run|--open-download|uninstall' >&2
            return 2 ;;
    esac
}
