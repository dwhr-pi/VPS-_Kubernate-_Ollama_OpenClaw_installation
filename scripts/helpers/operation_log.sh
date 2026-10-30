#!/usr/bin/env bash
# Never substitute an unrelated historical log for the current attempt.
operation_tool_name() {
  local operation="$1" tool
  case "$operation" in
    tool_install_* | tool_uninstall_* | tool_update_* | tool_repair_* | tool_check_* | tool_doctor_* | tool_status_*)
      tool="${operation#tool_}"
      tool="${tool#*_}"
      [[ "$tool" =~ ^[[:alnum:]_.-]+$ ]] || return 1
      printf '%s\n' "$tool"
      ;;
    *) return 1 ;;
  esac
}

operation_log_color_enabled() {
  [[ -z "${NO_COLOR:-}" && "${TERM:-}" != dumb ]] && { [[ -t 1 ]] || [[ "${FORCE_COLOR:-0}" == 1 ]]; }
}

print_operation_tool_name() {
  local tool="$1"
  [[ -n "$tool" ]] || return 0
  if operation_log_color_enabled; then
    printf 'Tool: \033[1;36m%s\033[0m\n' "$tool"
  else
    printf 'Tool: %s\n' "$tool"
  fi
}

operation_log_tool_name() {
  local file="$1" line tool count=0
  [[ -f "$file" ]] || return 1
  # Inspect only the header, never execute text from the log.
  while IFS= read -r line || [[ -n "$line" ]]; do
    count=$((count + 1))
    if [[ "$line" =~ ^([[:alnum:]_.-]+):[[:space:]](install|update|repair|uninstall)[[:space:]]Log: ]]; then
      printf '%s\n' "${BASH_REMATCH[1]}"
      return 0
    fi
    case "$line" in
      'Tool: '*)
        tool="${line#Tool: }"
        if [[ "$tool" =~ ^[[:alnum:]_.-]+$ ]]; then
          printf '%s\n' "$tool"
          return 0
        fi
        ;;
      'Vorgang: '*)
        if tool="$(operation_tool_name "${line#Vorgang: }")"; then
          printf '%s\n' "$tool"
          return 0
        fi
        ;;
    esac
    ((count < 32)) || break
  done <"$file"
  return 1
}

print_operation_log_heading() {
  local file="$1" tool
  if operation_log_color_enabled; then
    printf '\033[1;33mInstallationsprotokoll:\033[0m %s\n' "$file"
  else
    printf 'Installationsprotokoll: %s\n' "$file"
  fi
  if tool="$(operation_log_tool_name "$file")"; then
    print_operation_tool_name "$tool"
  fi
}

start_operation_log() {
  local operation="$1" slug timestamp tool="" header
  ACTIVE_OPERATION_LOG_FILE=""
  LAST_OPERATION_LOG_FILE=""
  slug="$(printf '%s' "$operation" | tr -cs '[:alnum:]_.-' '_')"
  timestamp="$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$USER_INSTALL_LOG_DIR" || {
    echo 'Aktuelles Installationslog kann nicht angelegt werden; keine alte Logdatei wird verwendet.' >&2
    return 1
  }
  ACTIVE_OPERATION_LOG_FILE="$(mktemp "$USER_INSTALL_LOG_DIR/${timestamp}_${slug}_XXXXXX.log")" || {
    ACTIVE_OPERATION_LOG_FILE=""
    echo 'Log-Erstellung fehlgeschlagen (z. B. Datentraeger voll). Keine alte Logdatei wird verwendet.' >&2
    return 1
  }
  tool="$(operation_tool_name "$operation")" || tool=""
  if [[ -n "$tool" ]]; then
    printf -v header 'Vorgang: %s\nTool: %s\nStart: %s\n' "$operation" "$tool" "$(date -Iseconds)"
  else
    printf -v header 'Vorgang: %s\nStart: %s\n' "$operation" "$(date -Iseconds)"
  fi
  if ! printf '%s' "$header" >>"$ACTIVE_OPERATION_LOG_FILE"; then
    echo 'Aktuelles Log nicht beschreibbar; Vorgang nicht gestartet.' >&2
    ACTIVE_OPERATION_LOG_FILE=""
    return 1
  fi
  print_operation_tool_name "$tool"
}

capture_operation_output() {
  local -a results=()
  [[ -n "${ACTIVE_OPERATION_LOG_FILE:-}" && -f "$ACTIVE_OPERATION_LOG_FILE" ]] || {
    echo 'Keine aktuelle Logdatei; Aktion nicht gestartet.' >&2
    return 74
  }
  if "$@" 2>&1 | tee -a "$ACTIVE_OPERATION_LOG_FILE"; then
    results=("${PIPESTATUS[@]}")
  else
    results=("${PIPESTATUS[@]}")
  fi
  if [[ "${results[1]}" != 0 ]]; then
    echo 'Aktuelles Log konnte nicht vollstaendig geschrieben werden (moeglicherweise Speicherplatzmangel). Keine alten Logs als Ersatz.' >&2
  fi
  [[ "${results[0]}" == 0 ]] || return "${results[0]}"
  [[ "${results[1]}" == 0 ]] || return 74
}

append_operation_note() {
  capture_operation_output printf '%s\n' "$1"
}
