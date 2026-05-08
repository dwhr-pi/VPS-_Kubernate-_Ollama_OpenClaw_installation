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

HUGINN_DIR="/opt/huginn"
HUGINN_REPO_URL="${HUGINN_REPO_URL:-https://github.com/huginn/huginn.git}"
HUGINN_REPO_REF="${HUGINN_REPO_REF:-v2022.08.18}"
HUGINN_DISABLE_JAVASCRIPT_AGENT_ON_LIBV8_FAILURE="${HUGINN_DISABLE_JAVASCRIPT_AGENT_ON_LIBV8_FAILURE:-true}"
HUGINN_FORCE_RUBY_PLATFORM="${HUGINN_FORCE_RUBY_PLATFORM:-false}"
HUGINN_GRPC_VERSION="${HUGINN_GRPC_VERSION:-~> 1.54.3}"
HUGINN_EXPECTED_BUNDLER_VERSION="${HUGINN_EXPECTED_BUNDLER_VERSION:-}"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
HUGINN_TEMPLATE_DIR="$USER_WORKSPACE_DIR/huginn"
HUGINN_TEMPLATE_FILE="$HUGINN_TEMPLATE_DIR/.env.template"
HUGINN_REPO_TEMPLATE_FILE="$INSTALL_DIR/scripts/config_templates/huginn/.env.template"

print_runtime_summary() {
    local ruby_version bundler_version

    ruby_version="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || echo 'unbekannt')"
    bundler_version="$(bundle --version 2>/dev/null | awk '{print $3}' || echo 'unbekannt')"

    echo -e "${YELLOW}Ruby erkannt: ${ruby_version}${NC}"
    echo -e "${YELLOW}Bundler erkannt: ${bundler_version}${NC}"
}

warn_if_ruby_version_is_unexpected() {
    local ruby_version ruby_major_minor

    ruby_version="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || true)"
    ruby_major_minor="$(printf '%s' "$ruby_version" | awk -F. '{print $1 "." $2}')"

    if [ -n "$ruby_major_minor" ] && [ "$ruby_major_minor" != "2.7" ]; then
        echo -e "${YELLOW}Hinweis: Huginn ${HUGINN_REPO_REF} wurde mit Ruby 2.7.x gepflegt, erkannt wurde aber Ruby ${ruby_version}.${NC}"
        echo -e "${YELLOW}Die Installation kann trotzdem funktionieren, aber bei nativen Gems und Rails-Tasks sind Abweichungen moeglich.${NC}"
    fi
}

detect_lockfile_bundler_version() {
    awk '
        /^BUNDLED WITH$/ { getline; gsub(/^[[:space:]]+/, "", $0); print $0; exit }
    ' Gemfile.lock 2>/dev/null || true
}

ensure_matching_bundler() {
    local requested_version bundler_command current_version

    requested_version="${HUGINN_EXPECTED_BUNDLER_VERSION}"
    if [ -z "$requested_version" ]; then
        requested_version="$(detect_lockfile_bundler_version || true)"
    fi
    if [ -z "$requested_version" ]; then
        BUNDLE_CMD="bundle"
        return 0
    fi

    current_version="$(bundle --version 2>/dev/null | awk '{print $3}' || true)"
    if [ "$current_version" != "$requested_version" ]; then
        echo -e "${YELLOW}Installiere Bundler ${requested_version}, passend zum Huginn-Lockfile...${NC}"
        gem install bundler -v "$requested_version"
    fi

    bundler_command="bundle _${requested_version}_"
    if ! bash -lc "${bundler_command} --version" >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Bundler ${requested_version} konnte nicht aktiviert werden.${NC}"
        exit 1
    fi

    BUNDLE_CMD="$bundler_command"
}

configure_bundle_platform() {
    "$BUNDLE_CMD" config set --local path vendor/bundle
    "$BUNDLE_CMD" config set --local without "development test"

    if [ "$HUGINN_FORCE_RUBY_PLATFORM" = "true" ]; then
        echo -e "${YELLOW}force_ruby_platform=true wurde explizit angefordert. Native Gems werden aus dem Quellcode gebaut.${NC}"
        "$BUNDLE_CMD" config set --local force_ruby_platform true
    else
        "$BUNDLE_CMD" config unset --local force_ruby_platform >/dev/null 2>&1 || true
        "$BUNDLE_CMD" lock --add-platform x86_64-linux >/dev/null 2>&1 || true
        "$BUNDLE_CMD" lock --add-platform ruby >/dev/null 2>&1 || true
        echo -e "${YELLOW}Bevorzuge vorkompilierte Linux-Gems, damit Legacy-Abhaengigkeiten wie grpc nicht unnoetig lokal kompiliert werden.${NC}"
    fi
}

bundle_log_has_grpc_issue() {
    local log_file="$1"
    grep -Eq 'grpc|google-protobuf|google-cloud-translate|google-gax|googleapis-common-protos|FormatConversionChar' "$log_file"
}

ensure_huginn_template_workspace() {
    mkdir -p "$HUGINN_TEMPLATE_DIR"

    if [ ! -f "$HUGINN_TEMPLATE_FILE" ]; then
        if [ -f "$HUGINN_REPO_TEMPLATE_FILE" ]; then
            cp "$HUGINN_REPO_TEMPLATE_FILE" "$HUGINN_TEMPLATE_FILE"
        elif [ -f ".env.example" ]; then
            cp .env.example "$HUGINN_TEMPLATE_FILE"
        else
            touch "$HUGINN_TEMPLATE_FILE"
        fi
    fi
}

ensure_grpc_compatibility_override() {
    HUGINN_GRPC_VERSION="$HUGINN_GRPC_VERSION" python3 - <<'PY'
import os
from pathlib import Path

path = Path("Gemfile")
text = path.read_text(encoding="utf-8")
marker = "gem 'google-cloud-translate', '~> 2.0', require: 'google/cloud/translate'\n"
grpc_version = os.environ["HUGINN_GRPC_VERSION"]
override_line = f"gem 'grpc', '{grpc_version}' # Setup-Fix: vermeidet bekannte Build-Probleme mit grpc 1.42 auf moderner Toolchain\n"
override = marker + override_line

if "gem 'grpc'," in text:
    lines = text.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if "Setup-Fix: vermeidet bekannte Build-Probleme mit grpc 1.42 auf moderner Toolchain" in line:
            lines[index] = override_line
            text = "".join(lines)
            break
    else:
        raise SystemExit(1)
elif marker in text:
    text = text.replace(marker, override, 1)
else:
    raise SystemExit(1)

path.write_text(text, encoding="utf-8")
PY
}

try_grpc_stack_refresh() {
    echo -e "${YELLOW}Versuche kompatiblen grpc-Fallback mit ${HUGINN_GRPC_VERSION}...${NC}"

    cp Gemfile Gemfile.bak.before_grpc_override 2>/dev/null || true
    cp Gemfile.lock Gemfile.lock.bak.before_grpc_override 2>/dev/null || true

    if ! ensure_grpc_compatibility_override; then
        echo -e "${RED}Fehler: grpc-Fallback konnte nicht sicher in die Gemfile eingetragen werden.${NC}"
        return 1
    fi

    "$BUNDLE_CMD" update grpc google-protobuf googleapis-common-protos googleapis-common-protos-types 2>&1
}

disable_google_translate_agent() {
    if ! grep -Eq "^gem 'google-cloud-translate'.*google/cloud/translate" Gemfile 2>/dev/null; then
        return 1
    fi

    cp Gemfile Gemfile.bak.before_no_google_translate 2>/dev/null || true
    python3 - <<'PY'
from pathlib import Path

path = Path("Gemfile")
lines = path.read_text(encoding="utf-8").splitlines()
updated = []
for line in lines:
    if line.startswith("gem 'google-cloud-translate', '~> 2.0', require: 'google/cloud/translate'"):
        updated.append("# gem 'google-cloud-translate', '~> 2.0', require: 'google/cloud/translate' # deaktiviert durch Setup-Fallback wegen grpc 1.42 Build-Fehler")
    elif "Setup-Fix: vermeidet bekannte Build-Probleme mit grpc 1.42 auf moderner Toolchain" in line:
        continue
    else:
        updated.append(line)

path.write_text("\n".join(updated) + "\n", encoding="utf-8")
PY
}

refresh_google_translate_lockfile() {
    cp Gemfile.lock Gemfile.lock.bak.before_no_google_translate 2>/dev/null || true

    "$BUNDLE_CMD" update google-cloud-translate google-gax googleapis-common-protos googleapis-common-protos-types grpc google-protobuf 2>&1 || true

    if [ -f Gemfile.lock ] && grep -Eq 'grpc \(1\.42\.0\)|google-cloud-translate \(2\.3\.0\)|google-gax \(1\.8\.2\)|googleapis-common-protos \(1\.3\.12\)' Gemfile.lock; then
        echo -e "${YELLOW}Das alte Huginn-Lockfile haelt den Legacy-gRPC-Stack weiter fest. Entferne Gemfile.lock fuer eine frische Aufloesung ohne GoogleTranslateAgent...${NC}"
        rm -f Gemfile.lock
    fi
}

apply_google_translate_grpc_fallback() {
    echo -e "${YELLOW}Hinweis: Der alte Google-Translate-Stack zieht weiterhin grpc 1.42.0 nach.${NC}"
    echo -e "${YELLOW}Versuche Fallback ohne GoogleTranslateAgent, damit Huginn auf modernem Ruby weiter installiert werden kann.${NC}"

    if ! disable_google_translate_agent; then
        echo -e "${RED}Fehler: GoogleTranslate-Fallback konnte in der Gemfile nicht sicher angewendet werden.${NC}"
        return 1
    fi

    refresh_google_translate_lockfile
    return 0
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
        sudo mkdir -p "$HUGINN_DIR"
        sudo chown -R "$USER:$USER" "$HUGINN_DIR"
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

echo -e "${BLUE}Starte Installation von Huginn...${NC}"
echo -e "${YELLOW}Standard-Referenz: ${HUGINN_REPO_REF}.${NC}"
echo -e "${YELLOW}Wenn du bewusst einen anderen Upstream-Stand testen willst, kannst du HUGINN_REPO_REF überschreiben.${NC}"

echo -e "${GREEN}1/5: Installiere System-Abhängigkeiten für Huginn...${NC}"
sudo apt-get update
sudo apt-get install -y ruby-full ruby-bundler build-essential libmysqlclient-dev libpq-dev pkg-config git curl libyaml-dev zlib1g-dev libffi-dev shared-mime-info

echo -e "${GREEN}2/5: Hole Huginn aus GitHub...${NC}"
checkout_huginn_ref

mkdir -p log tmp/pids tmp/sockets
chmod -R u+rwX,go-w log tmp

echo -e "${GREEN}3/5: Bereite .env und Verzeichnisse vor...${NC}"
ensure_huginn_template_workspace
if [ ! -f .env ]; then
    if [ -f "$HUGINN_TEMPLATE_FILE" ]; then
        cp "$HUGINN_TEMPLATE_FILE" .env
    elif [ -f .env.example ]; then
        cp .env.example .env
    else
        touch .env
    fi
fi
ensure_secret_token
ensure_production_env_defaults
chmod o-rwx .env 2>/dev/null || true
echo -e "${YELLOW}Bearbeitbare Huginn-Vorlage: ${HUGINN_TEMPLATE_FILE}${NC}"
echo -e "${YELLOW}Huginn-Laufzeitdatei: ${HUGINN_DIR}/.env${NC}"

echo -e "${GREEN}4/5: Installiere Ruby Gems mit Bundler...${NC}"
if ! command -v bundle >/dev/null 2>&1; then
    gem install bundler
fi
warn_if_ruby_version_is_unexpected
ensure_matching_bundler
print_runtime_summary
configure_bundle_platform
echo -e "${YELLOW}Hinweis: 'development test' ist hier keine Versionsnummer, sondern die ausgeschlossene Bundler-Gruppenkombination.${NC}"
bundle_log_file="$(mktemp)"
if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee "$bundle_log_file"; then
    if grep -Eq 'nokogiri .* can no longer be found' "$bundle_log_file"; then
        echo -e "${YELLOW}Hinweis: Bundler ist auf eine entfernte nokogiri-Binärversion gelaufen. Versuche Reparatur mit Ruby-Plattform und nokogiri-Update...${NC}"
        bash -lc "$BUNDLE_CMD update nokogiri" 2>&1 | tee -a "$bundle_log_file" || true
        if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
            if bundle_log_has_grpc_issue "$bundle_log_file"; then
                if ! try_grpc_stack_refresh 2>&1 | tee -a "$bundle_log_file"; then
                    rm -f "$bundle_log_file"
                    echo -e "${RED}Fehler: grpc-Kompatibilitaetsfallback für Huginn fehlgeschlagen.${NC}"
                    exit 1
                fi
                if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
                    if bundle_log_has_grpc_issue "$bundle_log_file"; then
                        if ! apply_google_translate_grpc_fallback 2>&1 | tee -a "$bundle_log_file"; then
                            rm -f "$bundle_log_file"
                            echo -e "${RED}Fehler: GoogleTranslate-gRPC-Fallback für Huginn fehlgeschlagen.${NC}"
                            exit 1
                        fi
                        if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
                            rm -f "$bundle_log_file"
                            echo -e "${RED}Fehler: Bundler install für Huginn ist nach nokogiri-, grpc- und GoogleTranslate-Fallback fehlgeschlagen.${NC}"
                            exit 1
                        fi
                    else
                        rm -f "$bundle_log_file"
                        echo -e "${RED}Fehler: Bundler install für Huginn ist nach nokogiri- und grpc-Fallback fehlgeschlagen.${NC}"
                        exit 1
                    fi
                fi
            else
                rm -f "$bundle_log_file"
                echo -e "${RED}Fehler: Bundler install für Huginn fehlgeschlagen.${NC}"
                exit 1
            fi
        fi
    elif bundle_log_has_grpc_issue "$bundle_log_file"; then
        if ! try_grpc_stack_refresh 2>&1 | tee -a "$bundle_log_file"; then
            if ! apply_google_translate_grpc_fallback 2>&1 | tee -a "$bundle_log_file"; then
                rm -f "$bundle_log_file"
                echo -e "${RED}Fehler: grpc-Kompatibilitaetsfallback für Huginn fehlgeschlagen.${NC}"
                exit 1
            fi
            if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
                rm -f "$bundle_log_file"
                echo -e "${RED}Fehler: Bundler install für Huginn ist trotz GoogleTranslate-Fallback fehlgeschlagen.${NC}"
                exit 1
            fi
            rm -f "$bundle_log_file"
            true
        fi
        if [ -f "$bundle_log_file" ] && ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
            if bundle_log_has_grpc_issue "$bundle_log_file"; then
                if ! apply_google_translate_grpc_fallback 2>&1 | tee -a "$bundle_log_file"; then
                    rm -f "$bundle_log_file"
                    echo -e "${RED}Fehler: GoogleTranslate-gRPC-Fallback für Huginn fehlgeschlagen.${NC}"
                    exit 1
                fi
                if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
                    rm -f "$bundle_log_file"
                    echo -e "${RED}Fehler: Bundler install für Huginn ist trotz grpc- und GoogleTranslate-Fallback fehlgeschlagen.${NC}"
                    exit 1
                fi
            else
                rm -f "$bundle_log_file"
                echo -e "${RED}Fehler: Bundler install für Huginn ist trotz grpc-Fallback fehlgeschlagen.${NC}"
                exit 1
            fi
        fi
    elif grep -Eq 'An error occurred while installing libv8-node|mini_racer was resolved to .* depends on[[:space:]]+libv8-node' "$bundle_log_file" && [ "${HUGINN_DISABLE_JAVASCRIPT_AGENT_ON_LIBV8_FAILURE}" = "true" ]; then
        echo -e "${YELLOW}Hinweis: mini_racer bzw. libv8-node konnte auf diesem System nicht gebaut werden.${NC}"
        echo -e "${YELLOW}Versuche Fallback ohne JavaScriptAgent, damit Huginn sonst weiter installiert werden kann.${NC}"
        if disable_huginn_javascript_agent; then
            bash -lc "$BUNDLE_CMD update mini_racer libv8-node" 2>&1 | tee -a "$bundle_log_file" || true
            if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
                if bundle_log_has_grpc_issue "$bundle_log_file"; then
                    if ! apply_google_translate_grpc_fallback 2>&1 | tee -a "$bundle_log_file"; then
                        rm -f "$bundle_log_file"
                        echo -e "${RED}Fehler: GoogleTranslate-gRPC-Fallback für Huginn nach JavaScriptAgent-Fallback fehlgeschlagen.${NC}"
                        exit 1
                    fi
                    if ! bash -lc "$BUNDLE_CMD install" 2>&1 | tee -a "$bundle_log_file"; then
                        rm -f "$bundle_log_file"
                        echo -e "${RED}Fehler: Bundler install für Huginn ist nach JavaScriptAgent- und GoogleTranslate-Fallback fehlgeschlagen.${NC}"
                        exit 1
                    fi
                else
                    rm -f "$bundle_log_file"
                    echo -e "${RED}Fehler: Bundler install für Huginn fehlgeschlagen.${NC}"
                    exit 1
                fi
            fi
            echo -e "${YELLOW}Huginn wurde ohne JavaScriptAgent vorbereitet. Die Datei $HUGINN_DIR/Gemfile.bak.before_no_mini_racer enthält die Originalzeile.${NC}"
            if grep -Eq "^# gem 'google-cloud-translate'.*deaktiviert durch Setup-Fallback" Gemfile 2>/dev/null; then
                echo -e "${YELLOW}Zusätzlich wurde GoogleTranslateAgent deaktiviert, damit der alte grpc-1.42-Zweig auf modernem Ruby nicht weiter blockiert.${NC}"
            fi
        else
            rm -f "$bundle_log_file"
            echo -e "${RED}Fehler: mini_racer/libv8-node schlug fehl, aber der Fallback konnte in der Gemfile nicht sicher angewendet werden.${NC}"
            exit 1
        fi
    else
        rm -f "$bundle_log_file"
        echo -e "${RED}Fehler: Bundler install für Huginn fehlgeschlagen.${NC}"
        exit 1
    fi
fi
rm -f "$bundle_log_file"

if ! database_config_complete; then
    echo -e "${YELLOW}Huginn Quellcode und Gems wurden vorbereitet, aber die Datenbank-Konfiguration in $HUGINN_DIR/.env ist noch unvollständig.${NC}"
    echo -e "${YELLOW}Bitte trage mindestens DATABASE_ADAPTER, DATABASE_NAME und je nach Adapter auch DATABASE_USERNAME/DATABASE_PASSWORD ein.${NC}"
    echo -e "${YELLOW}Danach kannst du manuell fortsetzen mit:${NC}"
    echo "cd $HUGINN_DIR"
    echo "RAILS_ENV=production $BUNDLE_CMD exec rake db:create"
    echo "RAILS_ENV=production $BUNDLE_CMD exec rake db:migrate"
    echo "RAILS_ENV=production $BUNDLE_CMD exec rake db:seed"
    echo "RAILS_ENV=production $BUNDLE_CMD exec rails server -p 3000"
    mark_current_tool_installed
    echo -e "${GREEN}Huginn wurde als vorbereitet markiert.${NC}"
    exit 0
fi

echo -e "${GREEN}5/5: Initialisiere Datenbank...${NC}"
if ! bash -lc "RAILS_ENV=production $BUNDLE_CMD exec rake db:create"; then
    echo -e "${RED}Fehler: Huginn Datenbank konnte nicht erstellt werden.${NC}"
    exit 1
fi
if ! bash -lc "RAILS_ENV=production $BUNDLE_CMD exec rake db:migrate"; then
    echo -e "${RED}Fehler: Huginn Datenbankmigration fehlgeschlagen.${NC}"
    exit 1
fi

echo -e "${YELLOW}Hinweis: Das Seeding von Huginn wurde nicht blind automatisiert, damit keine unsicheren Standard-Zugangsdaten entstehen.${NC}"
echo -e "${YELLOW}Wenn du Beispiel-Daten oder einen Startbenutzer anlegen willst, führe danach bewusst 'RAILS_ENV=production $BUNDLE_CMD exec rake db:seed' aus.${NC}"
echo -e "${YELLOW}Start-Hinweis: RAILS_ENV=production $BUNDLE_CMD exec rails server -p 3000${NC}"

mark_current_tool_installed
echo -e "${GREEN}Huginn Installation abgeschlossen.${NC}"
