#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
uninstall_whisper_cpp() {
  local mode="${1:-uninstall}" target=/opt/whisper_cpp resolved
  case "$mode" in uninstall | --dry-run) ;; *)
    log_error 'Aufruf: whisper_cpp_uninstall.sh [--dry-run]'
    return 2
    ;;
  esac
  resolved="$(realpath -m -- "$target")" || return 1
  if [ -L "$target" ] || [ "$resolved" != "$target" ]; then
    log_error 'Unsicheres Deinstallationsziel: /opt/whisper_cpp ist ein Symlink oder verweist auf einen anderen Pfad.'
    return 1
  fi
  if [ "$mode" = --dry-run ]; then
    echo 'Plan: /opt/whisper_cpp mit sudo entfernen, einschliesslich dortiger Modelle/Daten. Keine Ausfuehrung oder Statusaenderung.'
    return 0
  fi
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_uninstall_Whisper_CPP 'Whisper.cpp entfernen'
  log_warn 'Entferne /opt/whisper_cpp einschliesslich dort gespeicherter Modelle und Aufnahmen. Vorher sichern; --dry-run zeigt nur den Plan.'
  if ! sudo rm -rf --one-file-system -- "$target"; then
    log_error 'Whisper.cpp konnte nicht entfernt werden. sudo-Rechte pruefen; Installationsstatus bleibt erhalten.'
    end_measurement failed
    return 1
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    log_error 'Whisper.cpp-Ziel ist noch vorhanden. Mounts/Rechte manuell pruefen; Installationsstatus bleibt erhalten.'
    end_measurement failed
    return 1
  fi
  mark_tool_removed Whisper_CPP
  end_measurement success
  log_success 'Whisper.cpp entfernt. Externe Modell-/Audioordner und Systempakete bleiben erhalten.'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then uninstall_whisper_cpp "$@"; fi
