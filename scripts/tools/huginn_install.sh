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
HUGINN_SKIP_SYSTEM_PACKAGES="${HUGINN_SKIP_SYSTEM_PACKAGES:-false}"

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

ensure_production_env_defaults() {
    if ! grep -Eq '^RAILS_ENV=' .env 2>/dev/null; then
        echo "RAILS_ENV=production" >> .env
    fi
}

database_config_complete() {
    local adapter

    adapter="$(awk -F= '/^DATABASE_ADAPTER=/{print $2}' .env | tail -n 1 | tr -d '\r" ')"
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

huginn_google_translate_agent_active() {
    grep -Eq "^gem 'google-cloud-translate'.*google/cloud/translate" Gemfile 2>/dev/null
}

legacy_huginn_google_grpc_stack_present() {
    if ! [ -f Gemfile.lock ]; then
        return 1
    fi

    huginn_google_translate_agent_active &&
    lockfile_contains_pattern '^\s*grpc \(1\.42\.0\)$|^\s*google-gax \(1\.8\.2\)$|^\s*googleapis-common-protos \(1\.3\.12\)$'
}

ensure_huginn_lockfile_without_nokogiri_legacy_linux() {
    local bundle_log_file="$1"

    if lockfile_contains_pattern '^\s*nokogiri \(1\.13\.8(-x86_64-linux)?\)$|^\s*nokogiri \(1\.13\.8-x86_64-linux\)$'; then
        echo -e "${YELLOW}Gemfile.lock enthält weiterhin den veralteten nokogiri-Stand. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi
}

ensure_huginn_lockfile_without_disabled_gems() {
    local bundle_log_file="$1"

    if grep -Eq '^# gem '\''mini_racer'\''' Gemfile 2>/dev/null && lockfile_contains_pattern '^\s*mini_racer \('; then
        echo -e "${YELLOW}Gemfile.lock enthält mini_racer noch trotz deaktiviertem JavaScriptAgent. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi

    if grep -Eq '^# gem '\''google-cloud-translate'\''' Gemfile 2>/dev/null && lockfile_contains_pattern '^\s*google-cloud-translate \('; then
        echo -e "${YELLOW}Gemfile.lock enthält google-cloud-translate noch trotz deaktiviertem GoogleTranslateAgent. Erzwinge einen Neuaufbau des Lockfiles...${NC}"
        rebuild_huginn_lockfile_from_current_gemfile "$bundle_log_file"
    fi
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
        persist_huginn_lockfile "$bundle_log_file" nokogiri racc mini_portile2 google-gax google-protobuf googleapis-common-protos googleapis-common-protos-types grpc
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
echo -e "${YELLOW}Wenn du bewusst einen anderen Upstream-Stand testen willst, kannst du HUGINN_REPO_REF überschreiben.${NC}"

echo -e "${GREEN}1/5: Installiere System-Abhängigkeiten für Huginn...${NC}"
if [ "$HUGINN_SKIP_SYSTEM_PACKAGES" != "true" ]; then
    sudo apt-get update
    sudo apt-get install -y ruby-full ruby-bundler build-essential libmysqlclient-dev libpq-dev pkg-config
else
    echo -e "${YELLOW}Überspringe Systempakete, weil HUGINN_SKIP_SYSTEM_PACKAGES=true gesetzt ist.${NC}"
fi

echo -e "${GREEN}2/5: Hole Huginn aus GitHub...${NC}"
checkout_huginn_ref

mkdir -p log tmp/pids tmp/sockets
chmod -R u+rwX,go-w log tmp

echo -e "${GREEN}3/5: Bereite .env und Verzeichnisse vor...${NC}"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        touch .env
    fi
fi
ensure_secret_token
ensure_production_env_defaults
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
bundle_disable_js_done="false"
bundle_disable_translate_done="false"

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
            persist_huginn_lockfile "$bundle_log_file"
            ensure_huginn_lockfile_without_disabled_gems "$bundle_log_file"
            ensure_huginn_lockfile_without_nokogiri_legacy_linux "$bundle_log_file"
            echo -e "${YELLOW}Huginn wurde ohne JavaScriptAgent vorbereitet. Die Datei $HUGINN_DIR/Gemfile.bak.before_no_mini_racer enthält die Originalzeile.${NC}"
            bundle_disable_js_done="true"
            bundle_repair_nokogiri_done="false"
            continue
        fi
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
    echo "RAILS_ENV=production bundle exec rails server -p 3000"
    mark_current_tool_installed
    echo -e "${GREEN}Huginn wurde als vorbereitet markiert.${NC}"
    exit 0
fi

echo -e "${GREEN}5/5: Initialisiere Datenbank...${NC}"
if ! RAILS_ENV=production bundle exec rake db:create; then
    echo -e "${RED}Fehler: Huginn Datenbank konnte nicht erstellt werden.${NC}"
    exit 1
fi
if ! RAILS_ENV=production bundle exec rake db:migrate; then
    echo -e "${RED}Fehler: Huginn Datenbankmigration fehlgeschlagen.${NC}"
    exit 1
fi

echo -e "${YELLOW}Hinweis: Das Seeding von Huginn wurde nicht blind automatisiert, damit keine unsicheren Standard-Zugangsdaten entstehen.${NC}"
echo -e "${YELLOW}Wenn du Beispiel-Daten oder einen Startbenutzer anlegen willst, führe danach bewusst 'RAILS_ENV=production bundle exec rake db:seed' aus.${NC}"
echo -e "${YELLOW}Start-Hinweis: RAILS_ENV=production bundle exec rails server -p 3000${NC}"

mark_current_tool_installed
echo -e "${GREEN}Huginn Installation abgeschlossen.${NC}"
