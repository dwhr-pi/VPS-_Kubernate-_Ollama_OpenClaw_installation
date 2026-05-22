#!/usr/bin/env bash
# Lokale Hilfsfunktionen fuer Diagnose-Mail-Konfiguration.
# Die Empfaengeradresse wird nicht im Klartext gespeichert, sondern lokal mit
# einem Schluessel unter ~/.openclaw_ultimate_user_data/mail verschluesselt.

OPENCLAW_PRODUCT_ID="${OPENCLAW_PRODUCT_ID:-OpenClaw Ultimate Setup}"
USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-$HOME/.openclaw_ultimate_user_data}"
MAIL_CONFIG_DIR="${MAIL_CONFIG_DIR:-$USER_WORKSPACE_DIR/mail}"
MAIL_SETTINGS_FILE="${MAIL_SETTINGS_FILE:-$MAIL_CONFIG_DIR/mail_settings.env}"
MAIL_RECIPIENT_KEY_FILE="${MAIL_RECIPIENT_KEY_FILE:-$MAIL_CONFIG_DIR/diagnostic_recipient.key}"

ensure_mail_crypto_workspace() {
    mkdir -p "$MAIL_CONFIG_DIR"
    chmod 700 "$MAIL_CONFIG_DIR" 2>/dev/null || true
}

ensure_mail_crypto_key() {
    ensure_mail_crypto_workspace
    if [ ! -f "$MAIL_RECIPIENT_KEY_FILE" ]; then
        if command -v openssl >/dev/null 2>&1; then
            openssl rand -base64 32 > "$MAIL_RECIPIENT_KEY_FILE"
        else
            umask 077
            date +%s%N | sha256sum | awk '{print $1}' > "$MAIL_RECIPIENT_KEY_FILE"
        fi
    fi
    chmod 600 "$MAIL_RECIPIENT_KEY_FILE" 2>/dev/null || true
}

encrypt_mail_value() {
    local value="$1"
    ensure_mail_crypto_key
    if ! command -v openssl >/dev/null 2>&1; then
        return 1
    fi
    printf '%s' "$value" | openssl enc -aes-256-cbc -pbkdf2 -salt -a -A -pass "file:$MAIL_RECIPIENT_KEY_FILE"
}

decrypt_mail_value() {
    local value="$1"
    ensure_mail_crypto_key
    if ! command -v openssl >/dev/null 2>&1; then
        return 1
    fi
    printf '%s' "$value" | openssl enc -d -aes-256-cbc -pbkdf2 -a -A -pass "file:$MAIL_RECIPIENT_KEY_FILE" 2>/dev/null
}

load_secure_mail_settings() {
    DEFAULT_EMAIL_TO="${DEFAULT_EMAIL_TO:-}"
    MAIL_FROM="${MAIL_FROM:-}"
    SMTP_HOST="${SMTP_HOST:-smtp.web.de}"
    SMTP_PORT="${SMTP_PORT:-587}"
    SMTP_TLS="${SMTP_TLS:-on}"
    SMTP_TLS_STARTTLS="${SMTP_TLS_STARTTLS:-on}"
    MSMTP_ACCOUNT="${MSMTP_ACCOUNT:-default}"

    if [ -f "$MAIL_SETTINGS_FILE" ]; then
        # shellcheck disable=SC1090
        source "$MAIL_SETTINGS_FILE"
    fi

    if [ -n "${DEFAULT_EMAIL_TO_ENC:-}" ]; then
        DEFAULT_EMAIL_TO="$(decrypt_mail_value "$DEFAULT_EMAIL_TO_ENC" || true)"
    fi
}

write_secure_mail_settings() {
    ensure_mail_crypto_workspace
    local encrypted_to=""

    if [ -n "${DEFAULT_EMAIL_TO:-}" ]; then
        encrypted_to="$(encrypt_mail_value "$DEFAULT_EMAIL_TO")"
    fi

    cat > "$MAIL_SETTINGS_FILE" <<EOF
# OpenClaw Diagnose-Mail Einstellungen
# Keine Passwoerter oder Tokens in diese Datei schreiben.
# Der Diagnose-Empfaenger ist lokal verschluesselt.
# Schluesseldatei: $MAIL_RECIPIENT_KEY_FILE

MAIL_FROM="${MAIL_FROM:-}"
SMTP_HOST="${SMTP_HOST:-smtp.web.de}"
SMTP_PORT="${SMTP_PORT:-587}"
SMTP_TLS="${SMTP_TLS:-on}"
SMTP_TLS_STARTTLS="${SMTP_TLS_STARTTLS:-on}"
MSMTP_ACCOUNT="${MSMTP_ACCOUNT:-default}"
DEFAULT_EMAIL_TO_ENC="${encrypted_to}"
EOF
    chmod 600 "$MAIL_SETTINGS_FILE" 2>/dev/null || true
}

infer_tool_name_from_log_path() {
    local log_path="$1"
    local base
    base="$(basename "$log_path")"
    case "$base" in
        *_tool_install_*.log)
            base="${base#*_tool_install_}"
            printf '%s' "${base%.log}"
            ;;
        *_tool_uninstall_*.log)
            base="${base#*_tool_uninstall_}"
            printf '%s' "${base%.log}"
            ;;
        *)
            printf ''
            ;;
    esac
}

make_diagnostic_report_id() {
    local tool="$1"
    local timestamp="$2"
    local safe_tool
    safe_tool="$(printf '%s' "${tool:-unknown}" | tr -cs '[:alnum:]_.-' '_')"
    printf 'openclaw-setup-%s-%s' "$safe_tool" "$timestamp"
}
