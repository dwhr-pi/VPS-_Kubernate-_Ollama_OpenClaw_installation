#!/usr/bin/env bash
# Explicit local documentation lifecycle; merely opening this menu changes nothing.
set -euo pipefail

markdown_docs_dialog_result() {
  case "$1" in
    1 | 255) return 0 ;;
    *) return "$1" ;;
  esac
}

markdown_docs_document() {
  case "$1" in
    guide) printf '%s\n' 'docs/tools/markdown-docs-server.md' ;;
    index) printf '%s\n' 'docs/readme.md' ;;
    metrics) printf '%s\n' 'docs/INSTALLATION_BENCHMARKS.md' ;;
    linux) printf '%s\n' 'docs/LINUX_INSTALL_LAB.md' ;;
    wsl) printf '%s\n' 'docs/WSL_INSTALL_LAB.md' ;;
    *) return 2 ;;
  esac
}

markdown_docs_terminal_size() {
  # Query the terminal, not the install transaction's redirected output.
  { stty size </dev/tty; } 2>/dev/null
}

markdown_docs_dialog() {
  local height="$1" width="$2" size rows cols widget body
  local -a position=() options=()
  shift 2
  while (($#)); do
    case "$1" in
      --menu | --textbox | --inputbox | --yesno) break ;;
      *)
        options+=("$1")
        shift
        ;;
    esac
  done
  widget="$1" body="$2"
  shift 2
  if size="$(markdown_docs_terminal_size)" && [[ "$size" =~ ^([1-9][0-9]{0,4})[[:blank:]]+([1-9][0-9]{0,4})$ ]]; then
    rows="${BASH_REMATCH[1]}"
    cols="${BASH_REMATCH[2]}"
    if ((rows >= 13 && cols >= 42)); then
      ((height <= rows - 4)) || height=$((rows - 4))
      ((width <= cols - 4)) || width=$((cols - 4))
      position=(--begin "$(((rows - height) / 2))" "$(((cols - width) / 2))")
    else
      height=0 width=0
    fi
  else
    height=0 width=0
  fi
  if [[ "$widget" == --menu ]] && ((height == 0 || height < $1 + 10)); then
    set -- 0 "${@:2}"
  fi
  # Keep screen output on the terminal even when the install wrapper logs stdout.
  DIALOG_TTY=1 dialog --clear --no-shadow --backtitle 'OpenClaw Ultimate Setup | Offline-Handbuch' \
    "${position[@]}" "${options[@]}" "$widget" "$body" "$height" "$width" "$@"
}

markdown_docs_confirm_source() {
  local action="$1" commit="$2"
  markdown_docs_dialog 11 76 --defaultno --title 'GitHub-Quellen bewusst einrichten?' --yes-label 'Ja' --no-label 'Nein' \
    --yesno "Aktion: $action\nQuellstand: $commit\n\nGitHub-Quellen herunterladen und privat pruefen/einrichten? Kein Docker, Browser-, Dienst- oder Modellstart. Updates behalten den alten Snapshot."
}

markdown_docs_action() {
  local action="$1" root="$2" commit port relative
  local cancel_rc="${3:-0}" rc
  local python="${GAP_TOOLS_PYTHON_BIN:-python3}"
  case "$action" in
    guide | index | metrics | linux | wsl)
      relative="$(markdown_docs_document "$action")" || return $?
      if markdown_docs_dialog 28 100 --title 'Lokale Dokumentation' --exit-label 'Zurueck' --textbox "$root/$relative"; then
        :
      else
        markdown_docs_dialog_result "$?"
      fi
      ;;
    plan)
      "$python" -I -B "$root/scripts/documentation_server/lifecycle.py" install
      ;;
    install | update)
      if commit="$(markdown_docs_dialog 13 94 --stdout --title 'Gepruefter GitHub-Quellstand' --cancel-label 'Abbrechen' \
        --inputbox 'Vollstaendigen, bewusst geprueften Commit (40 kleine Hex-Zeichen) eingeben. Er muss bereits auf GitHub stehen und den Server enthalten. Enter ohne Wert bricht ab.')"; then
        :
      else
        rc=$?
        markdown_docs_dialog_result "$rc" || return $?
        return "$cancel_rc"
      fi
      [[ -n "$commit" ]] || return "$cancel_rc"
      if [[ ! "$commit" =~ ^[0-9a-f]{40}$ ]]; then
        printf '%s\n' 'Ungueltiger Commit; keine Aenderung.' >&2
        return 2
      fi
      if markdown_docs_confirm_source "$action" "$commit"; then
        "$python" -I -B "$root/scripts/documentation_server/lifecycle.py" "$action" --source-commit "$commit" --apply
      else
        rc=$?
        markdown_docs_dialog_result "$rc" || return $?
        return "$cancel_rc"
      fi
      ;;
    status | doctor)
      "$python" -I -B "$root/scripts/documentation_server/lifecycle.py" "$action"
      ;;
    serve)
      if port="$(markdown_docs_dialog 11 88 --stdout --title 'Lokaler Handbuch-Port' --cancel-label 'Abbrechen' \
        --inputbox 'Nur 127.0.0.1; Port 1024-65535. Stoppen mit Strg+C im Terminal. Kein Browser-Autostart. Ein leerer Wert bricht ab.' 8765)"; then
        :
      else
        markdown_docs_dialog_result "$?"
        return $?
      fi
      [[ -n "$port" ]] || return 0
      if [[ ! "$port" =~ ^[1-9][0-9]{3,4}$ ]] || ((10#$port < 1024 || 10#$port > 65535)); then
        printf '%s\n' 'Ungueltiger Port; kein Start.' >&2
        return 2
      fi
      if markdown_docs_dialog 13 88 --defaultno --title 'Handbuch bewusst starten?' --yes-label 'Ja' --no-label 'Nein' \
        --yesno "Den bereits installierten Server jetzt im Vordergrund starten?\nhttp://127.0.0.1:$port\n\nStop: Strg+C. Keine Firewall-Freigabe, kein Tunnel, kein Hintergrunddienst."; then
        "$python" -I -B "$root/scripts/documentation_server/lifecycle.py" serve --port "$port" --apply
      else
        markdown_docs_dialog_result "$?"
      fi
      ;;
    uninstall)
      if markdown_docs_dialog 12 90 --defaultno --title 'Nur Handbuch-App entfernen?' --yes-label 'Ja' --no-label 'Nein' \
        --yesno 'Nur die unveraenderte, hashgepruefte Handbuch-App entfernen? Vorher den Server mit Strg+C stoppen. Messwerte, Update-Historie, Backups und andere Tools bleiben erhalten.'; then
        "$python" -I -B "$root/scripts/documentation_server/lifecycle.py" uninstall --apply
      else
        markdown_docs_dialog_result "$?"
      fi
      ;;
    *) return 2 ;;
  esac
}

markdown_docs_menu() {
  local root choice rc
  root="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
  while :; do
    if choice="$(markdown_docs_dialog 26 100 --stdout --title 'OFFLINE-HANDBUCH / MARKDOWNSERVER' --cancel-label 'Zurueck' \
      --menu 'Enter waehlt aus; Zurueck/Esc beendet. Lesen ist offline. Installieren, Update, Start und Entfernen brauchen jeweils eine gesonderte Freigabe.' 12 \
      guide 'Einrichtung, Start, Stop, Update und Rollback lesen' \
      index 'Dokumentations-Wegweiser lesen' \
      metrics 'Installation: Zeit, Speicher und Messwert-Backups' \
      linux 'Testlabor fuer normales Linux (nur Anleitung)' \
      wsl 'Separate WSL-Testdistribution (nur Anleitung)' \
      plan 'GitHub-Installation planen (kein Download)' \
      install 'Handbuch-Quellen installieren (gepruefter Commit)' \
      status 'Vorhandene App / Quellstand pruefen' \
      doctor 'Integritaet pruefen (kein Serverstart)' \
      serve 'Installierten Server bewusst starten; Stop mit Strg+C' \
      update 'Dokumentation auf geprueften GitHub-Commit aktualisieren' \
      uninstall 'Nur Handbuch-App entfernen (mit Freigabe)')"; then
      :
    else
      markdown_docs_dialog_result "$?"
      return $?
    fi
    rc=0
    markdown_docs_action "$choice" "$root" || rc=$?
    if ((rc != 0)); then
      printf 'Aktion nicht erfolgreich (Exitcode %s); keine Erfolgsfreigabe. Ausgabe pruefen.\n' "$rc" >&2
    fi
    read -r -p 'Enter zurueck zum Handbuch-Menue...' || return 0
  done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ "$#" == 0 ]]; then
    markdown_docs_menu
  elif [[ "$#" == 2 && "$1" == --action && "$2" =~ ^(install|update)$ ]]; then
    # A cancelled tool transaction must never become a successful install metric.
    markdown_docs_action "$2" "$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)" 2
  else
    printf '%s\n' 'Erlaubt: ohne Argumente oder --action install|update.' >&2
    exit 2
  fi
fi
