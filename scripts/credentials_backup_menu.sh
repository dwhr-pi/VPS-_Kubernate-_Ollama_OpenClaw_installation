#!/usr/bin/env bash
set -u
ROOT="$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd)"
HELPER="$ROOT/scripts/security/credentials_backup.py"
[[ -t 0 ]] || { echo 'Interaktives Linux-/WSL-Terminal erforderlich.'; exit 1; }
while true; do
    printf '\n%s\n' 'ZUGANGSDATEN-BACKUP (getrennt vom Programminventar)'
    printf '%s\n' '1: Dateiauswahl / E-Mail / optionalen Hinweis konfigurieren (kein Passwort speichern)'
    printf '%s\n' '2: TAR mit age-Passphrase verschluesseln und extern exportieren'
    printf '%s\n' '3: Entschluesselung und Archivintegritaet pruefen (keine Dateien schreiben)'
    printf '%s\n' '4: In neuen privaten Linux-Ordner wiederherstellen (keine Aktivierung)'
    printf '%s\n' '5: E-Mail-Entwurf (.eml) mit verschluesseltem Anhang erstellen'
    printf '%s\n' '6: Verschluesselten Anhang ueber vorhandenen msmtp-Account versenden'
    printf '%s\n' '0: Zurueck'
    read -r -p 'Auswahl [0]: ' choice || break
    case "$choice" in
        0|'') break ;;
        1) python3 -B "$HELPER" configure || true ;;
        2)
            echo 'Z.B. /mnt/d/Setup-Sicherung/zugangsdaten.tar.age; nur verschluesselt nach Windows.'
            echo 'Passphrase wird ausschliesslich durch age am Terminal abgefragt. Separat sicher verwahren!'
            read -r -p 'Neuer absoluter Exportpfad: ' target || continue
            python3 -B "$HELPER" export --output "$target" || true ;;
        3|4)
            read -r -p 'Verschluesseltes Archiv (.tar.age): ' source || continue
            read -r -p 'Neuer privater Linux-Zielordner (auch bei Pruefung, wird dort nicht angelegt): ' target || continue
            if [[ "$choice" == 3 ]]; then
                python3 -B "$HELPER" check --input "$source" --output "$target" || true
            else
                read -r -p 'Klartext-Zugangsdaten isoliert wiederherstellen? [j/N]: ' answer || continue
                case "${answer,,}" in
                    j|ja|y|yes) python3 -B "$HELPER" restore --input "$source" --output "$target" --confirm-restore || true ;;
                esac
            fi ;;
        5|6)
            python3 -B "$HELPER" settings || continue
            read -r -p 'Verschluesseltes Archiv (.tar.age): ' source || continue
            echo 'Adresse und Hinweis aus credential-backup-settings.json pruefen. Hinweis ist in der Mail sichtbar!'
            if [[ "$choice" == 5 ]]; then
                read -r -p 'Neuer absoluter .eml-Pfad: ' target || continue
                python3 -B "$HELPER" draft --input "$source" --output "$target" || true
            else
                read -r -p 'An den konfigurierten Empfaenger senden (externe Datenuebertragung)? [j/N]: ' answer || continue
                case "${answer,,}" in
                    j|ja|y|yes) python3 -B "$HELPER" send --input "$source" --confirm-send || true ;;
                esac
            fi ;;
        *) echo 'Bitte 0 bis 6 waehlen.' ;;
    esac
done
