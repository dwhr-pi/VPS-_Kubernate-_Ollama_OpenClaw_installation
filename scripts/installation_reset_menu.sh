#!/usr/bin/env bash
# Recovery is explicit and lock-only; never terminate WSL or purge tool data.
set -u
ROOT="$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd)"
command -v python3 >/dev/null || { printf '%s\n' 'Python 3 fehlt; keine Reset-Aktion.'; exit 1; }
tool_args=()
if [[ ! -t 0 ]]; then
    python3 -I -B "$ROOT/scripts/operations/reset_installation.py" --check
    exit $?
fi
while true; do
    printf '\n%s\n' 'INSTALLATIONS-RESET (keine Linux-Neuinstallation)'
    printf '%s\n' '1: Sperren und aktive Prozesse pruefen (nur lesen)'
    printf '%s\n' '2: Gepruefte alte Sperren archivieren / freigeben'
    printf '%s\n' '3: Optionales Tool waehlen (z.B. node_red, cadvisor); leer = nur globale Sperre'
    printf '%s\n' '0: Zurueck'
    read -r -p 'Auswahl [0]: ' choice || break
    case "$choice" in
        1)
            python3 -I -B "$ROOT/scripts/operations/reset_installation.py" --check "${tool_args[@]}" || true
            ;;
        2)
            python3 -I -B "$ROOT/scripts/operations/reset_installation.py" --check "${tool_args[@]}" || true
            printf '%s\n' 'Aktive Installer werden NICHT entsperrt oder beendet. Im Installations-Terminal kontrolliert abbrechen (Ctrl+C) oder abwarten.'
            printf '%s\n' 'Keine Prozesse mit killall/pkill beenden; apt/dpkg zuerst fertig arbeiten lassen.'
            printf '%s\n' 'Alle parallelen/alten Installer und Builds manuell geprueft und geschlossen? Nur Sperren archivieren? [j/N]'
            printf '%s\n' 'Warte auf Ihre Eingabe und Enter. Nur [j/ja/y/yes] erlaubt die Aktion; Nur [Enter] bedeutet: Nein.'
            read -r answer || answer=''
            case "${answer,,}" in
                j|ja|y|yes)
                    python3 -I -B "$ROOT/scripts/operations/reset_installation.py" --apply --confirm-reset --acknowledge-legacy "${tool_args[@]}" || true
                    ;;
                *) printf '%s\n' 'Reset nicht freigegeben; nichts veraendert.' ;;
            esac
            ;;
        3)
            read -r -p 'Tool-ID (leer = nur globale Sperre): ' tool || tool=''
            tool_args=()
            [[ -z "$tool" ]] || tool_args=(--tool "$tool")
            ;;
        0|'') break ;;
        *) printf '%s\n' 'Bitte 0, 1, 2 oder 3 waehlen.' ;;
    esac
done
exit 0
