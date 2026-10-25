#!/usr/bin/env bash
# Official download pages only. Never fetch or execute an EXE in Linux/WSL.
set -euo pipefail
browser_desktop_can_prompt() { [[ -t 0 ]]; }
browser_desktop_main() {
    local tool="$1" action="$2" url name answer
    case "$tool" in
        comet) name='Comet'; url='https://www.perplexity.ai/comet' ;;
        browseros) name='BrowserOS'; url='https://github.com/browseros-ai/BrowserOS/releases/latest' ;;
        enki_browser) name='Enki Browser'; url='https://github.com/danilogiles/enki-browser/releases/latest' ;;
        *) return 2 ;;
    esac
    case "$action" in
        --dry-run|--plan|plan|check|--check|status|--status|doctor|--doctor)
            printf '{"installed":false,"status":"manual-unverified","scope":"desktop-manual","download_page":"%s"}\n' "$url"
            return 0 ;;
        uninstall|--uninstall)
            echo "$name: Deinstallation manuell in Windows unter Einstellungen > Apps bzw. ueber den gewaehlten Linux-Paketweg."
            echo 'Kein Browserprofil, keine Cookies oder Nutzerdaten entfernt.'
            return 3 ;;
        install|update|--open-download) ;;
        *) return 2 ;;
    esac
    echo "$name: offizieller Desktop-Download, kein Docker und keine EXE-Ausfuehrung in WSL."
    echo "Download: $url"
    echo 'Anleitung: docs/tools/comet-and-browser-research.md'
    if ! browser_desktop_can_prompt && [[ "$action" != --open-download ]]; then
        echo 'Manueller Vorgang wartet auf Benutzer. Kein Download und keine Installation ausgefuehrt.'
        return 3
    fi
    answer='j'
    if [[ "$action" != --open-download ]]; then
        read -r -p 'Offizielle Downloadseite im Browser oeffnen? [j/N]: ' answer || return 3
    fi
    answer="${answer//$'\r'/}"
    case "${answer,,}" in
        j|ja|y|yes)
            if command -v powershell.exe >/dev/null 2>&1; then
                powershell.exe -NoProfile -NonInteractive -Command "Start-Process '$url'" || echo "Bitte manuell oeffnen: $url"
            elif [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] && command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$url" || echo "Bitte manuell oeffnen: $url"
            else
                echo "Kein Desktop-Browser gefunden. Bitte manuell oeffnen: $url"
            fi ;;
    esac
    [[ "$action" != --open-download ]] || return 0
    echo 'Setup pausiert: korrektes Plattformpaket herunterladen, Signatur/Pruefsumme pruefen und selbst installieren.'
    echo 'Unter Windows EXE nativ starten, nicht in WSL. Schutzfunktionen/Sandbox nicht deaktivieren.'
    read -r -p 'Nach Abschluss oder zum Verschieben Enter druecken ... ' answer || return 3
    read -r -p 'Installation/Aktualisierung erfolgreich abgeschlossen? [j/N]: ' answer || return 3
    answer="${answer//$'\r'/}"
    case "${answer,,}" in
        j|ja|y|yes) echo 'Manuell bestaetigt, technisch nicht verifiziert. Kein automatischer Installiert-Marker.'; return 0 ;;
        *) echo 'Verschoben/nicht bestaetigt. Kein Installationsfehler.'; return 3 ;;
    esac
}
