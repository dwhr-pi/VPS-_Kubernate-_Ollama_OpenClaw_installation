#!/bin/bash
# ==============================================================================
# MAIL_CONFIG_MANAGER.SH - Lokaler Editor fuer Diagnose-Mailversand
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-${HOME}/.openclaw_ultimate_user_data}"
MAIL_CONFIG_DIR="$USER_WORKSPACE_DIR/mail"
MAIL_SETTINGS_FILE="$MAIL_CONFIG_DIR/mail_settings.env"
SMTP_PASSWORD_FILE="$MAIL_CONFIG_DIR/smtp_password"
MSMTPRC_FILE="$HOME/.msmtprc"
MSMTP_LOG_FILE="$MAIL_CONFIG_DIR/msmtp.log"
TEST_MAIL_FILE="$MAIL_CONFIG_DIR/last_test_mail.txt"
DEFAULT_TEST_TO="ai-chat-to-markdown@web.de"

ensure_mail_workspace() {
    mkdir -p "$MAIL_CONFIG_DIR"
    chmod 700 "$MAIL_CONFIG_DIR" 2>/dev/null || true
}

load_mail_settings() {
    ensure_mail_workspace
    MAIL_FROM="${MAIL_FROM:-}"
    SMTP_HOST="${SMTP_HOST:-smtp.web.de}"
    SMTP_PORT="${SMTP_PORT:-587}"
    SMTP_TLS_STARTTLS="${SMTP_TLS_STARTTLS:-on}"
    SMTP_TLS="${SMTP_TLS:-on}"
    MSMTP_ACCOUNT="${MSMTP_ACCOUNT:-default}"
    DEFAULT_EMAIL_TO="${DEFAULT_EMAIL_TO:-$DEFAULT_TEST_TO}"

    if [ -f "$MAIL_SETTINGS_FILE" ]; then
        # shellcheck disable=SC1090
        source "$MAIL_SETTINGS_FILE"
    fi
}

write_mail_settings() {
    ensure_mail_workspace
    cat > "$MAIL_SETTINGS_FILE" <<EOF
# OpenClaw Diagnose-Mail Einstellungen
# Keine Passwoerter oder Tokens in diese Datei schreiben.
# Das SMTP-/App-Passwort liegt getrennt in:
# $SMTP_PASSWORD_FILE

MAIL_FROM="${MAIL_FROM}"
SMTP_HOST="${SMTP_HOST}"
SMTP_PORT="${SMTP_PORT}"
SMTP_TLS="${SMTP_TLS}"
SMTP_TLS_STARTTLS="${SMTP_TLS_STARTTLS}"
MSMTP_ACCOUNT="${MSMTP_ACCOUNT}"
DEFAULT_EMAIL_TO="${DEFAULT_EMAIL_TO}"
EOF
    chmod 600 "$MAIL_SETTINGS_FILE" 2>/dev/null || true
}

write_msmtprc() {
    ensure_mail_workspace
    cat > "$MSMTPRC_FILE" <<EOF
defaults
auth           on
tls            ${SMTP_TLS}
tls_starttls   ${SMTP_TLS_STARTTLS}
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ${MSMTP_LOG_FILE}

account        ${MSMTP_ACCOUNT}
host           ${SMTP_HOST}
port           ${SMTP_PORT}
from           ${MAIL_FROM}
user           ${MAIL_FROM}
passwordeval   "cat ${SMTP_PASSWORD_FILE}"
EOF
    chmod 600 "$MSMTPRC_FILE" 2>/dev/null || true
}

ensure_mail_tools() {
    if command -v msmtp >/dev/null 2>&1 && command -v mail >/dev/null 2>&1 && command -v sendmail >/dev/null 2>&1; then
        return 0
    fi

    echo -e "${YELLOW}Mail-Tools fehlen teilweise. Installiere Mail_Utils_MSMTP automatisch...${NC}"
    INSTALL_DIR="$INSTALL_DIR" bash "$INSTALL_DIR/scripts/tools/mail_utils_msmtp_install.sh"
}

edit_mail_settings_dialog() {
    load_mail_settings
    local tmp_form
    tmp_form="$(mktemp)"

    dialog --clear --backtitle "OpenClaw Ultimate Setup" \
    --title "E-MAIL-DIAGNOSE KONFIGURATION" \
    --form "SMTP-Daten fuer Diagnoseberichte. Hinweis: Beim E-Mail-Anbieter muss SMTP/IMAP fuer Drittanbieter-Apps aktiviert sein." 22 100 10 \
    "Absender / SMTP-User:" 1 1 "$MAIL_FROM" 1 28 60 120 \
    "SMTP-Host:" 2 1 "$SMTP_HOST" 2 28 60 120 \
    "SMTP-Port:" 3 1 "$SMTP_PORT" 3 28 60 10 \
    "TLS:" 4 1 "$SMTP_TLS" 4 28 60 10 \
    "STARTTLS:" 5 1 "$SMTP_TLS_STARTTLS" 5 28 60 10 \
    "msmtp Account:" 6 1 "$MSMTP_ACCOUNT" 6 28 60 40 \
    "Test-Empfaenger:" 7 1 "$DEFAULT_EMAIL_TO" 7 28 60 120 \
    2> "$tmp_form"

    if [ $? -ne 0 ]; then
        rm -f "$tmp_form"
        return 0
    fi

    mapfile -t values < "$tmp_form"
    rm -f "$tmp_form"

    MAIL_FROM="${values[0]:-}"
    SMTP_HOST="${values[1]:-smtp.web.de}"
    SMTP_PORT="${values[2]:-587}"
    SMTP_TLS="${values[3]:-on}"
    SMTP_TLS_STARTTLS="${values[4]:-on}"
    MSMTP_ACCOUNT="${values[5]:-default}"
    DEFAULT_EMAIL_TO="${values[6]:-$DEFAULT_TEST_TO}"

    if [ -z "$MAIL_FROM" ]; then
        dialog --msgbox "Absenderadresse darf nicht leer sein." 8 70
        return 1
    fi

    write_mail_settings
    write_msmtprc
    ensure_mail_tools

    dialog --msgbox "E-Mail-Einstellungen wurden gespeichert.\n\nPasswort bitte separat ueber den Passwort-Menuepunkt setzen.\n\nWichtig: Beim E-Mail-Anbieter muss SMTP/IMAP bzw. Drittanbieter-App-Zugriff aktiviert sein." 13 90
}

edit_password_dialog() {
    load_mail_settings
    local tmp_pass
    tmp_pass="$(mktemp)"
    chmod 600 "$tmp_pass" 2>/dev/null || true

    dialog --clear --backtitle "OpenClaw Ultimate Setup" \
    --title "SMTP-PASSWORT / APP-PASSWORT" \
    --insecure --passwordbox "SMTP- oder App-Passwort lokal speichern.\n\nEs wird nur in $SMTP_PASSWORD_FILE gespeichert, chmod 600.\nNicht ins Repo schreiben." 12 92 2> "$tmp_pass"

    if [ $? -ne 0 ]; then
        rm -f "$tmp_pass"
        return 0
    fi

    ensure_mail_workspace
    cp "$tmp_pass" "$SMTP_PASSWORD_FILE"
    rm -f "$tmp_pass"
    chmod 600 "$SMTP_PASSWORD_FILE"
    write_msmtprc
    ensure_mail_tools

    dialog --msgbox "SMTP-Passwort wurde lokal gespeichert.\n\nDatei: $SMTP_PASSWORD_FILE\nRechte: chmod 600" 10 82
}

send_test_mail() {
    load_mail_settings
    ensure_mail_tools

    if [ -z "${MAIL_FROM:-}" ] || [ ! -f "$SMTP_PASSWORD_FILE" ]; then
        dialog --msgbox "Bitte zuerst Absenderadresse und SMTP-Passwort eintragen." 8 76
        return 1
    fi

    write_msmtprc
    ensure_mail_workspace
    cat > "$TEST_MAIL_FILE" <<EOF
From: ${MAIL_FROM}
To: ${DEFAULT_EMAIL_TO}
Subject: OpenClaw Diagnose-Mailtest
Content-Type: text/plain; charset=UTF-8

OpenClaw Diagnose-Mailtest
Datum: $(date '+%Y-%m-%d %H:%M:%S')

Diese Testmail enthaelt bewusst keine Installationslogs und keine Diagnoseberichte.
Sie dient nur zur Pruefung von SMTP, Absenderadresse und Zustellung.
EOF
    chmod 600 "$TEST_MAIL_FILE" 2>/dev/null || true

    if msmtp -a "$MSMTP_ACCOUNT" -f "$MAIL_FROM" "$DEFAULT_EMAIL_TO" < "$TEST_MAIL_FILE"; then
        dialog --msgbox "Testmail wurde an $DEFAULT_EMAIL_TO uebergeben.\n\nDie Testmail enthaelt keine Logs.\nLokale Testdatei:\n$TEST_MAIL_FILE\n\nDu kannst sie im Menue wieder loeschen." 13 92
    else
        dialog --msgbox "Testmail konnte nicht versendet werden.\n\nPruefe:\n$MSMTP_LOG_FILE" 9 82
        return 1
    fi
}

delete_local_test_artifacts() {
    rm -f "$TEST_MAIL_FILE"
    dialog --msgbox "Lokale Testmail-Datei wurde geloescht, falls vorhanden.\n\nHinweis: Bereits zugestellte E-Mails muessen im Postfach des Anbieters geloescht werden." 10 88
}

show_status() {
    load_mail_settings
    clear
    echo "E-Mail-Diagnose Status"
    echo
    echo "Mail-Settings: $MAIL_SETTINGS_FILE"
    echo "msmtp Config:  $MSMTPRC_FILE"
    echo "Passwortdatei: $SMTP_PASSWORD_FILE"
    echo "msmtp Log:     $MSMTP_LOG_FILE"
    echo
    echo "MAIL_FROM=${MAIL_FROM:-nicht gesetzt}"
    echo "SMTP_HOST=${SMTP_HOST:-nicht gesetzt}"
    echo "SMTP_PORT=${SMTP_PORT:-nicht gesetzt}"
    echo "DEFAULT_EMAIL_TO=${DEFAULT_EMAIL_TO:-nicht gesetzt}"
    echo
    command -v msmtp >/dev/null 2>&1 && echo "msmtp: $(command -v msmtp)" || echo "msmtp: fehlt"
    command -v mail >/dev/null 2>&1 && echo "mail:  $(command -v mail)" || echo "mail: fehlt"
    command -v sendmail >/dev/null 2>&1 && echo "sendmail: $(command -v sendmail)" || echo "sendmail: fehlt"
    echo
    [ -f "$SMTP_PASSWORD_FILE" ] && echo "SMTP-Passwortdatei: vorhanden" || echo "SMTP-Passwortdatei: fehlt"
    echo
    read -r -p "Druecken Sie Enter..."
}

main_menu() {
    ensure_mail_workspace

    while true; do
        dialog --clear --backtitle "OpenClaw Ultimate Setup" \
        --cancel-label "Zurueck" \
        --title "E-MAIL-DIAGNOSE" \
        --menu "Konfiguration fuer Diagnoseberichte per E-Mail. Keine Secrets im Repo." 22 100 6 \
        "1" ".env-aehnliche SMTP-Einstellungen bearbeiten" \
        "2" "SMTP-/App-Passwort sicher speichern" \
        "3" "Mailtools installieren / pruefen" \
        "4" "Testmail ohne Logs senden" \
        "5" "Lokale Testmail-Datei loeschen" \
        "6" "Status anzeigen" 2> /tmp/mail_config_choice

        if [ $? -ne 0 ]; then
            clear
            return 0
        fi

        case "$(cat /tmp/mail_config_choice)" in
            1) edit_mail_settings_dialog ;;
            2) edit_password_dialog ;;
            3)
                clear
                ensure_mail_tools
                echo
                read -r -p "Mailtools geprueft/installiert. Druecken Sie Enter..."
                ;;
            4) send_test_mail ;;
            5) delete_local_test_artifacts ;;
            6) show_status ;;
        esac
    done
}

main_menu "$@"
