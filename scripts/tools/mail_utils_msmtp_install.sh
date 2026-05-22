#!/bin/bash
# ==============================================================================
# MAIL_UTILS_MSMTP_INSTALL.SH - Lokale Mailausgabe fuer Diagnoseberichte
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Mail_Utils_MSMTP"

USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
MAIL_CONFIG_DIR="$USER_WORKSPACE_DIR/mail"
MSMTP_TEMPLATE="$MAIL_CONFIG_DIR/msmtprc.template"
MAIL_SETTINGS_TEMPLATE="$MAIL_CONFIG_DIR/mail_settings.env.template"
MAIL_README="$MAIL_CONFIG_DIR/README.md"

echo -e "${BLUE}Installiere Mail-Tools fuer Diagnoseberichte...${NC}"
echo -e "${YELLOW}Hinweis: Es werden keine SMTP-Passwoerter oder Zugangsdaten ins Repository geschrieben.${NC}"

if command -v mail >/dev/null 2>&1 && command -v sendmail >/dev/null 2>&1; then
    echo -e "${GREEN}mail und sendmail sind bereits vorhanden. Paketinstallation wird uebersprungen.${NC}"
elif [ "$(id -u)" -eq 0 ]; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils msmtp msmtp-mta ca-certificates
elif sudo -n true 2>/dev/null; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils msmtp msmtp-mta ca-certificates
else
    echo -e "${RED}Fehler: sudo ist nicht ohne Passwort-Prompt verfuegbar.${NC}"
    echo "Bitte interaktiv im Setup ausfuehren oder vorher installieren:"
    echo "  sudo apt-get update"
    echo "  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mailutils msmtp msmtp-mta ca-certificates"
    exit 1
fi

mkdir -p "$MAIL_CONFIG_DIR"
chmod 700 "$MAIL_CONFIG_DIR" 2>/dev/null || true

if [ ! -f "$MSMTP_TEMPLATE" ]; then
    cat > "$MSMTP_TEMPLATE" <<'EOF'
# msmtp Beispielkonfiguration
# Kopiere diese Datei bei Bedarf nach ~/.msmtprc und passe sie lokal an.
# Keine echten Passwoerter, App-Passwoerter oder Tokens ins Repository schreiben.

defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.openclaw_ultimate_user_data/mail/msmtp.log

account        default
host           smtp.example.org
port           587
from           dein.absender@example.org
user           dein.absender@example.org
passwordeval   "pass show smtp/dein.absender@example.org"

# WEB.DE Beispiel ohne Zugangsdaten:
# host smtp.web.de
# port 587
# from deine-adresse@web.de
# user deine-adresse@web.de
# tls_starttls on
# Alternative: Port 465 mit tls_starttls off und tls on, falls bewusst SSL/TLS genutzt wird.

# Alternative ohne pass:
# passwordeval "cat ~/.openclaw_ultimate_user_data/mail/smtp_password"
# Die Datei smtp_password muss chmod 600 haben und darf nie ins Repo.
EOF
    chmod 600 "$MSMTP_TEMPLATE" 2>/dev/null || true
fi

if [ ! -f "$MAIL_SETTINGS_TEMPLATE" ]; then
    cat > "$MAIL_SETTINGS_TEMPLATE" <<'EOF'
# OpenClaw Diagnose-Mail Einstellungen
# Diese Datei dient nur als Hinweis. Nutze bevorzugt das Setup-Menue, damit der
# Diagnose-Empfaenger verschluesselt als DEFAULT_EMAIL_TO_ENC gespeichert wird.
# Keine Passwoerter, Tokens oder Empfaengeradressen im Klartext ins Repo schreiben.

MAIL_FROM="deine-adresse@web.de"
MSMTP_ACCOUNT="default"
EOF
    chmod 600 "$MAIL_SETTINGS_TEMPLATE" 2>/dev/null || true
fi

cat > "$MAIL_README" <<'EOF'
# Mailausgabe fuer OpenClaw Setup-Diagnose

Dieses Verzeichnis enthaelt lokale Mail-Hinweise fuer Diagnoseberichte.

Installierte Pakete:

- `mailutils`
- `msmtp`
- `msmtp-mta`

Test ohne echte externe Zustellung:

```bash
command -v mail
command -v sendmail
```

Sicherer Konfigurationsweg:

Empfohlen ueber das Setup-Menue:

```bash
bash ~/openclaw_ultimate_setup/setup_ultimate.sh
# Optionen -> E-Mail-Diagnose konfigurieren / Testmail senden
```

Manuell:

1. `~/.openclaw_ultimate_user_data/mail/msmtprc.template` nach `~/.msmtprc` kopieren.
2. SMTP-Host, Absender und Benutzer lokal anpassen.
3. Passwort nur lokal ueber `pass`, `passwordeval` oder eine Datei mit `chmod 600` einbinden.
4. `~/.openclaw_ultimate_user_data/mail/mail_settings.env.template` nach `~/.openclaw_ultimate_user_data/mail/mail_settings.env` kopieren.
5. Dort `MAIL_FROM` auf die erlaubte SMTP-Absenderadresse setzen.
6. Keine Zugangsdaten ins Repository schreiben.

Wichtig beim E-Mail-Anbieter:

- SMTP/IMAP bzw. Zugriff fuer Drittanbieter-Apps muss oft erst aktiviert werden.
- Das ist vergleichbar mit Mail-Apps auf Handy oder Tablet.
- Bei manchen Anbietern ist ein App-Passwort noetig statt des normalen Login-Passworts.

Testversand:

```bash
# Empfaenger ueber das Setup-Menue verschluesselt konfigurieren, dann:
bash ~/openclaw_ultimate_setup/scripts/mail_config_manager.sh
```

Diagnosebericht senden:

```bash
bash ~/openclaw_ultimate_setup/scripts/tool_log_diagnostics.sh --tool Huginn --email
```
EOF

echo -e "${GREEN}Mail-Tools installiert.${NC}"
echo -e "${YELLOW}Konfigurationsvorlage:${NC} $MSMTP_TEMPLATE"
echo -e "${YELLOW}Hinweis:${NC} Ohne lokale SMTP-Konfiguration kann mail/sendmail zwar vorhanden sein, aber externe Zustellung ist nicht garantiert."

mark_current_tool_installed
