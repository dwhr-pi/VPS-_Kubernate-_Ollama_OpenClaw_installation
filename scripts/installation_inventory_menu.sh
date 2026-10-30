#!/usr/bin/env bash
# Portable metadata only; never execute imported checks or installation commands.
set -u
ROOT="$(cd -- "${BASH_SOURCE[0]%/*}/.." && pwd)"
HELPER="$ROOT/scripts/operations/installation_inventory.py"
command -v python3 >/dev/null || {
  echo 'Python 3 fehlt.'
  exit 1
}
if [[ ! -t 0 ]]; then
  python3 -I -B "$HELPER" list
  exit $?
fi
while true; do
  printf '\n%s\n' 'INSTALLATIONSSTATUS / BACKUP-EXPORT'
  printf '%s\n' '1: Erfasste Programme und lokale Hinweise anzeigen'
  printf '%s\n' '2: Unabhaengigen Export erstellen (JSON + lesbare Programmliste)'
  printf '%s\n' '3: Export pruefen / Wiederherstellungsvorschau'
  printf '%s\n' '4: Vorhandene Nachweise in Statuslisten uebernehmen (Zusammenfuehren)'
  printf '%s\n' '5: ENV / API-Keys verschluesselt exportieren, wiederherstellen oder versenden'
  printf '%s\n' '0: Zurueck'
  read -r -p 'Auswahl [0]: ' choice || break
  case "$choice" in
    1) python3 -I -B "$HELPER" list || true ;;
    5) bash "$ROOT/scripts/credentials_backup_menu.sh" || true ;;
    2)
      echo 'Ziel ausserhalb des Workspace und Git-Repos waehlen, z.B. /mnt/d/Setup-Sicherung/programme.json.'
      echo 'Export muss nach Loeschen von Setup/WSL noch unabhaengig verfuegbar sein.'
      read -r -p 'Absoluter neuer JSON-Zielpfad: ' target || target=''
      [[ -z "$target" ]] || python3 -I -B "$HELPER" export --output "$target" || true
      ;;
    3 | 4)
      read -r -p 'Absoluter Pfad der Export-JSON: ' source || source=''
      [[ -n "$source" ]] || continue
      if python3 -I -B "$HELPER" preview --input "$source"; then
        if [[ "$choice" == 4 ]]; then
          echo 'Nur lokal noch vorhandene Datei-/Programmhinweise uebernehmen. Fehlende Tools bleiben offen, Profile nur historisch.'
          echo 'Alle Installer geschlossen? Export vertrauenswuerdig? Status zusammenfuehren? [j/N]'
          echo 'Warte auf Ihre Eingabe und Enter. Nur [j/ja/y/yes] erlaubt die Aktion; Nur [Enter] bedeutet: Nein.'
          read -r answer || answer=''
          case "${answer,,}" in
            j | ja | y | yes) python3 -I -B "$HELPER" restore --input "$source" --confirm-restore || true ;;
            *) echo 'Keine Wiederherstellung ausgefuehrt.' ;;
          esac
        fi
      fi
      ;;
    0 | '') break ;;
    *) echo 'Bitte 0 bis 5 waehlen.' ;;
  esac
done
exit 0
