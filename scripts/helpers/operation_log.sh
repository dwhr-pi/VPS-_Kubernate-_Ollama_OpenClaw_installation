#!/usr/bin/env bash
# Never substitute an unrelated historical log for the current attempt.
start_operation_log() {
    local operation="$1" slug timestamp
    ACTIVE_OPERATION_LOG_FILE=""
    LAST_OPERATION_LOG_FILE=""
    slug="$(printf '%s' "$operation" | tr -cs '[:alnum:]_.-' '_')"
    timestamp="$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$USER_INSTALL_LOG_DIR" || {
        echo 'Aktuelles Installationslog kann nicht angelegt werden; keine alte Logdatei wird verwendet.' >&2; return 1;
    }
    ACTIVE_OPERATION_LOG_FILE="$(mktemp "$USER_INSTALL_LOG_DIR/${timestamp}_${slug}_XXXXXX.log")" || {
        ACTIVE_OPERATION_LOG_FILE=""
        echo 'Log-Erstellung fehlgeschlagen (z. B. Datentraeger voll). Keine alte Logdatei wird verwendet.' >&2; return 1;
    }
    if ! printf 'Vorgang: %s\nStart: %s\n' "$operation" "$(date -Iseconds)" >> "$ACTIVE_OPERATION_LOG_FILE"; then
        echo 'Aktuelles Log nicht beschreibbar; Vorgang nicht gestartet.' >&2
        ACTIVE_OPERATION_LOG_FILE=""
        return 1
    fi
}

capture_operation_output() {
    local -a results=()
    [[ -n "${ACTIVE_OPERATION_LOG_FILE:-}" && -f "$ACTIVE_OPERATION_LOG_FILE" ]] || {
        echo 'Keine aktuelle Logdatei; Aktion nicht gestartet.' >&2; return 74;
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
