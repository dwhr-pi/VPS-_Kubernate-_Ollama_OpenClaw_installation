#!/bin/bash
# ==============================================================================
# HUGINN_INSTALL.SH - Installation von Huginn
# Huginn ist ein Open-Source-Agentensystem, das Aktionen im Web automatisiert.
# ==============================================================================

set -euo pipefail

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Huginn"

HUGINN_DIR="${HUGINN_DIR:-/opt/huginn}"
HUGINN_REPO_URL="${HUGINN_REPO_URL:-https://github.com/huginn/huginn.git}"
HUGINN_REPO_REF="${HUGINN_REPO_REF:-v2022.08.18}"
HUGINN_DISABLE_JAVASCRIPT_AGENT_ON_LIBV8_FAILURE="${HUGINN_DISABLE_JAVASCRIPT_AGENT_ON_LIBV8_FAILURE:-true}"
HUGINN_DISABLE_GOOGLE_TRANSLATE_ON_GRPC_FAILURE="${HUGINN_DISABLE_GOOGLE_TRANSLATE_ON_GRPC_FAILURE:-true}"
HUGINN_DISABLE_GROWL_AGENT_ON_RUBY32_FAILURE="${HUGINN_DISABLE_GROWL_AGENT_ON_RUBY32_FAILURE:-true}"
HUGINN_DISABLE_FTPSITE_AGENT_ON_RUBY32_FAILURE="${HUGINN_DISABLE_FTPSITE_AGENT_ON_RUBY32_FAILURE:-true}"
HUGINN_ENABLE_NET_IMAP_COMPAT_ON_RUBY32="${HUGINN_ENABLE_NET_IMAP_COMPAT_ON_RUBY32:-true}"
HUGINN_DISABLE_GMAIL_XOAUTH_ON_NET_IMAP_FAILURE="${HUGINN_DISABLE_GMAIL_XOAUTH_ON_NET_IMAP_FAILURE:-true}"
HUGINN_ENABLE_MYSQL2_RUBY32_COMPAT="${HUGINN_ENABLE_MYSQL2_RUBY32_COMPAT:-true}"
HUGINN_ENABLE_PG_RUBY32_COMPAT="${HUGINN_ENABLE_PG_RUBY32_COMPAT:-true}"
HUGINN_SKIP_SYSTEM_PACKAGES="${HUGINN_SKIP_SYSTEM_PACKAGES:-false}"
HUGINN_ENABLE_RBENV_FOR_MASTER="${HUGINN_ENABLE_RBENV_FOR_MASTER:-true}"
HUGINN_MASTER_RUBY_VERSION="${HUGINN_MASTER_RUBY_VERSION:-3.4.9}"
HUGINN_RBENV_ROOT="${HUGINN_RBENV_ROOT:-$HOME/.rbenv-openclaw-huginn}"
HUGINN_ACTIVE_RUBY_VERSION="${HUGINN_ACTIVE_RUBY_VERSION:-}"
HUGINN_SYSTEMD_WEB_SERVICE="${HUGINN_SYSTEMD_WEB_SERVICE:-huginn-web.service}"
HUGINN_SYSTEMD_WORKER_SERVICE="${HUGINN_SYSTEMD_WORKER_SERVICE:-huginn-worker.service}"
HUGINN_UPSTREAM_DEFAULT_PORT="${HUGINN_UPSTREAM_DEFAULT_PORT:-3000}"
HUGINN_WEB_PORT="${HUGINN_WEB_PORT:-3002}"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
HUGINN_USER_CONFIG_DIR="${USER_WORKSPACE_DIR}/huginn"
HUGINN_USER_SETTINGS_FILE="${HUGINN_USER_CONFIG_DIR}/install_settings.env"
HUGINN_USER_ENV_TEMPLATE="${HUGINN_USER_CONFIG_DIR}/.env.template"

load_huginn_user_settings() {
    if [ -f "$HUGINN_USER_SETTINGS_FILE" ]; then
        # shellcheck disable=SC1090
        source "$HUGINN_USER_SETTINGS_FILE"
    fi
}

load_huginn_user_settings

bootstrap_huginn_env_from_secure_template() {
    if [ -f "$HUGINN_USER_ENV_TEMPLATE" ]; then
        cp "$HUGINN_USER_ENV_TEMPLATE" .env
        return 0
    fi

    if [ -f .env.example ]; then
        cp .env.example .env
    else
        touch .env
    fi
}

sanitize_huginn_env_database_defaults() {
    python3 - <<'PY'
from pathlib import Path

path = Path(".env")
if not path.exists():
    raise SystemExit(0)

text = path.read_text(encoding="utf-8")
replacements = {
    "DATABASE_NAME=huginn_development": "DATABASE_NAME=huginn_production",
    "DATABASE_USERNAME=root": "DATABASE_USERNAME=huginn",
    'DATABASE_PASSWORD=""': 'DATABASE_PASSWORD=change-me',
}
for old, new in replacements.items():
    text = text.replace(old, new)

path.write_text(text, encoding="utf-8")
PY
}

apply_huginn_selected_database_adapter() {
    local selected_adapter="${HUGINN_DATABASE_ADAPTER:-}"

    [ -f .env ] || return 0
    [ -n "$selected_adapter" ] || return 0

    case "$selected_adapter" in
        mysql2|postgresql)
            ;;
        *)
            echo -e "${YELLOW}Warnung: Unbekannter HUGINN_DATABASE_ADAPTER=${selected_adapter}. Bestehende .env bleibt unveraendert.${NC}"
            return 0
            ;;
    esac

    python3 - "$selected_adapter" <<'PY'
from pathlib import Path
import sys

adapter = sys.argv[1]
path = Path(".env")
text = path.read_text(encoding="utf-8") if path.exists() else ""
db_keys = {
    "DATABASE_ADAPTER",
    "DATABASE_NAME",
    "DATABASE_USERNAME",
    "DATABASE_PASSWORD",
    "DATABASE_HOST",
    "DATABASE_PORT",
}

presets = {
    "mysql2": {
        "DATABASE_ADAPTER": "mysql2",
        "DATABASE_NAME": "huginn_production",
        "DATABASE_USERNAME": "huginn",
        "DATABASE_PASSWORD": "huginn_local_change_me",
        "DATABASE_HOST": "localhost",
        "DATABASE_PORT": "3306",
    },
    "postgresql": {
        "DATABASE_ADAPTER": "postgresql",
        "DATABASE_NAME": "huginn_production",
        "DATABASE_USERNAME": "huginn",
        "DATABASE_PASSWORD": "change-me",
        "DATABASE_HOST": "127.0.0.1",
        "DATABASE_PORT": "5432",
    },
}

kept_lines = []
for line in text.splitlines():
    if line.strip() == "### Database":
        continue
    if "=" in line and not line.lstrip().startswith("#"):
        key = line.split("=", 1)[0].strip()
        if key in db_keys:
            continue
    kept_lines.append(line)

if kept_lines and kept_lines[-1].strip():
    kept_lines.append("")
kept_lines.append("### Database")
for key, value in presets[adapter].items():
    kept_lines.append(f"{key}={value}")

path.write_text("\n".join(kept_lines).rstrip() + "\n", encoding="utf-8")
PY

    echo -e "${YELLOW}Huginn Datenbankauswahl aus install_settings.env angewendet: ${selected_adapter}.${NC}"
}

current_huginn_service_user() {
    if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
        printf '%s' "$SUDO_USER"
    else
        printf '%s' "$USER"
    fi
}

current_huginn_service_home() {
    local service_user
    service_user="$(current_huginn_service_user)"
    getent passwd "$service_user" | cut -d: -f6
}

systemd_available_for_huginn() {
    command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]
}

install_huginn_systemd_units() {
    if ! systemd_available_for_huginn; then
        echo -e "${YELLOW}Hinweis: systemd ist in dieser Umgebung nicht verfuegbar. Huginn wird nicht als Dienst eingerichtet.${NC}"
        return 1
    fi

    local service_user service_home
    service_user="$(current_huginn_service_user)"
    service_home="$(current_huginn_service_home)"

    if [ -z "$service_home" ]; then
        echo -e "${YELLOW}Warnung: Konnte kein Home-Verzeichnis fuer den Huginn-Dienstbenutzer ermitteln.${NC}"
        return 1
    fi

    sudo tee "/etc/systemd/system/${HUGINN_SYSTEMD_WEB_SERVICE}" >/dev/null <<EOF
[Unit]
Description=Huginn Web Server
After=network.target mariadb.service mysql.service postgresql.service
Wants=network.target

[Service]
Type=simple
User=${service_user}
WorkingDirectory=${HUGINN_DIR}
Environment=HOME=${service_home}
Environment=RAILS_ENV=production
Environment=RAILS_SERVE_STATIC_FILES=1
Environment=RBENV_ROOT=${HUGINN_RBENV_ROOT}
Environment=RBENV_VERSION=${HUGINN_ACTIVE_RUBY_VERSION}
Environment=PATH=${HUGINN_RBENV_ROOT}/shims:${HUGINN_RBENV_ROOT}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/bin/env bash -lc 'bundle exec rails server -b 127.0.0.1 -p ${HUGINN_WEB_PORT}'
Restart=always
RestartSec=5
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF

    sudo tee "/etc/systemd/system/${HUGINN_SYSTEMD_WORKER_SERVICE}" >/dev/null <<EOF
[Unit]
Description=Huginn Worker
After=network.target mariadb.service mysql.service postgresql.service ${HUGINN_SYSTEMD_WEB_SERVICE}
Wants=network.target

[Service]
Type=simple
User=${service_user}
WorkingDirectory=${HUGINN_DIR}
Environment=HOME=${service_home}
Environment=RAILS_ENV=production
Environment=RBENV_ROOT=${HUGINN_RBENV_ROOT}
Environment=RBENV_VERSION=${HUGINN_ACTIVE_RUBY_VERSION}
Environment=PATH=${HUGINN_RBENV_ROOT}/shims:${HUGINN_RBENV_ROOT}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/bin/env bash -lc 'bundle exec rails runner bin/threaded.rb'
Restart=always
RestartSec=5
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
}

enable_and_start_huginn_systemd_units() {
    if ! systemd_available_for_huginn; then
        return 1
    fi

    sudo systemctl enable "$HUGINN_SYSTEMD_WEB_SERVICE" "$HUGINN_SYSTEMD_WORKER_SERVICE"
    sudo systemctl restart "$HUGINN_SYSTEMD_WEB_SERVICE"
    sudo systemctl restart "$HUGINN_SYSTEMD_WORKER_SERVICE"
}

ensure_secret_token() {
    if grep -Eq '^APP_SECRET_TOKEN=.+$' .env 2>/dev/null; then
        return 0
    fi

    local secret_token
    if command -v openssl >/dev/null 2>&1; then
        secret_token="$(openssl rand -hex 32)"
    else
        secret_token="$(date +%s)_huginn_secret"
    fi

    echo "APP_SECRET_TOKEN=$secret_token" >> .env
}

generate_huginn_invitation_code() {
    if [ -n "${HUGINN_INVITATION_CODE:-}" ]; then
        printf '%s' "$HUGINN_INVITATION_CODE"
        return 0
    fi

    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 12
    else
        printf 'huginn-%s' "$(date +%s)"
    fi
}

ensure_huginn_invitation_code() {
    local invitation_code

    invitation_code="$(awk -F= '/^INVITATION_CODE=/{print $2}' .env 2>/dev/null | tail -n 1 | tr -d '\r\" ')"
    if [ -n "$invitation_code" ] && [ "$invitation_code" != "try-huginn" ]; then
        return 0
    fi

    invitation_code="$(generate_huginn_invitation_code)"
    python3 - "$invitation_code" <<'PY'
from pathlib import Path
import sys

path = Path(".env")
text = path.read_text(encoding="utf-8")
code = sys.argv[1]
new_line = f"INVITATION_CODE={code}"

if "INVITATION_CODE=" in text:
    lines = text.splitlines()
    for idx, line in enumerate(lines):
        if line.startswith("INVITATION_CODE="):
            lines[idx] = new_line
            break
    text = "\n".join(lines) + ("\n" if text.endswith("\n") else "")
else:
    if text and not text.endswith("\n"):
        text += "\n"
    text += new_line + "\n"

path.write_text(text, encoding="utf-8")
PY
}

current_huginn_invitation_code() {
    awk -F= '/^INVITATION_CODE=/{print $2}' .env 2>/dev/null | tail -n 1 | tr -d '\r\" '
}

ensure_production_env_defaults() {
    if ! grep -Eq '^RAILS_ENV=' .env 2>/dev/null; then
        echo "RAILS_ENV=production" >> .env
    fi
}

apply_huginn_dry_runnable_kwarg_fix() {
    if [ ! -f app/concerns/dry_runnable.rb ]; then
        return 1
    fi

    python3 - <<'PY'
from pathlib import Path

path = Path("app/concerns/dry_runnable.rb")
text = path.read_text(encoding="utf-8")
old = """    def save(options = {})
      return super unless dry_run?
      perform_validations(options)
    end

    def save!(options = {})
      return super unless dry_run?
      save(options) or raise_record_invalid
    end
"""
new = """    def save(**options)
      return super(**options) unless dry_run?
      perform_validations(options)
    end

    def save!(**options)
      return super(**options) unless dry_run?
      save(**options) or raise_record_invalid
    end
"""
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
}

apply_huginn_jobs_yaml_fix() {
    if [ ! -f app/helpers/jobs_helper.rb ]; then
        return 1
    fi

    python3 - <<'PY'
from pathlib import Path

path = Path("app/helpers/jobs_helper.rb")
text = path.read_text(encoding="utf-8")
old = "    data = YAML.load(job.handler.to_s).try(:job_data)\n"
new = "    data = YAML.unsafe_load(job.handler.to_s).try(:job_data)\n"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
}

apply_huginn_web_request_faraday_fix() {
    if [ ! -f app/concerns/web_request_concern.rb ]; then
        return 1
    fi

    python3 - <<'PY'
from pathlib import Path

path = Path("app/concerns/web_request_concern.rb")
text = path.read_text(encoding="utf-8")
old = """  class CharacterEncoding < Faraday::Middleware
    def initialize(app, force_encoding: nil, default_encoding: nil, unzip: nil)
      super(app)
      @force_encoding   = force_encoding
      @default_encoding = default_encoding
      @unzip            = unzip
    end
"""
new = """  class CharacterEncoding < Faraday::Middleware
    def initialize(app = nil, options = nil, force_encoding: nil, default_encoding: nil, unzip: nil)
      super(app)
      options = options.is_a?(Hash) ? options : {}
      @force_encoding   = force_encoding || options[:force_encoding]
      @default_encoding = default_encoding || options[:default_encoding]
      @unzip            = unzip || options[:unzip]
    end
"""
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
}

apply_huginn_mysql_reconnect_deprecation_fix() {
    if [ ! -f config/database.yml ]; then
        return 1
    fi

    python3 - <<'PY'
from pathlib import Path

path = Path("config/database.yml")
text = path.read_text(encoding="utf-8")
old = '  reconnect: <%= ENV[\'DATABASE_RECONNECT\'].presence || "true" %>'
new = '  reconnect: <%= ENV[\'DATABASE_RECONNECT\'].presence || "false" %>'

if old in text:
    text = text.replace(old, new)
    path.write_text(text, encoding="utf-8")
PY
}

current_database_adapter() {
    awk -F= '/^DATABASE_ADAPTER=/{print $2}' .env 2>/dev/null | tail -n 1 | tr -d '\r" '
}

current_database_host() {
    awk -F= '/^DATABASE_HOST=/{print $2}' .env 2>/dev/null | tail -n 1 | tr -d '\r" '
}

current_database_name() {
    awk -F= '/^DATABASE_NAME=/{print $2}' .env 2>/dev/null | tail -n 1 | tr -d '\r" '
}

current_database_username() {
    awk -F= '/^DATABASE_USERNAME=/{print $2}' .env 2>/dev/null | tail -n 1 | tr -d '\r" '
}

current_database_password() {
    awk -F= '/^DATABASE_PASSWORD=/{print $2}' .env 2>/dev/null | tail -n 1 | tr -d '\r" '
}

mysql_local_socket_expected() {
    local host

    host="$(current_database_host)"
    [ -z "$host" ] || [ "$host" = "localhost" ]
}

print_huginn_mysql_service_guidance() {
    local host

    host="$(current_database_host)"
    if [ -z "$host" ]; then
        host="localhost/socket-default"
    fi

    echo -e "${RED}Fehler: Huginn ist auf mysql2 konfiguriert, aber lokal ist aktuell kein erreichbarer MySQL-/MariaDB-Dienst verfügbar.${NC}"
    echo -e "${YELLOW}Aktueller Adapter: mysql2${NC}"
    echo -e "${YELLOW}Aktueller Host: $host${NC}"
    echo -e "${YELLOW}Erwarteter Socket: /var/run/mysqld/mysqld.sock${NC}"
    echo -e "${YELLOW}Du hast jetzt drei sinnvolle Wege:${NC}"
    echo -e "${YELLOW}1. Lokalen MySQL- oder MariaDB-Server installieren und starten.${NC}"
    echo -e "${YELLOW}2. In $HUGINN_DIR/.env einen externen MySQL-Host über DATABASE_HOST und optional DATABASE_PORT eintragen.${NC}"
    echo -e "${YELLOW}3. Huginn auf postgresql oder sqlite3 umstellen, wenn du keinen lokalen MySQL-Dienst betreiben willst.${NC}"
}

mysql_service_available_for_huginn() {
    if [ "$(current_database_adapter)" != "mysql2" ]; then
        return 0
    fi

    if ! mysql_local_socket_expected; then
        return 0
    fi

    [ -S /var/run/mysqld/mysqld.sock ]
}

postgresql_local_expected() {
    local host

    host="$(current_database_host)"
    [ -z "$host" ] || [ "$host" = "localhost" ] || [ "$host" = "127.0.0.1" ]
}

start_postgresql_service_for_huginn() {
    if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
        sudo systemctl enable postgresql >/dev/null 2>&1 || true
        sudo systemctl start postgresql
        return $?
    fi

    if command -v pg_ctlcluster >/dev/null 2>&1; then
        local cluster_version
        cluster_version="$(pg_lsclusters --no-header 2>/dev/null | awk 'NR == 1 {print $1}')"
        if [ -n "$cluster_version" ]; then
            sudo pg_ctlcluster "$cluster_version" main start
            return $?
        fi
    fi

    if command -v service >/dev/null 2>&1; then
        sudo service postgresql start
        return $?
    fi

    return 1
}

prepare_postgresql_database_for_huginn() {
    local db_user db_password db_name db_user_ident db_user_literal db_password_literal

    if [ "$(current_database_adapter)" != "postgresql" ]; then
        return 0
    fi

    if ! postgresql_local_expected; then
        echo -e "${YELLOW}PostgreSQL ist auf einen externen Host konfiguriert. Lokale Role-/DB-Vorbereitung wird uebersprungen.${NC}"
        return 0
    fi

    db_user="$(current_database_username)"
    db_password="$(current_database_password)"
    db_name="$(current_database_name)"

    if [ -z "$db_user" ] || [ -z "$db_password" ] || [ -z "$db_name" ]; then
        echo -e "${RED}Fehler: PostgreSQL-Konfiguration ist unvollstaendig. DATABASE_NAME, DATABASE_USERNAME und DATABASE_PASSWORD muessen gesetzt sein.${NC}"
        return 1
    fi

    echo -e "${GREEN}Bereite lokale PostgreSQL-Datenbank fuer Huginn vor...${NC}"
    sudo apt-get install -y postgresql postgresql-contrib libpq-dev

    if ! start_postgresql_service_for_huginn; then
        echo -e "${RED}Fehler: PostgreSQL-Dienst konnte nicht gestartet werden.${NC}"
        return 1
    fi

    db_user_ident="$(printf "%s" "$db_user" | sed 's/"/""/g')"
    db_user_literal="$(printf "%s" "$db_user" | sed "s/'/''/g")"
    db_password_literal="$(printf "%s" "$db_password" | sed "s/'/''/g")"

    if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname = '$db_user_literal'" | grep -qx '1'; then
        sudo -u postgres psql -v ON_ERROR_STOP=1 -c "ALTER ROLE \"$db_user_ident\" LOGIN CREATEDB PASSWORD '$db_password_literal';"
    else
        sudo -u postgres psql -v ON_ERROR_STOP=1 -c "CREATE ROLE \"$db_user_ident\" LOGIN CREATEDB PASSWORD '$db_password_literal';"
    fi

    echo -e "${GREEN}PostgreSQL-Rolle fuer Huginn ist vorbereitet. Datenbankname: ${db_name}.${NC}"
}

prepare_huginn_frontend_dependencies() {
    if [ ! -f package.json ]; then
        return 0
    fi

    if command -v npm >/dev/null 2>&1 && npm run 2>/dev/null | grep -q ' build'; then
        if command -v npx >/dev/null 2>&1 && npx --no-install esbuild --version >/dev/null 2>&1; then
            return 0
        fi

        echo -e "${GREEN}Bereite Huginn-Frontend-Abhaengigkeiten fuer assets:precompile vor...${NC}"
        if [ -f package-lock.json ]; then
            npm ci || npm install --include=dev
        else
            npm install --include=dev
        fi
        return 0
    fi

    return 0
}

print_huginn_compat_debug_state() {
    echo -e "${YELLOW}Huginn Debug: Script=$0${NC}"
    echo -e "${YELLOW}Huginn Debug: INSTALL_DIR=$INSTALL_DIR${NC}"
    echo -e "${YELLOW}Huginn Debug: HUGINN_DIR=$HUGINN_DIR${NC}"
    echo -e "${YELLOW}Huginn Debug: Ruby=$(ruby -e 'print RUBY_VERSION')${NC}"
    echo -e "${YELLOW}Huginn Debug: DB_ADAPTER=$(current_database_adapter || true)${NC}"
    echo -e "${YELLOW}Huginn Debug: GOOGLE_ACTIVE=$(huginn_google_translate_agent_active; echo $?) GOOGLE_LOCK=$(lockfile_contains_pattern '^[[:space:]]*grpc \(1\.42\.0\)$|^[[:space:]]*google-gax \(1\.8\.2\)$|^[[:space:]]*googleapis-common-protos \(1\.3\.12\)$'; echo $?)${NC}"
    echo -e "${YELLOW}Huginn Debug: JS_ACTIVE=$(huginn_javascript_agent_active; echo $?) JS_LOCK=$(lockfile_contains_pattern '^[[:space:]]*mini_racer \(0\.6\.2\)$|^[[:space:]]*libv8-node \(16\.10\.0\.0\)$'; echo $?)${NC}"
    echo -e "${YELLOW}Huginn Debug: GROWL_ACTIVE=$(huginn_growl_agent_active; echo $?) GROWL_LOCK=$(lockfile_contains_pattern '^[[:space:]]*ruby-growl \(4\.1\)$'; echo $?)${NC}"
    echo -e "${YELLOW}Huginn Debug: FTPSITE_ACTIVE=$(huginn_ftpsite_agent_active; echo $?) FTPSITE_LOCK=$(lockfile_contains_pattern '^[[:space:]]*net-ftp-list \(3\.2\.8\)$'; echo $?)${NC}"
    echo -e "${YELLOW}Huginn Debug: GMAIL_ACTIVE=$(huginn_gmail_xoauth_active; echo $?) GMAIL_LOCK=$(lockfile_contains_pattern '^[[:space:]]*gmail_xoauth \(0\.4\.2\)$'; echo $?)${NC}"
    echo -e "${YELLOW}Huginn Debug: MYSQL_LINE=$(grep -Eq \"gem 'mysql2'[[:space:]]*,[[:space:]]*\\\"~> 0\\.5\\.2\\\"\" Gemfile 2>/dev/null; echo $?) MYSQL_LOCK=$(lockfile_contains_pattern '^[[:space:]]*mysql2 \(0\.5\.3\)$'; echo $?)${NC}"
    echo -e "${YELLOW}Huginn Debug: PG_LINE=$(grep -Eq \"gem 'pg'[[:space:]]*,[[:space:]]*'~> 1\\.1\\.3'\" Gemfile 2>/dev/null; echo $?) PG_LOCK=$(lockfile_contains_pattern '^[[:space:]]*pg \(1\.1\.3\)$'; echo $?)${NC}"
}

database_config_complete() {
    local adapter

    adapter="$(current_database_adapter)"
    case "$adapter" in
        mysql2|postgresql)
            grep -Eq '^DATABASE_NAME=.+$' .env &&
            grep -Eq '^DATABASE_USERNAME=.+$' .env &&
            grep -Eq '^DATABASE_PASSWORD=.+$' .env
            ;;
        sqlite3)
            grep -Eq '^DATABASE_NAME=.+$' .env
            ;;
        *)
            return 1
            ;;
    esac
}

checkout_huginn_ref() {
    if [ -d "$HUGINN_DIR/.git" ]; then
        echo -e "${YELLOW}Huginn Verzeichnis $HUGINN_DIR existiert bereits. Aktualisiere Repository und wechsle auf ${HUGINN_REPO_REF}...${NC}"
        cd "$HUGINN_DIR"
        git fetch --tags origin
        git checkout "$HUGINN_REPO_REF"
        if git show-ref --verify --quiet "refs/heads/$HUGINN_REPO_REF"; then
            git pull --ff-only origin "$HUGINN_REPO_REF"
        fi
    else
        echo -e "${BLUE}Klone Huginn (${HUGINN_REPO_REF}) in $HUGINN_DIR...${NC}"
        if mkdir -p "$HUGINN_DIR" 2>/dev/null; then
            :
        else
            sudo mkdir -p "$HUGINN_DIR"
            sudo chown -R "$USER:$USER" "$HUGINN_DIR"
        fi
        git clone --branch "$HUGINN_REPO_REF" "$HUGINN_REPO_URL" "$HUGINN_DIR"
        cd "$HUGINN_DIR"
    fi
}

disable_huginn_javascript_agent() {
    if ! grep -Eq "^gem 'mini_racer'.*# JavaScriptAgent" Gemfile 2>/dev/null; then
        return 1
    fi

    cp Gemfile Gemfile.bak.before_no_mini_racer 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
old = "gem 'mini_racer'                  # JavaScriptAgent"
new = "# gem 'mini_racer'                # JavaScriptAgent (deaktiviert durch Setup-Fallback wegen libv8-node Build-Fehler)"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

disable_huginn_google_translate_agent() {
    if ! grep -Eq "^gem 'google-cloud-translate'.*google/cloud/translate" Gemfile 2>/dev/null; then
        return 1
    fi

    cp Gemfile Gemfile.bak.before_no_google_translate 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
old = "gem 'google-cloud-translate', '~> 2.0', require: 'google/cloud/translate'"
new = "# gem 'google-cloud-translate', '~> 2.0', require: 'google/cloud/translate' # deaktiviert durch Setup-Fallback wegen grpc/google-protobuf Altstack"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

disable_huginn_growl_agent() {
    if ! grep -Eq "^gem 'ruby-growl'.*# GrowlAgent" Gemfile 2>/dev/null; then
        return 1
    fi

    cp Gemfile Gemfile.bak.before_no_ruby_growl 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
old = "gem 'ruby-growl', '~> 4.1.0'      # GrowlAgent"
new = "# gem 'ruby-growl', '~> 4.1.0'    # GrowlAgent (deaktiviert durch Setup-Fallback wegen Ruby-3.x URI-Inkompatibilitaet)"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

disable_huginn_gmail_xoauth_support() {
    if ! grep -Eq "^gem 'gmail_xoauth'.*Gmail using OAuth" Gemfile 2>/dev/null; then
        return 1
    fi

    cp Gemfile Gemfile.bak.before_no_gmail_xoauth 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
old = "gem 'gmail_xoauth' # support for Gmail using OAuth"
new = "# gem 'gmail_xoauth' # support for Gmail using OAuth (deaktiviert durch Setup-Fallback wegen Ruby-3.x net/imap-Inkompatibilitaet)"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

ensure_huginn_gmail_xoauth_compat_gems() {
    if grep -Eq "^gem 'net-imap'" Gemfile 2>/dev/null && grep -Eq "^gem 'net-smtp'" Gemfile 2>/dev/null && grep -Eq "^gem 'net-pop'" Gemfile 2>/dev/null; then
        return 0
    fi

    cp Gemfile Gemfile.bak.before_gmail_xoauth_compat 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
needle = "gem 'gmail_xoauth' # support for Gmail using OAuth"
insert = "gem 'gmail_xoauth' # support for Gmail using OAuth\ngem 'net-imap', '~> 0.4', require: false # Ruby-3.x Kompatibilitaet fuer gmail_xoauth\ngem 'net-smtp', require: false # Ruby-3.x Kompatibilitaet fuer gmail_xoauth\ngem 'net-pop', require: false # Ruby-3.x Kompatibilitaet fuer mail/pop3"
if needle in text:
    additions = []
    if "gem 'net-imap'" not in text:
        additions.append("gem 'net-imap', '~> 0.4', require: false # Ruby-3.x Kompatibilitaet fuer gmail_xoauth")
    if "gem 'net-smtp'" not in text:
        additions.append("gem 'net-smtp', require: false # Ruby-3.x Kompatibilitaet fuer gmail_xoauth")
    if "gem 'net-pop'" not in text:
        additions.append("gem 'net-pop', require: false # Ruby-3.x Kompatibilitaet fuer mail/pop3")
    if additions:
        text = text.replace(needle, needle + "\n" + "\n".join(additions), 1)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

ensure_huginn_mysql2_ruby32_compat() {
    if grep -Eq "gem 'mysql2'[[:space:]]*,[[:space:]]*\"~> 0\.5\.(5|6|7)\"" Gemfile 2>/dev/null; then
        return 0
    fi

    cp Gemfile Gemfile.bak.before_mysql2_ruby32_compat 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
old = "  gem 'mysql2' , \"~> 0.5.2\""
new = "  gem 'mysql2' , \"~> 0.5.7\" # Ruby-3.2-Kompatibilitaet fuer mysql2"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

ensure_huginn_pg_ruby32_compat() {
    if grep -Eq "gem 'pg'[[:space:]]*,[[:space:]]*'~> 1\.(5|6|7)'" Gemfile 2>/dev/null; then
        return 0
    fi

    cp Gemfile Gemfile.bak.before_pg_ruby32_compat 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
import re

path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
new = "  gem 'pg', '~> 1.5' # Ruby-3.2-Kompatibilitaet fuer PostgreSQL"
text = re.sub(r"^[ \t]*gem 'pg'[ \t]*,[ \t]*['\"][^'\"]+['\"].*$", new, text, count=1, flags=re.MULTILINE)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

disable_huginn_ftpsite_agent() {
    if ! grep -Eq "^gem 'net-ftp-list'.*# FtpsiteAgent" Gemfile 2>/dev/null; then
        return 1
    fi

    cp Gemfile Gemfile.bak.before_no_net_ftp_list 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path
path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
old = "gem 'net-ftp-list', '~> 3.2.8'    # FtpsiteAgent"
new = "# gem 'net-ftp-list', '~> 3.2.8'  # FtpsiteAgent (deaktiviert durch Setup-Fallback wegen Ruby-3.x net/ftp-Inkompatibilitaet)"
if old in text:
    text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
PY
    return 0
}

prune_huginn_ftpsite_lock_entries() {
    if [ ! -f Gemfile.lock ]; then
        return 0
    fi

    cp Gemfile.lock Gemfile.lock.bak.before_ftpsite_prune 2>/dev/null || true

    python3 - <<'PY'
from pathlib import Path

path = Path("Gemfile.lock")
lines = path.read_text(encoding="utf-8").splitlines()

remove_specs = {
    "net-ftp-list",
}
remove_dependencies = {
    "net-ftp-list",
}

out = []
i = 0
section = None

while i < len(lines):
    line = lines[i]
    stripped = line.strip()

    if stripped == "GEM":
        section = "GEM"
        out.append(line)
        i += 1
        continue
    if stripped == "DEPENDENCIES":
        section = "DEPENDENCIES"
        out.append(line)
        i += 1
        continue
    if stripped and not line.startswith(" "):
        section = None
        out.append(line)
        i += 1
        continue

    if section == "GEM" and line.startswith("    "):
        gem_name = line.strip().split(" ", 1)[0]
        if gem_name in remove_specs:
            i += 1
            while i < len(lines) and lines[i].startswith("      "):
                i += 1
            continue

    if section == "DEPENDENCIES" and line.startswith("  "):
        dep_name = line.strip().split(" ", 1)[0].rstrip("!")
        if dep_name in remove_dependencies:
            i += 1
            continue

    out.append(line)
    i += 1

path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
}

prune_huginn_gmail_xoauth_lock_entries() {
    if [ ! -f Gemfile.lock ]; then
        return 0
    fi

    cp Gemfile.lock Gemfile.lock.bak.before_gmail_xoauth_prune 2>/dev/null || true

    python3 - <<'PY'
from pathlib import Path

path = Path("Gemfile.lock")
lines = path.read_text(encoding="utf-8").splitlines()

remove_specs = {
    "gmail_xoauth",
}
remove_dependencies = {
    "gmail_xoauth",
}

out = []
i = 0
section = None

while i < len(lines):
    line = lines[i]
    stripped = line.strip()

    if stripped == "GEM":
        section = "GEM"
        out.append(line)
        i += 1
        continue
    if stripped == "DEPENDENCIES":
        section = "DEPENDENCIES"
        out.append(line)
        i += 1
        continue
    if stripped and not line.startswith(" "):
        section = None
        out.append(line)
        i += 1
        continue

    if section == "GEM" and line.startswith("    "):
        gem_name = line.strip().split(" ", 1)[0]
        if gem_name in remove_specs:
            i += 1
            while i < len(lines) and lines[i].startswith("      "):
                i += 1
            continue

    if section == "DEPENDENCIES" and line.startswith("  "):
        dep_name = line.strip().split(" ", 1)[0].rstrip("!")
        if dep_name in remove_dependencies:
            i += 1
            continue

    out.append(line)
    i += 1

path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
}

prune_huginn_growl_lock_entries() {
    if [ ! -f Gemfile.lock ]; then
        return 0
    fi

    cp Gemfile.lock Gemfile.lock.bak.before_growl_prune 2>/dev/null || true

    python3 - <<'PY'
from pathlib import Path

path = Path("Gemfile.lock")
lines = path.read_text(encoding="utf-8").splitlines()

remove_specs = {
    "ruby-growl",
}
remove_dependencies = {
    "ruby-growl",
}

out = []
i = 0
section = None

while i < len(lines):
    line = lines[i]
    stripped = line.strip()

    if stripped == "GEM":
        section = "GEM"
        out.append(line)
        i += 1
        continue
    if stripped == "DEPENDENCIES":
        section = "DEPENDENCIES"
        out.append(line)
        i += 1
        continue
    if stripped and not line.startswith(" "):
        section = None
        out.append(line)
        i += 1
        continue

    if section == "GEM" and line.startswith("    "):
        gem_name = line.strip().split(" ", 1)[0]
        if gem_name in remove_specs:
            i += 1
            while i < len(lines) and lines[i].startswith("      "):
                i += 1
            continue

    if section == "DEPENDENCIES" and line.startswith("  "):
        dep_name = line.strip().split(" ", 1)[0].rstrip("!")
        if dep_name in remove_dependencies:
            i += 1
            continue

    out.append(line)
    i += 1

path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
}

prune_huginn_javascript_lock_entries() {
    if [ ! -f Gemfile.lock ]; then
        return 0
    fi

    cp Gemfile.lock Gemfile.lock.bak.before_javascript_prune 2>/dev/null || true

    python3 - <<'PY'
from pathlib import Path

path = Path("Gemfile.lock")
lines = path.read_text(encoding="utf-8").splitlines()

remove_specs = {
    "libv8-node",
    "mini_racer",
}
remove_dependencies = {
    "mini_racer",
}

out = []
i = 0
section = None

while i < len(lines):
    line = lines[i]
    stripped = line.strip()

    if stripped == "GEM":
        section = "GEM"
        out.append(line)
        i += 1
        continue
    if stripped == "DEPENDENCIES":
        section = "DEPENDENCIES"
        out.append(line)
        i += 1
        continue
    if stripped and not line.startswith(" "):
        section = None
        out.append(line)
        i += 1
        continue

    if section == "GEM" and line.startswith("    "):
        gem_name = line.strip().split(" ", 1)[0]
        if gem_name in remove_specs:
            i += 1
            while i < len(lines) and lines[i].startswith("      "):
                i += 1
            continue

    if section == "DEPENDENCIES" and line.startswith("  "):
        dep_name = line.strip().split(" ", 1)[0].rstrip("!")
        if dep_name in remove_dependencies:
            i += 1
            continue

    out.append(line)
    i += 1

path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
}

prune_huginn_google_translate_lock_entries() {
    if [ ! -f Gemfile.lock ]; then
        return 0
    fi

    cp Gemfile.lock Gemfile.lock.bak.before_google_translate_prune 2>/dev/null || true

    python3 - <<'PY'
from pathlib import Path

path = Path("Gemfile.lock")
lines = path.read_text(encoding="utf-8").splitlines()

remove_specs = {
    "google-cloud-translate",
    "google-cloud-core",
    "google-cloud-env",
    "google-cloud-errors",
    "google-gax",
    "google-protobuf",
    "googleapis-common-protos",
    "googleapis-common-protos-types",
    "grpc",
}
remove_dependencies = {
    "google-cloud-translate",
}

out = []
i = 0
section = None

while i < len(lines):
    line = lines[i]
    stripped = line.strip()

    if stripped == "GEM":
        section = "GEM"
        out.append(line)
        i += 1
        continue
    if stripped == "DEPENDENCIES":
        section = "DEPENDENCIES"
        out.append(line)
        i += 1
        continue
    if stripped and not line.startswith(" "):
        section = None
        out.append(line)
        i += 1
        continue

    if section == "GEM" and line.startswith("    "):
        gem_name = line.strip().split(" ", 1)[0]
        if gem_name in remove_specs:
            i += 1
            while i < len(lines) and lines[i].startswith("      "):
                i += 1
            continue

    if section == "DEPENDENCIES" and line.startswith("  "):
        dep_name = line.strip().split(" ", 1)[0].rstrip("!")
        if dep_name in remove_dependencies:
            i += 1
            continue

    out.append(line)
    i += 1

path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
}

run_bundle_install_logged() {
    local bundle_log_file="$1"
    bundle install 2>&1 | tee -a "$bundle_log_file"
}

run_bundle_lock_logged() {
    local bundle_log_file="$1"
    shift || true

    if [ "$#" -gt 0 ]; then
        bundle lock --update "$@" 2>&1 | tee -a "$bundle_log_file"
    else
        bundle lock 2>&1 | tee -a "$bundle_log_file"
    fi
}

normalize_huginn_lockfile_platforms() {
    local bundle_log_file="$1"

    if [ ! -f Gemfile.lock ]; then
        return 0
    fi

    echo -e "${YELLOW}Bereinige veraltete Linux-Plattform-Locks aus Gemfile.lock, damit Bundler wieder auflösbar bleibt...${NC}"
    cp Gemfile.lock Gemfile.lock.bak.before_platform_cleanup 2>/dev/null || true

    bundle lock --remove-platform x86_64-linux 2>&1 | tee -a "$bundle_log_file" || true
    bundle lock --remove-platform x86_64-darwin 2>&1 | tee -a "$bundle_log_file" || true
    bundle lock --add-platform ruby 2>&1 | tee -a "$bundle_log_file" || true
}

rebuild_huginn_lockfile_from_current_gemfile() {
    local bundle_log_file="$1"

    if [ -f Gemfile.lock ]; then
        cp Gemfile.lock Gemfile.lock.bak.before_rebuild 2>/dev/null || true
        rm -f Gemfile.lock
    fi

    echo -e "${YELLOW}Erzeuge Gemfile.lock aus dem aktuell bereinigten Gemfile neu, damit keine Alt-Locks erhalten bleiben...${NC}"
    run_bundle_lock_logged "$bundle_log_file"
}

persist_huginn_lockfile() {
    local bundle_log_file="$1"
    shift || true

    run_bundle_lock_logged "$bundle_log_file" "$@" || true

    if [ ! -f Gemfile.lock ]; then
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi
}

bundle_log_contains_net_imap_resolution_failure() {
    local bundle_log_file="$1"
    grep -Eq "Could not find gem 'net-imap'|Could not find gem 'net-smtp'|Could not find gem 'net-pop'" "$bundle_log_file" 2>/dev/null
}

lockfile_contains_pattern() {
    local pattern="$1"
    if [ ! -f Gemfile.lock ]; then
        return 1
    fi

    grep -Eq "$pattern" Gemfile.lock
}

ruby_version_at_least() {
    local required="$1"

    ruby -e 'exit((Gem::Version.new(RUBY_VERSION) >= Gem::Version.new(ARGV[0])) ? 0 : 1)' "$required"
}

is_huginn_master_ref() {
    case "$HUGINN_REPO_REF" in
        master|main)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

activate_rbenv_shell() {
    export RBENV_ROOT="$HUGINN_RBENV_ROOT"
    export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
    if [ -x "$RBENV_ROOT/bin/rbenv" ]; then
        eval "$("$RBENV_ROOT/bin/rbenv" init - bash)"
    fi
}

ensure_huginn_master_ruby() {
    if ! is_huginn_master_ref; then
        return 0
    fi

    echo -e "${YELLOW}Huginn master erkannt: aktueller Upstream verlangt Ruby >= 3.4.0.${NC}"
    echo -e "${YELLOW}Dieses Setup nutzt dafuer einen separaten rbenv-Pfad nur fuer Huginn master: ${HUGINN_RBENV_ROOT}.${NC}"

    if ruby_version_at_least "3.4"; then
        HUGINN_ACTIVE_RUBY_VERSION="$(ruby -e 'print RUBY_VERSION')"
        echo -e "${GREEN}System-Ruby ist bereits ausreichend: Ruby ${HUGINN_ACTIVE_RUBY_VERSION}.${NC}"
        return 0
    fi

    if [ "$HUGINN_ENABLE_RBENV_FOR_MASTER" != "true" ]; then
        echo -e "${RED}Fehler: Huginn master benoetigt Ruby >= 3.4.0, aber HUGINN_ENABLE_RBENV_FOR_MASTER=false.${NC}"
        echo -e "${YELLOW}Nutze v2022.08.18 oder aktiviere den separaten rbenv-Pfad fuer Huginn master.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Installiere bzw. aktualisiere rbenv/ruby-build fuer Huginn master...${NC}"
    if [ ! -d "$HUGINN_RBENV_ROOT/.git" ]; then
        rm -rf "$HUGINN_RBENV_ROOT"
        git clone https://github.com/rbenv/rbenv.git "$HUGINN_RBENV_ROOT"
    else
        git -C "$HUGINN_RBENV_ROOT" pull --ff-only || true
    fi

    mkdir -p "$HUGINN_RBENV_ROOT/plugins"
    if [ ! -d "$HUGINN_RBENV_ROOT/plugins/ruby-build/.git" ]; then
        git clone https://github.com/rbenv/ruby-build.git "$HUGINN_RBENV_ROOT/plugins/ruby-build"
    else
        git -C "$HUGINN_RBENV_ROOT/plugins/ruby-build" pull --ff-only || true
    fi

    activate_rbenv_shell
    echo -e "${GREEN}Installiere Ruby ${HUGINN_MASTER_RUBY_VERSION} fuer Huginn master, falls noch nicht vorhanden...${NC}"
    rbenv install -s "$HUGINN_MASTER_RUBY_VERSION"
    rbenv shell "$HUGINN_MASTER_RUBY_VERSION"
    HUGINN_ACTIVE_RUBY_VERSION="$HUGINN_MASTER_RUBY_VERSION"
    gem install bundler
    ruby -v
    bundle -v
}

huginn_google_translate_agent_active() {
    grep -Eq "^gem 'google-cloud-translate'.*google/cloud/translate" Gemfile 2>/dev/null
}

huginn_javascript_agent_active() {
    grep -Eq "^gem 'mini_racer'.*# JavaScriptAgent" Gemfile 2>/dev/null
}

huginn_growl_agent_active() {
    grep -Eq "^gem 'ruby-growl'.*# GrowlAgent" Gemfile 2>/dev/null
}

huginn_ftpsite_agent_active() {
    grep -Eq "^gem 'net-ftp-list'.*# FtpsiteAgent" Gemfile 2>/dev/null
}

huginn_gmail_xoauth_active() {
    grep -Eq "^gem 'gmail_xoauth'.*Gmail using OAuth" Gemfile 2>/dev/null
}

legacy_huginn_ftpsite_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    huginn_ftpsite_agent_active &&
    lockfile_contains_pattern '^[[:space:]]*net-ftp-list \(3\.2\.8\)$'
}

legacy_huginn_net_imap_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    huginn_gmail_xoauth_active &&
    ! grep -Eq "^gem 'net-imap'" Gemfile 2>/dev/null &&
    lockfile_contains_pattern '^[[:space:]]*gmail_xoauth \(0\.4\.2\)$'
}

legacy_huginn_mysql2_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    [ "$(current_database_adapter)" = "mysql2" ] &&
    lockfile_contains_pattern '^[[:space:]]*mysql2 \(0\.5\.3\)$'
}

legacy_huginn_pg_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    [ "$(current_database_adapter)" = "postgresql" ] &&
    lockfile_contains_pattern '^[[:space:]]*pg \(1\.1\.3\)$'
}

legacy_huginn_growl_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    huginn_growl_agent_active &&
    lockfile_contains_pattern '^[[:space:]]*ruby-growl \(4\.1\)$'
}

legacy_huginn_javascript_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    huginn_javascript_agent_active &&
    lockfile_contains_pattern '^[[:space:]]*mini_racer \(0\.6\.2\)$|^[[:space:]]*libv8-node \(16\.10\.0\.0\)$'
}

legacy_huginn_google_grpc_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    huginn_google_translate_agent_active &&
    lockfile_contains_pattern '^[[:space:]]*grpc \(1\.42\.0\)$|^[[:space:]]*google-gax \(1\.8\.2\)$|^[[:space:]]*googleapis-common-protos \(1\.3\.12\)$'
}

ensure_huginn_lockfile_without_nokogiri_legacy_linux() {
    local bundle_log_file="$1"

    if lockfile_contains_pattern '^[[:space:]]*nokogiri \(1\.13\.8(-x86_64-linux)?\)$|^[[:space:]]*nokogiri \(1\.13\.8-x86_64-linux\)$'; then
        echo -e "${YELLOW}Gemfile.lock enthaelt weiterhin den veralteten nokogiri-Stand. Aktualisiere nur nokogiri/racc/mini_portile2 gezielt...${NC}"
        echo -e "${YELLOW}Hinweis: Ein kompletter Lockfile-Neuaufbau wird vermieden, weil der alte Huginn-twitter-Stack sonst in einen Solverkonflikt laufen kann.${NC}"
        persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
    fi
}

ensure_huginn_lockfile_without_disabled_gems() {
    local bundle_log_file="$1"

    if grep -Eq '^# gem '\''ruby-growl'\''' Gemfile 2>/dev/null && lockfile_contains_pattern '^[[:space:]]*ruby-growl \('; then
        echo -e "${YELLOW}Gemfile.lock enthält ruby-growl noch trotz deaktiviertem GrowlAgent. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi

    if grep -Eq '^# gem '\''mini_racer'\''' Gemfile 2>/dev/null && lockfile_contains_pattern '^[[:space:]]*mini_racer \('; then
        echo -e "${YELLOW}Gemfile.lock enthält mini_racer noch trotz deaktiviertem JavaScriptAgent. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi

    if grep -Eq '^# gem '\''google-cloud-translate'\''' Gemfile 2>/dev/null && lockfile_contains_pattern '^[[:space:]]*google-cloud-translate \('; then
        echo -e "${YELLOW}Gemfile.lock enthält google-cloud-translate noch trotz deaktiviertem GoogleTranslateAgent. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi

    if grep -Eq '^# gem '\''net-ftp-list'\''' Gemfile 2>/dev/null && lockfile_contains_pattern '^[[:space:]]*net-ftp-list \('; then
        echo -e "${YELLOW}Gemfile.lock enthält net-ftp-list noch trotz deaktiviertem FtpsiteAgent. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi

    if grep -Eq '^# gem '\''gmail_xoauth'\''' Gemfile 2>/dev/null && lockfile_contains_pattern '^[[:space:]]*gmail_xoauth \('; then
        echo -e "${YELLOW}Gemfile.lock enthält gmail_xoauth noch trotz deaktivierter Gmail-OAuth-Unterstützung. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi
}

prepare_huginn_growl_stack_if_needed() {
    local bundle_log_file="$1"

    if [ "${HUGINN_DISABLE_GROWL_AGENT_ON_RUBY32_FAILURE}" != "true" ]; then
        return 1
    fi

    if ruby_version_at_least "3.1" && legacy_huginn_growl_stack_present; then
        echo -e "${YELLOW}Hinweis: Ruby $(ruby -e 'print RUBY_VERSION') trifft auf den alten Huginn-GrowlAgent/ruby-growl-Stack.${NC}"
        echo -e "${YELLOW}Aktiviere den GrowlAgent-Fallback vorsorglich, bevor Huginn spaeter im Rails-Start an ruby-growl scheitert...${NC}"
        if disable_huginn_growl_agent; then
            prune_huginn_growl_lock_entries
            persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
            ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
            ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
            echo -e "${YELLOW}Huginn wurde ohne GrowlAgent vorbereitet. Die Datei $HUGINN_DIR/Gemfile.bak.before_no_ruby_growl enthält die Originalzeile.${NC}"
            return 0
        fi
    fi

    return 1
}

prepare_huginn_ftpsite_stack_if_needed() {
    local bundle_log_file="$1"

    if [ "${HUGINN_DISABLE_FTPSITE_AGENT_ON_RUBY32_FAILURE}" != "true" ]; then
        return 1
    fi

    if ruby_version_at_least "3.1" && legacy_huginn_ftpsite_stack_present; then
        echo -e "${YELLOW}Hinweis: Ruby $(ruby -e 'print RUBY_VERSION') trifft auf den alten Huginn-FtpsiteAgent/net-ftp-list-Stack.${NC}"
        echo -e "${YELLOW}Aktiviere den FtpsiteAgent-Fallback vorsorglich, bevor Rails spaeter an net/ftp scheitert...${NC}"
        if disable_huginn_ftpsite_agent; then
            prune_huginn_ftpsite_lock_entries
            persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
            ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
            ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
            echo -e "${YELLOW}Huginn wurde ohne FtpsiteAgent vorbereitet. Die Datei $HUGINN_DIR/Gemfile.bak.before_no_net_ftp_list enthält die Originalzeile.${NC}"
            return 0
        fi
    fi

    return 1
}

prepare_huginn_net_imap_stack_if_needed() {
    local bundle_log_file="$1"

    if [ "${HUGINN_ENABLE_NET_IMAP_COMPAT_ON_RUBY32}" != "true" ]; then
        return 1
    fi

    if ruby_version_at_least "3.1" && legacy_huginn_net_imap_stack_present; then
        echo -e "${YELLOW}Hinweis: Ruby $(ruby -e 'print RUBY_VERSION') trifft auf den alten Huginn-Gmail/gmail_xoauth-Stack.${NC}"
        echo -e "${YELLOW}Ergänze die ausgelagerten Ruby-Stdlib-Gems net-imap, net-smtp und net-pop vorsorglich, bevor Rails spaeter an gmail_xoauth oder mail/pop3 scheitert...${NC}"
        ensure_huginn_gmail_xoauth_compat_gems
        persist_huginn_lockfile "$bundle_log_file" net-imap net-smtp net-pop nokogiri racc mini_portile2
        ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
        if bundle_log_contains_net_imap_resolution_failure "$bundle_log_file" && [ "${HUGINN_DISABLE_GMAIL_XOAUTH_ON_NET_IMAP_FAILURE}" = "true" ] && disable_huginn_gmail_xoauth_support; then
            echo -e "${YELLOW}Hinweis: net-imap/net-smtp/net-pop konnte in diesem Huginn-Stand nicht sauber aufgeloest werden.${NC}"
            echo -e "${YELLOW}Wechsle deshalb direkt auf den Gmail-OAuth-Fallback ohne gmail_xoauth, statt einen halben Compat-Stand zu behalten...${NC}"
            prune_huginn_gmail_xoauth_lock_entries
            persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
            ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
            ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
            echo -e "${YELLOW}Huginn wurde fuer diesen Lauf ohne Gmail-OAuth-Unterstuetzung vorbereitet.${NC}"
            return 0
        fi
        echo -e "${YELLOW}Huginn wurde fuer diesen Lauf mit net-imap/net-smtp/net-pop-Kompatibilitaet fuer gmail_xoauth vorbereitet.${NC}"
        return 0
    fi

    return 1
}

prepare_huginn_mysql2_stack_if_needed() {
    local bundle_log_file="$1"

    if [ "${HUGINN_ENABLE_MYSQL2_RUBY32_COMPAT}" != "true" ]; then
        return 1
    fi

    if ruby_version_at_least "3.2" && legacy_huginn_mysql2_stack_present; then
        echo -e "${YELLOW}Hinweis: Ruby $(ruby -e 'print RUBY_VERSION') trifft auf den alten Huginn-mysql2-Stack.${NC}"
        echo -e "${YELLOW}Aktualisiere den mysql2-Pfad vorsorglich auf einen Ruby-3.2-kompatiblen Stand, bevor Rails spaeter an mysql2.so scheitert...${NC}"
        ensure_huginn_mysql2_ruby32_compat
        persist_huginn_lockfile "$bundle_log_file" mysql2 nokogiri racc mini_portile2
        ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
        echo -e "${YELLOW}Huginn wurde fuer diesen Lauf mit mysql2-Ruby-3.2-Kompatibilitaet vorbereitet.${NC}"
        return 0
    fi

    return 1
}

prepare_huginn_pg_stack_if_needed() {
    local bundle_log_file="$1"

    if [ "${HUGINN_ENABLE_PG_RUBY32_COMPAT}" != "true" ]; then
        return 1
    fi

    if ruby_version_at_least "3.2" && legacy_huginn_pg_stack_present; then
        echo -e "${YELLOW}Hinweis: Ruby $(ruby -e 'print RUBY_VERSION') trifft auf den alten Huginn-pg-Stack.${NC}"
        echo -e "${YELLOW}Aktualisiere den pg-Pfad vorsorglich auf einen Ruby-3.2-kompatiblen Stand, bevor Rails spaeter an pg_ext.so scheitert...${NC}"
        ensure_huginn_pg_ruby32_compat
        persist_huginn_lockfile "$bundle_log_file" pg
        ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
        echo -e "${YELLOW}Huginn wurde fuer diesen Lauf mit pg-Ruby-3.2-Kompatibilitaet vorbereitet.${NC}"
        return 0
    fi

    return 1
}

prepare_huginn_google_stack_if_needed() {
    local bundle_log_file="$1"

    if [ "${HUGINN_DISABLE_GOOGLE_TRANSLATE_ON_GRPC_FAILURE}" != "true" ]; then
        return 1
    fi

    if ruby_version_at_least "3.1" && legacy_huginn_google_grpc_stack_present; then
        echo -e "${YELLOW}Hinweis: Ruby $(ruby -e 'print RUBY_VERSION') trifft auf den alten Huginn-Google/gRPC-Stack.${NC}"
        echo -e "${YELLOW}Aktiviere den GoogleTranslate-Fallback vorsorglich, bevor Bundler erneut in grpc 1.42.0 läuft...${NC}"
        repair_huginn_google_stack "$bundle_log_file"
        return 0
    fi

    return 1
}

prepare_huginn_javascript_stack_if_needed() {
    local bundle_log_file="$1"

    if [ "${HUGINN_DISABLE_JAVASCRIPT_AGENT_ON_LIBV8_FAILURE}" != "true" ]; then
        return 1
    fi

    if ruby_version_at_least "3.1" && legacy_huginn_javascript_stack_present; then
        echo -e "${YELLOW}Hinweis: Ruby $(ruby -e 'print RUBY_VERSION') trifft auf den alten Huginn-JavaScriptAgent/libv8-node-Stack.${NC}"
        echo -e "${YELLOW}Aktiviere den JavaScriptAgent-Fallback vorsorglich, bevor Bundler erneut in libv8-node läuft...${NC}"
        if disable_huginn_javascript_agent; then
            normalize_huginn_lockfile_platforms "$bundle_log_file"
            prune_huginn_javascript_lock_entries
            persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
            ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
            ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
            echo -e "${YELLOW}Huginn wurde ohne JavaScriptAgent vorbereitet. Die Datei $HUGINN_DIR/Gemfile.bak.before_no_mini_racer enthält die Originalzeile.${NC}"
            return 0
        fi
    fi

    return 1
}

repair_huginn_nokogiri_stack() {
    local bundle_log_file="$1"
    echo -e "${YELLOW}Hinweis: Das Huginn-Lockfile verweist auf eine nicht mehr verfügbare nokogiri-Binärversion.${NC}"
    echo -e "${YELLOW}Versuche Reparatur über nokogiri-, racc- und mini_portile2-Refresh ohne erzwungene Ruby-Plattform...${NC}"
    normalize_huginn_lockfile_platforms "$bundle_log_file"
    persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
    ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
}

repair_huginn_google_stack() {
    local bundle_log_file="$1"
    echo -e "${YELLOW}Hinweis: Der alte google-protobuf/grpc-Stack ist auf diesem System nicht mehr stabil installierbar.${NC}"
    echo -e "${YELLOW}Versuche Fallback ohne GoogleTranslateAgent, damit Huginn sonst weiter installiert werden kann.${NC}"
    if disable_huginn_google_translate_agent; then
        normalize_huginn_lockfile_platforms "$bundle_log_file"
        prune_huginn_google_translate_lock_entries
        persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
        ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
        echo -e "${YELLOW}Huginn wurde für diesen Lauf ohne GoogleTranslateAgent vorbereitet.${NC}"
        echo -e "${YELLOW}Die Datei $HUGINN_DIR/Gemfile.bak.before_no_google_translate enthält die Originalzeile.${NC}"
        return 0
    fi

    return 1
}

echo -e "${BLUE}Starte Installation von Huginn...${NC}"
echo -e "${YELLOW}Standard-Referenz: ${HUGINN_REPO_REF}.${NC}"
echo -e "${YELLOW}Wenn du bewusst einen anderen Upstream-Stand testen willst, kannst du HUGINN_REPO_REF im Setup auswaehlen oder festlegen.${NC}"
echo -e "${YELLOW}Port-Hinweis: Huginn nutzt upstream oft ${HUGINN_UPSTREAM_DEFAULT_PORT}; dieses Setup verwendet standardmaessig ${HUGINN_WEB_PORT}, damit kein Konflikt mit OpenClaw auf 3000 entsteht.${NC}"
echo -e "${YELLOW}Erkennungs-Hinweis: Der Installationslog enthaelt Standard-Referenz, Git-Ref, Commit und DATABASE_ADAPTER, damit spaeter klar ist, welche Kombination getestet wurde.${NC}"

echo -e "${GREEN}1/5: Installiere System-Abhängigkeiten für Huginn...${NC}"
if [ "$HUGINN_SKIP_SYSTEM_PACKAGES" != "true" ]; then
    sudo apt-get update
    sudo apt-get install -y \
        ruby-full ruby-bundler build-essential git curl pkg-config \
        libmysqlclient-dev libpq-dev \
        autoconf bison libssl-dev libyaml-dev zlib1g-dev libreadline-dev \
        libgmp-dev libncurses-dev libffi-dev libgdbm-dev libdb-dev
else
    echo -e "${YELLOW}Überspringe Systempakete, weil HUGINN_SKIP_SYSTEM_PACKAGES=true gesetzt ist.${NC}"
fi

echo -e "${GREEN}2/5: Hole Huginn aus GitHub...${NC}"
checkout_huginn_ref
echo -e "${YELLOW}Huginn Git-Ref nach Checkout: $(git -C "$HUGINN_DIR" describe --tags --exact-match 2>/dev/null || git -C "$HUGINN_DIR" branch --show-current 2>/dev/null || git -C "$HUGINN_DIR" rev-parse --short HEAD 2>/dev/null || echo unbekannt)${NC}"
echo -e "${YELLOW}Huginn Commit nach Checkout: $(git -C "$HUGINN_DIR" rev-parse --short HEAD 2>/dev/null || echo unbekannt)${NC}"
ensure_huginn_master_ruby
if [ -n "$HUGINN_ACTIVE_RUBY_VERSION" ] && [ -x "$HUGINN_RBENV_ROOT/bin/rbenv" ]; then
    activate_rbenv_shell
    rbenv shell "$HUGINN_ACTIVE_RUBY_VERSION"
    rbenv local "$HUGINN_ACTIVE_RUBY_VERSION" 2>/dev/null || true
fi

mkdir -p log tmp/pids tmp/sockets
chmod -R u+rwX,go-w log tmp

echo -e "${GREEN}3/5: Bereite .env und Verzeichnisse vor...${NC}"
if [ ! -f .env ]; then
    bootstrap_huginn_env_from_secure_template
fi
ensure_secret_token
ensure_huginn_invitation_code
ensure_production_env_defaults
sanitize_huginn_env_database_defaults
apply_huginn_selected_database_adapter
echo -e "${YELLOW}Huginn effektive Kombination: REPO_REF=$(git -C "$HUGINN_DIR" describe --tags --exact-match 2>/dev/null || git -C "$HUGINN_DIR" branch --show-current 2>/dev/null || git -C "$HUGINN_DIR" rev-parse --short HEAD 2>/dev/null || echo unbekannt), DATABASE_ADAPTER=$(current_database_adapter || true), WEB_PORT=${HUGINN_WEB_PORT}.${NC}"
apply_huginn_dry_runnable_kwarg_fix
apply_huginn_jobs_yaml_fix
apply_huginn_web_request_faraday_fix
apply_huginn_mysql_reconnect_deprecation_fix
chmod o-rwx .env 2>/dev/null || true

echo -e "${GREEN}4/5: Installiere Ruby Gems mit Bundler...${NC}"
if ! command -v bundle >/dev/null 2>&1; then
    sudo gem install bundler
fi
bundle config set --local path vendor/bundle
bundle config set --local without "development test"
bundle config unset --local force_ruby_platform >/dev/null 2>&1 || true
bundle lock --add-platform ruby >/dev/null 2>&1 || true
bundle lock --add-platform x86_64-linux >/dev/null 2>&1 || true
echo -e "${YELLOW}Hinweis: 'development test' ist hier keine Versionsnummer, sondern die ausgeschlossene Bundler-Gruppenkombination.${NC}"
bundle_log_file="$(mktemp)"
bundle_repair_nokogiri_done="false"
bundle_disable_ftpsite_done="false"
bundle_enable_net_imap_done="false"
bundle_disable_gmail_xoauth_done="false"
bundle_enable_mysql2_done="false"
bundle_enable_pg_done="false"
bundle_disable_growl_done="false"
bundle_disable_js_done="false"
bundle_disable_translate_done="false"

print_huginn_compat_debug_state

if prepare_huginn_mysql2_stack_if_needed "$bundle_log_file"; then
    bundle_enable_mysql2_done="true"
fi
if prepare_huginn_pg_stack_if_needed "$bundle_log_file"; then
    bundle_enable_pg_done="true"
fi
if prepare_huginn_ftpsite_stack_if_needed "$bundle_log_file"; then
    bundle_disable_ftpsite_done="true"
fi
if prepare_huginn_net_imap_stack_if_needed "$bundle_log_file"; then
    bundle_enable_net_imap_done="true"
fi
if prepare_huginn_growl_stack_if_needed "$bundle_log_file"; then
    bundle_disable_growl_done="true"
fi
if prepare_huginn_javascript_stack_if_needed "$bundle_log_file"; then
    bundle_disable_js_done="true"
fi
if prepare_huginn_google_stack_if_needed "$bundle_log_file"; then
    bundle_disable_translate_done="true"
fi

while true; do
    if run_bundle_install_logged "$bundle_log_file"; then
        break
    fi

    if grep -Eq 'Your bundle is locked to nokogiri|nokogiri .* can no longer be found' "$bundle_log_file" && [ "$bundle_repair_nokogiri_done" != "true" ]; then
        repair_huginn_nokogiri_stack "$bundle_log_file"
        bundle_repair_nokogiri_done="true"
        if [ "$bundle_disable_ftpsite_done" != "true" ] && prepare_huginn_ftpsite_stack_if_needed "$bundle_log_file"; then
            bundle_disable_ftpsite_done="true"
        fi
        if [ "$bundle_enable_mysql2_done" != "true" ] && prepare_huginn_mysql2_stack_if_needed "$bundle_log_file"; then
            bundle_enable_mysql2_done="true"
        fi
        if [ "${bundle_enable_pg_done:-false}" != "true" ] && prepare_huginn_pg_stack_if_needed "$bundle_log_file"; then
            bundle_enable_pg_done="true"
        fi
        if [ "$bundle_enable_net_imap_done" != "true" ] && prepare_huginn_net_imap_stack_if_needed "$bundle_log_file"; then
            bundle_enable_net_imap_done="true"
        fi
        if [ "$bundle_disable_growl_done" != "true" ] && prepare_huginn_growl_stack_if_needed "$bundle_log_file"; then
            bundle_disable_growl_done="true"
        fi
        if [ "$bundle_disable_js_done" != "true" ] && prepare_huginn_javascript_stack_if_needed "$bundle_log_file"; then
            bundle_disable_js_done="true"
        fi
        if [ "$bundle_disable_translate_done" != "true" ] && prepare_huginn_google_stack_if_needed "$bundle_log_file"; then
            bundle_disable_translate_done="true"
        fi
        continue
    fi

    if grep -Eq 'An error occurred while installing libv8-node|mini_racer was resolved to .* depends on[[:space:]]+libv8-node' "$bundle_log_file" && [ "${HUGINN_DISABLE_JAVASCRIPT_AGENT_ON_LIBV8_FAILURE}" = "true" ] && [ "$bundle_disable_js_done" != "true" ]; then
        echo -e "${YELLOW}Hinweis: mini_racer bzw. libv8-node konnte auf diesem System nicht gebaut werden.${NC}"
        echo -e "${YELLOW}Versuche Fallback ohne JavaScriptAgent, damit Huginn sonst weiter installiert werden kann.${NC}"
        if disable_huginn_javascript_agent; then
            normalize_huginn_lockfile_platforms "$bundle_log_file"
            prune_huginn_javascript_lock_entries
            persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
            ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
            ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
            echo -e "${YELLOW}Huginn wurde ohne JavaScriptAgent vorbereitet. Die Datei $HUGINN_DIR/Gemfile.bak.before_no_mini_racer enthält die Originalzeile.${NC}"
            bundle_disable_js_done="true"
            bundle_repair_nokogiri_done="false"
            continue
        fi
    fi

    if bundle_log_contains_net_imap_resolution_failure "$bundle_log_file" && [ "${HUGINN_DISABLE_GMAIL_XOAUTH_ON_NET_IMAP_FAILURE}" = "true" ] && [ "$bundle_disable_gmail_xoauth_done" != "true" ] && disable_huginn_gmail_xoauth_support; then
        echo -e "${YELLOW}Hinweis: net-imap/net-smtp konnte in diesem Huginn-Stand nicht sauber aufgeloest werden.${NC}"
        echo -e "${YELLOW}Deaktiviere deshalb gmail_xoauth direkt und versuche Bundler danach erneut...${NC}"
        prune_huginn_gmail_xoauth_lock_entries
        persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2
        ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
        bundle_disable_gmail_xoauth_done="true"
        continue
    fi

    if grep -Eq 'Your bundle is locked to google-protobuf|google-protobuf .* can no longer be found|An error occurred while installing grpc|google-cloud-translate was resolved to .* depends on|googleapis-common-protos was resolved to .* depends on[[:space:]]+grpc' "$bundle_log_file" && [ "${HUGINN_DISABLE_GOOGLE_TRANSLATE_ON_GRPC_FAILURE}" = "true" ] && [ "$bundle_disable_translate_done" != "true" ]; then
        if repair_huginn_google_stack "$bundle_log_file"; then
            bundle_disable_translate_done="true"
            bundle_repair_nokogiri_done="false"
            continue
        fi
    fi

    rm -f "$bundle_log_file"
    echo -e "${RED}Fehler: Bundler install für Huginn fehlgeschlagen.${NC}"
    exit 1
done
rm -f "$bundle_log_file"

if ! database_config_complete; then
    echo -e "${YELLOW}Huginn Quellcode und Gems wurden vorbereitet, aber die Datenbank-Konfiguration in $HUGINN_DIR/.env ist noch unvollständig.${NC}"
    echo -e "${YELLOW}Bitte trage mindestens DATABASE_ADAPTER, DATABASE_NAME und je nach Adapter auch DATABASE_USERNAME/DATABASE_PASSWORD ein.${NC}"
    echo -e "${YELLOW}Danach kannst du manuell fortsetzen mit:${NC}"
    echo "cd $HUGINN_DIR"
    echo "RAILS_ENV=production bundle exec rake db:create"
    echo "RAILS_ENV=production bundle exec rake db:migrate"
    echo "RAILS_ENV=production bundle exec rake db:seed"
    echo "RAILS_ENV=production bundle exec rails server -p ${HUGINN_WEB_PORT}"
    mark_current_tool_installed
    echo -e "${GREEN}Huginn wurde als vorbereitet markiert.${NC}"
    exit 0
fi

echo -e "${GREEN}5/5: Initialisiere Datenbank...${NC}"
prepare_postgresql_database_for_huginn
if ! mysql_service_available_for_huginn; then
    print_huginn_mysql_service_guidance
    echo -e "${YELLOW}Danach kannst du manuell fortsetzen mit:${NC}"
    echo "cd $HUGINN_DIR"
    echo "RAILS_ENV=production bundle exec rake db:create"
    echo "RAILS_ENV=production bundle exec rake db:migrate"
    echo "RAILS_ENV=production bundle exec rake db:seed"
    exit 1
fi
db_init_log_file="$(mktemp)"
if ! RAILS_ENV=production bundle exec rake db:create 2>&1 | tee "$db_init_log_file"; then
    if grep -Eq 'cannot load such file -- net/ftp|cannot load such file -- net-ftp-list' "$db_init_log_file" && [ "${HUGINN_DISABLE_FTPSITE_AGENT_ON_RUBY32_FAILURE}" = "true" ] && [ "$bundle_disable_ftpsite_done" != "true" ]; then
        echo -e "${YELLOW}Hinweis: Huginn scheitert beim Rails-Start am alten FtpsiteAgent/net-ftp-list-Stack.${NC}"
        echo -e "${YELLOW}Versuche Fallback ohne FtpsiteAgent und initialisiere die Datenbank danach erneut...${NC}"
        if disable_huginn_ftpsite_agent; then
            prune_huginn_ftpsite_lock_entries
            persist_huginn_lockfile "$db_init_log_file" nokogiri racc mini_portile2
            ensure_huginn_lockfile_without_disabled_gems "$db_init_log_file"
            ensure_huginn_lockfile_without_nokogiri_legacy_linux "$db_init_log_file"
            bundle_disable_ftpsite_done="true"
        fi
        if ! RAILS_ENV=production bundle install 2>&1 | tee -a "$db_init_log_file"; then
            rm -f "$db_init_log_file"
            echo -e "${RED}Fehler: Bundler-Reparatur nach FtpsiteAgent-Fallback fehlgeschlagen.${NC}"
            exit 1
        fi
        if ! RAILS_ENV=production bundle exec rake db:create 2>&1 | tee -a "$db_init_log_file"; then
            rm -f "$db_init_log_file"
            echo -e "${RED}Fehler: Huginn Datenbank konnte auch nach FtpsiteAgent-Fallback nicht erstellt werden.${NC}"
            exit 1
        fi
    elif grep -Eq 'cannot load such file -- net/imap|cannot load such file -- net/smtp|cannot load such file -- gmail_xoauth' "$db_init_log_file" && [ "${HUGINN_ENABLE_NET_IMAP_COMPAT_ON_RUBY32}" = "true" ] && [ "$bundle_enable_net_imap_done" != "true" ]; then
        echo -e "${YELLOW}Hinweis: Huginn scheitert beim Rails-Start am alten gmail_xoauth/net-imap-Stack.${NC}"
        echo -e "${YELLOW}Versuche net-imap/net-smtp-Kompatibilitaet nachzuziehen und initialisiere die Datenbank danach erneut...${NC}"
        ensure_huginn_gmail_xoauth_compat_gems
        persist_huginn_lockfile "$db_init_log_file" net-imap net-smtp nokogiri racc mini_portile2
        ensure_huginn_lockfile_without_disabled_gems "$db_init_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$db_init_log_file"
        bundle_enable_net_imap_done="true"
        if ! RAILS_ENV=production bundle install 2>&1 | tee -a "$db_init_log_file"; then
            if [ "${HUGINN_DISABLE_GMAIL_XOAUTH_ON_NET_IMAP_FAILURE}" = "true" ] && [ "$bundle_disable_gmail_xoauth_done" != "true" ] && disable_huginn_gmail_xoauth_support; then
                prune_huginn_gmail_xoauth_lock_entries
                persist_huginn_lockfile "$db_init_log_file" nokogiri racc mini_portile2
                ensure_huginn_lockfile_without_disabled_gems "$db_init_log_file"
                bundle_disable_gmail_xoauth_done="true"
                if ! RAILS_ENV=production bundle install 2>&1 | tee -a "$db_init_log_file"; then
                    rm -f "$db_init_log_file"
                    echo -e "${RED}Fehler: Bundler-Reparatur nach Gmail-OAuth-Fallback fehlgeschlagen.${NC}"
                    exit 1
                fi
            else
                rm -f "$db_init_log_file"
                echo -e "${RED}Fehler: Bundler-Reparatur nach net-imap/net-smtp-Kompatibilitaet fehlgeschlagen.${NC}"
                exit 1
            fi
        fi
        if ! RAILS_ENV=production bundle exec rake db:create 2>&1 | tee -a "$db_init_log_file"; then
            if grep -Eq 'cannot load such file -- net/imap|cannot load such file -- net/smtp|cannot load such file -- gmail_xoauth' "$db_init_log_file" && [ "${HUGINN_DISABLE_GMAIL_XOAUTH_ON_NET_IMAP_FAILURE}" = "true" ] && [ "$bundle_disable_gmail_xoauth_done" != "true" ] && disable_huginn_gmail_xoauth_support; then
                prune_huginn_gmail_xoauth_lock_entries
                persist_huginn_lockfile "$db_init_log_file" nokogiri racc mini_portile2
                ensure_huginn_lockfile_without_disabled_gems "$db_init_log_file"
                bundle_disable_gmail_xoauth_done="true"
                if ! RAILS_ENV=production bundle install 2>&1 | tee -a "$db_init_log_file"; then
                    rm -f "$db_init_log_file"
                    echo -e "${RED}Fehler: Bundler-Reparatur nach Gmail-OAuth-Fallback fehlgeschlagen.${NC}"
                    exit 1
                fi
                if ! RAILS_ENV=production bundle exec rake db:create 2>&1 | tee -a "$db_init_log_file"; then
                    rm -f "$db_init_log_file"
                    echo -e "${RED}Fehler: Huginn Datenbank konnte auch nach Gmail-OAuth-Fallback nicht erstellt werden.${NC}"
                    exit 1
                fi
            else
                rm -f "$db_init_log_file"
                echo -e "${RED}Fehler: Huginn Datenbank konnte auch nach net-imap/net-smtp-Kompatibilitaet nicht erstellt werden.${NC}"
                exit 1
            fi
        fi
    elif grep -Eq 'mysql2\.so: undefined symbol: rb_tainted_str_new2|mysql2/mysql2\.so: undefined symbol: rb_tainted_str_new2' "$db_init_log_file" && [ "${HUGINN_ENABLE_MYSQL2_RUBY32_COMPAT}" = "true" ] && [ "$bundle_enable_mysql2_done" != "true" ] && [ "$(current_database_adapter)" = "mysql2" ]; then
        echo -e "${YELLOW}Hinweis: Huginn scheitert beim Rails-Start am alten mysql2-Stack.${NC}"
        echo -e "${YELLOW}Versuche mysql2 auf einen Ruby-3.2-kompatiblen Stand anzuheben und initialisiere die Datenbank danach erneut...${NC}"
        ensure_huginn_mysql2_ruby32_compat
        persist_huginn_lockfile "$db_init_log_file" mysql2 nokogiri racc mini_portile2
        ensure_huginn_lockfile_without_disabled_gems "$db_init_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$db_init_log_file"
        bundle_enable_mysql2_done="true"
        if ! RAILS_ENV=production bundle install 2>&1 | tee -a "$db_init_log_file"; then
            rm -f "$db_init_log_file"
            echo -e "${RED}Fehler: Bundler-Reparatur nach mysql2-Ruby-3.2-Kompatibilitaet fehlgeschlagen.${NC}"
            exit 1
        fi
        if ! RAILS_ENV=production bundle exec rake db:create 2>&1 | tee -a "$db_init_log_file"; then
            rm -f "$db_init_log_file"
            echo -e "${RED}Fehler: Huginn Datenbank konnte auch nach mysql2-Ruby-3.2-Kompatibilitaet nicht erstellt werden.${NC}"
            exit 1
        fi
    elif grep -Eq 'ruby-growl|x_growl_resource|uninitialized class variable @@schemes in URI' "$db_init_log_file" && [ "${HUGINN_DISABLE_GROWL_AGENT_ON_RUBY32_FAILURE}" = "true" ] && [ "$bundle_disable_growl_done" != "true" ]; then
        echo -e "${YELLOW}Hinweis: Huginn scheitert beim Rails-Start am alten ruby-growl/GrowlAgent-Stack.${NC}"
        echo -e "${YELLOW}Versuche Fallback ohne GrowlAgent und initialisiere die Datenbank danach erneut...${NC}"
        if disable_huginn_growl_agent; then
            prune_huginn_growl_lock_entries
            persist_huginn_lockfile "$db_init_log_file" nokogiri racc mini_portile2
            ensure_huginn_lockfile_without_disabled_gems "$db_init_log_file"
            bundle_disable_growl_done="true"
            if ! RAILS_ENV=production bundle install 2>&1 | tee -a "$db_init_log_file"; then
                rm -f "$db_init_log_file"
                echo -e "${RED}Fehler: Bundler-Reparatur nach GrowlAgent-Fallback fehlgeschlagen.${NC}"
                exit 1
            fi
            if ! RAILS_ENV=production bundle exec rake db:create 2>&1 | tee -a "$db_init_log_file"; then
                rm -f "$db_init_log_file"
                echo -e "${RED}Fehler: Huginn Datenbank konnte auch nach GrowlAgent-Fallback nicht erstellt werden.${NC}"
                exit 1
            fi
        else
            rm -f "$db_init_log_file"
            echo -e "${RED}Fehler: Huginn Datenbank konnte nicht erstellt werden.${NC}"
            exit 1
        fi
    elif grep -Eq 'pg_ext\.so: undefined symbol: rb_tainted_str_new|LoadError: .*pg_ext\.so' "$db_init_log_file" && [ "${HUGINN_ENABLE_PG_RUBY32_COMPAT}" = "true" ] && [ "${bundle_enable_pg_done:-false}" != "true" ] && [ "$(current_database_adapter)" = "postgresql" ]; then
        echo -e "${YELLOW}Hinweis: Huginn laeuft derzeit mit DATABASE_ADAPTER=postgresql und trifft dabei auf den alten pg-Stack dieses Huginn-Stands.${NC}"
        echo -e "${YELLOW}Versuche pg auf einen Ruby-3.2-kompatiblen Stand anzuheben und initialisiere die Datenbank danach erneut...${NC}"
        ensure_huginn_pg_ruby32_compat
        persist_huginn_lockfile "$db_init_log_file" pg
        ensure_huginn_lockfile_without_disabled_gems "$db_init_log_file"
        ensure_huginn_lockfile_without_nokogiri_legacy_linux "$db_init_log_file"
        bundle_enable_pg_done="true"
        if ! RAILS_ENV=production bundle install 2>&1 | tee -a "$db_init_log_file"; then
            rm -f "$db_init_log_file"
            echo -e "${RED}Fehler: Bundler-Reparatur nach pg-Ruby-3.2-Kompatibilitaet fehlgeschlagen.${NC}"
            exit 1
        fi
        if ! RAILS_ENV=production bundle exec rake db:create 2>&1 | tee -a "$db_init_log_file"; then
            rm -f "$db_init_log_file"
            echo -e "${RED}Fehler: Huginn Datenbank konnte auch nach pg-Ruby-3.2-Kompatibilitaet nicht erstellt werden.${NC}"
            exit 1
        fi
    elif grep -Eq 'pg_ext\.so: undefined symbol: rb_tainted_str_new|LoadError: .*pg_ext\.so' "$db_init_log_file" && [ "$(current_database_adapter)" = "postgresql" ]; then
        rm -f "$db_init_log_file"
        echo -e "${YELLOW}Hinweis: Huginn laeuft derzeit mit DATABASE_ADAPTER=postgresql und trifft dabei auf den alten pg-Stack dieses Huginn-Stands.${NC}"
        echo -e "${YELLOW}Unter Ruby 3.2 fuehrt das alte pg-Gem in diesem Upstream-Stand zu einem LoadError in pg_ext.so.${NC}"
        echo -e "${YELLOW}Wenn du Huginn auf MariaDB/MySQL betreiben willst, stelle die sichere Vorlage in ~/.openclaw_ultimate_user_data/huginn/.env.template auf DATABASE_ADAPTER=mysql2 um und starte die Installation erneut.${NC}"
        echo -e "${YELLOW}Wenn du bewusst PostgreSQL testen willst, pruefe HUGINN_ENABLE_PG_RUBY32_COMPAT=true oder einen neueren Upstream-Stand.${NC}"
        exit 1
    elif grep -Eq "Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld\.sock'|Mysql2::Error::ConnectionError" "$db_init_log_file" && [ "$(current_database_adapter)" = "mysql2" ]; then
        rm -f "$db_init_log_file"
        print_huginn_mysql_service_guidance
        echo -e "${YELLOW}Deine aktuelle .env zeigt derzeit auf eine lokale MySQL-Standardverbindung ohne gesetzten DATABASE_HOST.${NC}"
        echo -e "${YELLOW}Wenn du lokal bleiben willst, installiere und starte MariaDB/MySQL zuerst. Wenn du extern arbeiten willst, setze DATABASE_HOST, DATABASE_PORT und passende Zugangsdaten.${NC}"
        exit 1
    else
        rm -f "$db_init_log_file"
        echo -e "${RED}Fehler: Huginn Datenbank konnte nicht erstellt werden.${NC}"
        exit 1
    fi
fi
rm -f "$db_init_log_file"

if ! RAILS_ENV=production bundle exec rake db:migrate; then
    echo -e "${RED}Fehler: Huginn Datenbankmigration fehlgeschlagen.${NC}"
    exit 1
fi

echo -e "${GREEN}6/6: Vorkompiliere Production-Assets...${NC}"
prepare_huginn_frontend_dependencies
if ! RAILS_ENV=production bundle exec rake assets:precompile; then
    echo -e "${RED}Fehler: Huginn Asset-Precompile fehlgeschlagen.${NC}"
    exit 1
fi

echo -e "${GREEN}7/7: Richte optionalen Dauerbetrieb als lokale systemd-Dienste ein...${NC}"
if install_huginn_systemd_units; then
    if enable_and_start_huginn_systemd_units; then
        echo -e "${GREEN}Huginn Dauerbetrieb aktiviert: ${HUGINN_SYSTEMD_WEB_SERVICE} und ${HUGINN_SYSTEMD_WORKER_SERVICE}.${NC}"
    else
        echo -e "${YELLOW}Warnung: Die Huginn-Dienste wurden angelegt, konnten aber nicht automatisch gestartet werden.${NC}"
        echo -e "${YELLOW}Pruefe spaeter mit: sudo systemctl status ${HUGINN_SYSTEMD_WEB_SERVICE} ${HUGINN_SYSTEMD_WORKER_SERVICE}${NC}"
    fi
fi

echo -e "${YELLOW}Hinweis: Das Seeding von Huginn wurde nicht blind automatisiert, damit keine unsicheren Standard-Zugangsdaten entstehen.${NC}"
echo -e "${YELLOW}Wenn du Beispiel-Daten oder einen Startbenutzer anlegen willst, führe danach bewusst 'RAILS_ENV=production bundle exec rake db:seed' aus.${NC}"
echo -e "${YELLOW}Huginn Invitation Code: $(current_huginn_invitation_code)${NC}"
echo -e "${YELLOW}Zum Nachlesen im Terminal: grep '^INVITATION_CODE=' $HUGINN_DIR/.env${NC}"
echo -e "${YELLOW}Optionaler erster Admin ohne Web-Registrierung:${NC}"
echo "cd $HUGINN_DIR && RAILS_ENV=production bundle exec rails runner \"u=User.new(username: 'admin', email: 'admin@example.com', password: 'change-me-now', password_confirmation: 'change-me-now', admin: true); u.requires_no_invitation_code!; u.save!\""
echo -e "${YELLOW}Start-Hinweis: RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 bundle exec rails server -p ${HUGINN_WEB_PORT}${NC}"
echo -e "${YELLOW}Port-Hinweis: Upstream-Default ${HUGINN_UPSTREAM_DEFAULT_PORT}, Setup-Empfehlung ${HUGINN_WEB_PORT}.${NC}"
echo -e "${YELLOW}Dienst-Status: sudo systemctl status ${HUGINN_SYSTEMD_WEB_SERVICE} ${HUGINN_SYSTEMD_WORKER_SERVICE}${NC}"
echo -e "${YELLOW}Dienst-Neustart: sudo systemctl restart ${HUGINN_SYSTEMD_WEB_SERVICE} ${HUGINN_SYSTEMD_WORKER_SERVICE}${NC}"

mark_current_tool_installed
echo -e "${GREEN}Huginn Installation abgeschlossen.${NC}"
