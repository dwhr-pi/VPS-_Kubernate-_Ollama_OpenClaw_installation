#!/bin/bash

DEFAULT_SETUP_LANGUAGE="de"
DEFAULT_INSTALL_MONITORING_VERBOSE="false"
DEFAULT_INSTALL_MONITORING_MANUAL_FLOW="false"
DEFAULT_LOG_CLEANUP_BEFORE_OPERATION="false"
DEFAULT_LOG_CLEANUP_RETENTION_DAYS="14"
DEFAULT_LOG_CLEANUP_KEEP_RECENT="30"
SUPPORTED_SETUP_LANGUAGES=(de en fr zh ja ru es eo ar he)

USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-${HOME}/.openclaw_ultimate_user_data}"
SETUP_PREFERENCES_FILE="${SETUP_PREFERENCES_FILE:-$USER_WORKSPACE_DIR/setup_preferences.conf}"
LANG_FILES_DIR="${SCRIPT_ROOT_DIR}/scripts/lang"
LANGUAGE_PACKS_DIR="${LANGUAGE_PACKS_DIR:-$USER_WORKSPACE_DIR/language_packs}"

setup_language_name() {
    case "$1" in
        de) echo "Deutsch" ;;
        en) echo "English" ;;
        fr) echo "Français" ;;
        zh) echo "中文" ;;
        ja) echo "日本語" ;;
        ru) echo "Русский" ;;
        es) echo "Español" ;;
        eo) echo "Esperanto" ;;
        ar) echo "العربية" ;;
        he) echo "עברית" ;;
        *) echo "Deutsch" ;;
    esac
}

is_supported_setup_language() {
    local candidate="$1"
    local lang_code
    for lang_code in "${SUPPORTED_SETUP_LANGUAGES[@]}"; do
        if [ "$lang_code" = "$candidate" ]; then
            return 0
        fi
    done
    return 1
}

normalize_setup_language() {
    local candidate="${1:-$DEFAULT_SETUP_LANGUAGE}"
    if is_supported_setup_language "$candidate"; then
        printf '%s\n' "$candidate"
    else
        printf '%s\n' "$DEFAULT_SETUP_LANGUAGE"
    fi
}

normalize_setup_boolean() {
    local candidate="${1:-false}"
    case "$(printf '%s' "$candidate" | tr '[:upper:]' '[:lower:]')" in
        1|true|yes|on|ja)
            printf '%s\n' "true"
            ;;
        *)
            printf '%s\n' "false"
            ;;
    esac
}

ensure_setup_preferences() {
    mkdir -p "$USER_WORKSPACE_DIR"
    mkdir -p "$LANGUAGE_PACKS_DIR"
    if [ ! -f "$SETUP_PREFERENCES_FILE" ]; then
        cat > "$SETUP_PREFERENCES_FILE" <<EOF
# Ausgelagerte Benutzer-Einstellungen für das Ultimate Setup
SETUP_LANGUAGE="$DEFAULT_SETUP_LANGUAGE"
INSTALL_MONITORING_VERBOSE="$DEFAULT_INSTALL_MONITORING_VERBOSE"
INSTALL_MONITORING_MANUAL_FLOW="$DEFAULT_INSTALL_MONITORING_MANUAL_FLOW"
LOG_CLEANUP_BEFORE_OPERATION="$DEFAULT_LOG_CLEANUP_BEFORE_OPERATION"
LOG_CLEANUP_RETENTION_DAYS="$DEFAULT_LOG_CLEANUP_RETENTION_DAYS"
LOG_CLEANUP_KEEP_RECENT="$DEFAULT_LOG_CLEANUP_KEEP_RECENT"
EOF
    fi
}

persist_setup_preference() {
    local key="$1"
    local raw_value="$2"
    local normalized_value="$raw_value"
    local tmp_file

    case "$key" in
        SETUP_LANGUAGE)
            normalized_value="$(normalize_setup_language "$raw_value")"
            ;;
        INSTALL_MONITORING_VERBOSE|INSTALL_MONITORING_MANUAL_FLOW|LOG_CLEANUP_BEFORE_OPERATION)
            normalized_value="$(normalize_setup_boolean "$raw_value")"
            ;;
    esac

    ensure_setup_preferences
    mkdir -p "$USER_WORKSPACE_DIR"
    tmp_file="$(mktemp)"

    awk -v pref_key="$key" -v pref_value="$normalized_value" '
        BEGIN { updated = 0 }
        $0 ~ ("^" pref_key "=") {
            print pref_key "=\"" pref_value "\""
            updated = 1
            next
        }
        { print }
        END {
            if (updated == 0) {
                print pref_key "=\"" pref_value "\""
            }
        }
    ' "$SETUP_PREFERENCES_FILE" > "$tmp_file"

    mv "$tmp_file" "$SETUP_PREFERENCES_FILE"
}

persist_setup_language() {
    persist_setup_preference "SETUP_LANGUAGE" "$1"
}

load_setup_language_pack_overlays() {
    local language_code="${1:-$DEFAULT_SETUP_LANGUAGE}"
    local manifest_file pack_dir pack_setup_file

    [ -d "$LANGUAGE_PACKS_DIR" ] || return 0

    shopt -s nullglob
    for manifest_file in "$LANGUAGE_PACKS_DIR"/*/manifest.conf; do
        unset PACK_ID PACK_NAME PACK_LANGUAGE PACK_VERSION PACK_ENABLED PACK_DESCRIPTION
        # shellcheck disable=SC1090
        source "$manifest_file"

        if [ "${PACK_ENABLED:-true}" != "true" ]; then
            continue
        fi

        if [ "${PACK_LANGUAGE:-}" != "$language_code" ]; then
            continue
        fi

        pack_dir="$(cd "$(dirname "$manifest_file")" && pwd)"
        pack_setup_file="$pack_dir/setup/$language_code.sh"
        if [ -f "$pack_setup_file" ]; then
            # shellcheck disable=SC1090
            source "$pack_setup_file"
        fi
    done
    shopt -u nullglob
}

load_setup_language() {
    local language_code
    ensure_setup_preferences
    # shellcheck disable=SC1090
    source "$SETUP_PREFERENCES_FILE"
    language_code="$(normalize_setup_language "${SETUP_LANGUAGE:-$DEFAULT_SETUP_LANGUAGE}")"
    SETUP_LANGUAGE="$language_code"
    INSTALL_MONITORING_VERBOSE="$(normalize_setup_boolean "${INSTALL_MONITORING_VERBOSE:-$DEFAULT_INSTALL_MONITORING_VERBOSE}")"
    INSTALL_MONITORING_MANUAL_FLOW="$(normalize_setup_boolean "${INSTALL_MONITORING_MANUAL_FLOW:-$DEFAULT_INSTALL_MONITORING_MANUAL_FLOW}")"
    LOG_CLEANUP_BEFORE_OPERATION="$(normalize_setup_boolean "${LOG_CLEANUP_BEFORE_OPERATION:-$DEFAULT_LOG_CLEANUP_BEFORE_OPERATION}")"
    LOG_CLEANUP_RETENTION_DAYS="${LOG_CLEANUP_RETENTION_DAYS:-$DEFAULT_LOG_CLEANUP_RETENTION_DAYS}"
    LOG_CLEANUP_KEEP_RECENT="${LOG_CLEANUP_KEEP_RECENT:-$DEFAULT_LOG_CLEANUP_KEEP_RECENT}"

    if [ -f "$LANG_FILES_DIR/$SETUP_LANGUAGE.sh" ]; then
        # shellcheck disable=SC1090
        source "$LANG_FILES_DIR/$SETUP_LANGUAGE.sh"
    else
        # shellcheck disable=SC1090
        source "$LANG_FILES_DIR/$DEFAULT_SETUP_LANGUAGE.sh"
        SETUP_LANGUAGE="$DEFAULT_SETUP_LANGUAGE"
    fi

    load_setup_language_pack_overlays "$SETUP_LANGUAGE"
}

show_setup_language_menu() {
    local current_language="${SETUP_LANGUAGE:-$DEFAULT_SETUP_LANGUAGE}"

    dialog --clear --backtitle "$APP_TITLE" \
    --title "${TXT_LANGUAGE_MENU_TITLE:-Sprachauswahl}" \
    --menu "${TXT_LANGUAGE_MENU_PROMPT:-Bitte wählen Sie die Sprache für das Setup:}" 20 90 10 \
    "de" "Deutsch" \
    "en" "English" \
    "fr" "Français" \
    "zh" "中文" \
    "ja" "日本語" \
    "ru" "Русский" \
    "es" "Español" \
    "eo" "Esperanto" \
    "ar" "العربية" \
    "he" "עברית" 2> /tmp/setup_language_choice

    if [ $? -ne 0 ]; then
        return 1
    fi

    current_language="$(cat /tmp/setup_language_choice)"
    persist_setup_language "$current_language"
    load_setup_language
    return 0
}
