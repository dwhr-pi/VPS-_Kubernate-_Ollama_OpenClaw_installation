#!/bin/bash

DEFAULT_SETUP_LANGUAGE="de"
SUPPORTED_SETUP_LANGUAGES=(de en fr zh ja ru es eo ar he)

USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-${HOME}/.openclaw_ultimate_user_data}"
SETUP_PREFERENCES_FILE="${SETUP_PREFERENCES_FILE:-$USER_WORKSPACE_DIR/setup_preferences.conf}"
LANG_FILES_DIR="${SCRIPT_ROOT_DIR}/scripts/lang"

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

ensure_setup_preferences() {
    mkdir -p "$USER_WORKSPACE_DIR"
    if [ ! -f "$SETUP_PREFERENCES_FILE" ]; then
        cat > "$SETUP_PREFERENCES_FILE" <<EOF
# Ausgelagerte Benutzer-Einstellungen für das Ultimate Setup
SETUP_LANGUAGE="$DEFAULT_SETUP_LANGUAGE"
EOF
    fi
}

persist_setup_language() {
    local language_code
    language_code="$(normalize_setup_language "$1")"
    mkdir -p "$USER_WORKSPACE_DIR"
    cat > "$SETUP_PREFERENCES_FILE" <<EOF
# Ausgelagerte Benutzer-Einstellungen für das Ultimate Setup
SETUP_LANGUAGE="$language_code"
EOF
}

load_setup_language() {
    local language_code
    ensure_setup_preferences
    # shellcheck disable=SC1090
    source "$SETUP_PREFERENCES_FILE"
    language_code="$(normalize_setup_language "${SETUP_LANGUAGE:-$DEFAULT_SETUP_LANGUAGE}")"
    SETUP_LANGUAGE="$language_code"

    if [ -f "$LANG_FILES_DIR/$SETUP_LANGUAGE.sh" ]; then
        # shellcheck disable=SC1090
        source "$LANG_FILES_DIR/$SETUP_LANGUAGE.sh"
    else
        # shellcheck disable=SC1090
        source "$LANG_FILES_DIR/$DEFAULT_SETUP_LANGUAGE.sh"
        SETUP_LANGUAGE="$DEFAULT_SETUP_LANGUAGE"
    fi
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
