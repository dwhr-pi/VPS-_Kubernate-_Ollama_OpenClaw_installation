#!/bin/bash
#
# Skript: clawhub_install.sh
# Beschreibung: Installiert Clawhub aus GitHub. Clawhub ist aktuell ein Bun-
# Workspace-Projekt; pnpm wird nur noch als Fallback fuer abweichende Forks genutzt.
#

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
init_tool_tracking "Clawhub"

CLAWHUB_DIR="/opt/clawhub"
PNPM_REGISTRY_URL="${PNPM_REGISTRY_URL:-https://registry.npmjs.org}"
CLAWHUB_REPOS=(
    "${CLAWHUB_REPO_URL:-}"
    "https://github.com/openclaw/clawhub.git"
    "https://github.com/dwhr-pi/clawhub.git"
)

require_command() {
    local cmd="$1"
    local hint="$2"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Benötigter Befehl '$cmd' wurde nicht gefunden.${NC}"
        echo -e "${YELLOW}${hint}${NC}"
        exit 1
    fi
}

check_npm_registry() {
    local url="$1"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSI --connect-timeout 10 --max-time 20 "$url/pnpm" >/dev/null 2>&1 && return 0
    elif command -v wget >/dev/null 2>&1; then
        wget -q --spider --timeout=20 "$url/pnpm" && return 0
    else
        echo -e "${YELLOW}Hinweis: Weder curl noch wget gefunden, Registry-Preflight wird übersprungen.${NC}"
        return 0
    fi

    echo -e "${RED}Fehler: Die npm-Registry unter $url ist derzeit nicht zuverlässig erreichbar.${NC}"
    echo -e "${YELLOW}Typische Ursachen: DNS-Probleme, Proxy/Firewall, temporäre Paket-Registry-Störung oder instabile Internetverbindung.${NC}"
    exit 1
}

ensure_bun_prerequisites() {
    local missing_packages=()
    local package

    for package in curl ca-certificates unzip; do
        case "$package" in
            curl)
                command -v curl >/dev/null 2>&1 || missing_packages+=("$package")
                ;;
            unzip)
                command -v unzip >/dev/null 2>&1 || missing_packages+=("$package")
                ;;
            ca-certificates)
                dpkg -s ca-certificates >/dev/null 2>&1 || missing_packages+=("$package")
                ;;
        esac
    done

    if [ "${#missing_packages[@]}" -eq 0 ]; then
        return 0
    fi

    echo -e "${YELLOW}Installiere fehlende Bun-Basisabhaengigkeiten: ${missing_packages[*]}${NC}"
    echo -e "${YELLOW}Primaerquelle fuer Clawhub bleibt GitHub; apt installiert hier nur notwendige Systempakete wie unzip.${NC}"
    sudo apt-get update
    sudo apt-get install -y "${missing_packages[@]}"
}

project_prefers_bun() {
    [ -f "package.json" ] || return 1
    grep -q 'only-allow bun' package.json 2>/dev/null && return 0
    [ -f "bun.lockb" ] || [ -f "bun.lock" ]
}

ensure_bun_runtime() {
    export PATH="$HOME/.bun/bin:$PATH"

    if command -v bun >/dev/null 2>&1 && command -v bunx >/dev/null 2>&1; then
        return 0
    fi

    ensure_bun_prerequisites
    echo -e "${YELLOW}Hinweis: Clawhub nutzt Bun als Paketmanager. Installiere bun fuer den aktuellen Benutzer...${NC}"
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"

    if ! command -v bun >/dev/null 2>&1 || ! command -v bunx >/dev/null 2>&1; then
        echo -e "${RED}Fehler: bun konnte nicht korrekt eingerichtet werden.${NC}"
        exit 1
    fi
}

ensure_pnpm_workspace_file() {
    if [ -f "pnpm-workspace.yaml" ] || [ ! -f "package.json" ]; then
        return 0
    fi

    if ! command -v node >/dev/null 2>&1; then
        echo -e "${YELLOW}Hinweis: node nicht gefunden, automatische pnpm-Workspace-Erkennung wird übersprungen.${NC}"
        return 0
    fi

    if node <<'NODE' >/tmp/clawhub-pnpm-workspace.log 2>&1
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const workspaces = Array.isArray(pkg.workspaces)
  ? pkg.workspaces
  : Array.isArray(pkg.workspaces && pkg.workspaces.packages)
    ? pkg.workspaces.packages
    : [];

if (!workspaces.length) process.exit(1);

const body = "packages:\n" + workspaces.map((entry) => `  - '${String(entry).replace(/'/g, "''")}'`).join("\n") + "\n";
fs.writeFileSync("pnpm-workspace.yaml", body, "utf8");
process.stdout.write("pnpm-workspace.yaml wurde aus package.json/workspaces erzeugt.");
NODE
    then
        echo -e "${YELLOW}Hinweis: package.json nutzt Workspaces, aber pnpm-workspace.yaml fehlte.${NC}"
        cat /tmp/clawhub-pnpm-workspace.log
    fi
}

run_bun_install() {
    local attempt
    for attempt in 1 2 3; do
        echo -e "${BLUE}bun install Versuch ${attempt}/3...${NC}"
        if bun install; then
            return 0
        fi
        [ "$attempt" -lt 3 ] && echo -e "${YELLOW}bun install fehlgeschlagen. Neuer Versuch in 15 Sekunden...${NC}" && sleep 15
    done
    return 1
}

run_pnpm_install() {
    local attempt
    for attempt in 1 2 3; do
        echo -e "${BLUE}pnpm install Versuch ${attempt}/3...${NC}"
        if pnpm install --fetch-retries 5 --fetch-timeout 120000 --network-concurrency 8; then
            return 0
        fi
        [ "$attempt" -lt 3 ] && echo -e "${YELLOW}pnpm install fehlgeschlagen. Neuer Versuch in 15 Sekunden...${NC}" && sleep 15
    done
    return 1
}

echo -e "${BLUE}Starte Installation von Clawhub (Server)...${NC}"

require_command git "Bitte git installieren und das Skript erneut starten."

CLAWHUB_REPO_URL=""
for repo in "${CLAWHUB_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if GIT_TERMINAL_PROMPT=0 git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        CLAWHUB_REPO_URL="$repo"
        break
    fi
done

if [ -z "$CLAWHUB_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Clawhub Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden openclaw/clawhub und dwhr-pi/clawhub.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf CLAWHUB_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

echo -e "${BLUE}Primaerquelle: ${CLAWHUB_REPO_URL}${NC}"

if [ -d "$CLAWHUB_DIR/.git" ]; then
    echo -e "${YELLOW}Clawhub Verzeichnis $CLAWHUB_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$CLAWHUB_DIR"
    GIT_TERMINAL_PROMPT=0 git pull --ff-only
elif [ -d "$CLAWHUB_DIR" ]; then
    echo -e "${YELLOW}Vorhandenes Clawhub-Verzeichnis ist kein vollstaendiger Git-Clone. Bitte erst sichern oder entfernen:${NC}"
    echo -e "${YELLOW}  sudo rm -rf $CLAWHUB_DIR${NC}"
    exit 1
else
    echo -e "${BLUE}Klone Clawhub in $CLAWHUB_DIR...${NC}"
    sudo mkdir -p "$CLAWHUB_DIR"
    sudo chown -R "$USER:$USER" "$CLAWHUB_DIR"
    GIT_TERMINAL_PROMPT=0 git clone "$CLAWHUB_REPO_URL" "$CLAWHUB_DIR"
    cd "$CLAWHUB_DIR"
fi

echo -e "${BLUE}Installiere Abhängigkeiten für Clawhub...${NC}"
check_npm_registry "$PNPM_REGISTRY_URL"

if project_prefers_bun; then
    ensure_bun_runtime
    if [ -d "node_modules/.pnpm" ]; then
        echo -e "${YELLOW}Hinweis: Vorheriger pnpm-Installationsrest erkannt. Räume node_modules für Bun neu auf...${NC}"
        rm -rf node_modules
    fi
    if ! run_bun_install; then
        echo -e "${RED}Fehler: bun install für Clawhub fehlgeschlagen.${NC}"
        exit 1
    fi
else
    ensure_pnpm_workspace_file
    require_command pnpm "Bitte pnpm installieren oder via Corepack aktivieren, z. B. 'corepack enable && corepack prepare pnpm@latest --activate'."
    if ! run_pnpm_install; then
        echo -e "${RED}Fehler: pnpm install für Clawhub fehlgeschlagen.${NC}"
        echo -e "${YELLOW}Wenn ERR_PNPM_WORKSPACE_PKG_NOT_FOUND erscheint, ist das Upstream-Workspace-Layout inkonsistent oder unvollständig.${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}Baue Clawhub...${NC}"
export VITE_CONVEX_URL="${VITE_CONVEX_URL:-https://example.invalid}"
export VITE_CONVEX_SITE_URL="${VITE_CONVEX_SITE_URL:-https://example.invalid}"

if project_prefers_bun; then
    if ! bun run build; then
        echo -e "${RED}Fehler: bun run build für Clawhub fehlgeschlagen.${NC}"
        echo -e "${YELLOW}Hinweis: Clawhub ist ein aktives Upstream-Projekt. Falls der Build externe Convex-/Vite-Konfiguration erwartet, pruefe README und .env.local.example im Clawhub-Repo.${NC}"
        exit 1
    fi
else
    if ! pnpm build; then
        echo -e "${RED}Fehler: pnpm build für Clawhub fehlgeschlagen.${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Hinweis: Clawhub Konfiguration (z.B. Convex, Datenbank, API-Keys) und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig ist Clawhub ein Entwicklungs-/Webprojekt. Bitte nicht ungeschützt öffentlich freigeben.${NC}"

echo -e "${GREEN}Clawhub Installation abgeschlossen.${NC}"
mark_current_tool_installed
