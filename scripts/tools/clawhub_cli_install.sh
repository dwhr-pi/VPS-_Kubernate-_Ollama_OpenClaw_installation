#!/bin/bash
# ==============================================================================
# CLAWHUB_CLI_INSTALL.SH - Installation von Clawhub CLI
# Clawhub CLI ist ein Kommandozeilen-Tool zur Interaktion mit Clawhub-Diensten.
# ==============================================================================

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Clawhub_CLI"

CLAWHUB_CLI_DIR="/opt/clawhub-cli"
PNPM_REGISTRY_URL="${PNPM_REGISTRY_URL:-https://registry.npmjs.org}"
CLAWHUB_CLI_REPOS=(
    "${CLAWHUB_CLI_REPO_URL:-}"
    "https://github.com/openclaw/clawhub-cli.git"
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
        if curl -fsSI --connect-timeout 10 --max-time 20 "$url/pnpm" >/dev/null 2>&1; then
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q --spider --timeout=20 "$url/pnpm"; then
            return 0
        fi
    else
        echo -e "${YELLOW}Hinweis: Weder curl noch wget gefunden, Registry-Preflight wird übersprungen.${NC}"
        return 0
    fi

    echo -e "${RED}Fehler: Die npm-Registry unter $url ist derzeit nicht zuverlässig erreichbar.${NC}"
    echo -e "${YELLOW}Typische Ursachen: DNS-Probleme, Proxy/Firewall, temporäre Paket-Registry-Störung oder instabile Internetverbindung.${NC}"
    echo -e "${YELLOW}Bitte prüfen Sie insbesondere ERR_SOCKET_TIMEOUT, ECONNRESET und EAI_AGAIN im Installationslog.${NC}"
    exit 1
}

project_prefers_bun() {
    [ -f "package.json" ] || return 1

    if grep -q 'only-allow bun' package.json 2>/dev/null; then
        return 0
    fi

    [ -f "bun.lockb" ] || [ -f "bun.lock" ]
}

ensure_bun_runtime() {
    export PATH="$HOME/.bun/bin:$PATH"

    if command -v bun >/dev/null 2>&1 && command -v bunx >/dev/null 2>&1; then
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}Fehler: Dieses Repository benötigt bun, aber curl zum Installieren fehlt.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Hinweis: package.json erzwingt bun als Paketmanager. Installiere bun für den aktuellen Benutzer...${NC}"
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

if (!workspaces.length) {
  process.exit(1);
}

const body = "packages:\n" + workspaces.map((entry) => `  - '${String(entry).replace(/'/g, "''")}'`).join("\n") + "\n";
fs.writeFileSync("pnpm-workspace.yaml", body, "utf8");
process.stdout.write("pnpm-workspace.yaml wurde aus package.json/workspaces erzeugt.");
NODE
    then
        echo -e "${YELLOW}Hinweis: package.json nutzt Workspaces, aber pnpm-workspace.yaml fehlte.${NC}"
        cat /tmp/clawhub-pnpm-workspace.log
        return 0
    fi

    return 0
}

run_bun_install() {
    local attempt

    for attempt in 1 2 3; do
        echo -e "${BLUE}bun install Versuch ${attempt}/3...${NC}"
        if bun install; then
            return 0
        fi

        if [ "$attempt" -lt 3 ]; then
            echo -e "${YELLOW}bun install fehlgeschlagen. Neuer Versuch in 15 Sekunden...${NC}"
            sleep 15
        fi
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

        if [ "$attempt" -lt 3 ]; then
            echo -e "${YELLOW}pnpm install fehlgeschlagen. Neuer Versuch in 15 Sekunden...${NC}"
            sleep 15
        fi
    done

    return 1
}

echo -e "${BLUE}Starte Installation von Clawhub CLI...${NC}"

require_command git "Bitte git installieren und das Skript erneut starten."

CLAWHUB_CLI_REPO_URL=""
for repo in "${CLAWHUB_CLI_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if GIT_TERMINAL_PROMPT=0 git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        CLAWHUB_CLI_REPO_URL="$repo"
        break
    fi
done

if [ -z "$CLAWHUB_CLI_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares Clawhub CLI/Clawhub Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden openclaw/clawhub-cli, openclaw/clawhub und dwhr-pi/clawhub.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf CLAWHUB_CLI_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

# 1. Clawhub CLI aus GitHub klonen
if [ -d "$CLAWHUB_CLI_DIR" ]; then
    echo -e "${YELLOW}Clawhub CLI Verzeichnis $CLAWHUB_CLI_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$CLAWHUB_CLI_DIR"
    GIT_TERMINAL_PROMPT=0 git pull --ff-only
else
    echo -e "${BLUE}Klone Clawhub CLI in $CLAWHUB_CLI_DIR...${NC}"
    sudo mkdir -p "$CLAWHUB_CLI_DIR"
    sudo chown -R "$USER:$USER" "$CLAWHUB_CLI_DIR"
    GIT_TERMINAL_PROMPT=0 git clone "$CLAWHUB_CLI_REPO_URL" "$CLAWHUB_CLI_DIR"
    cd "$CLAWHUB_CLI_DIR"
fi

# 2. Abhängigkeiten installieren
echo -e "${BLUE}Installiere Abhängigkeiten für Clawhub CLI...${NC}"
check_npm_registry "$PNPM_REGISTRY_URL"
ensure_pnpm_workspace_file

if project_prefers_bun; then
    ensure_bun_runtime
    if ! run_bun_install; then
        echo -e "${RED}Fehler: bun install für Clawhub CLI fehlgeschlagen.${NC}"
        exit 1
    fi
else
    require_command pnpm "Bitte pnpm installieren oder via Corepack aktivieren, z. B. 'corepack enable && corepack prepare pnpm@latest --activate'."
    if ! run_pnpm_install; then
        echo -e "${RED}Fehler: pnpm install für Clawhub CLI fehlgeschlagen.${NC}"
        echo -e "${YELLOW}Wenn weiterhin ERR_SOCKET_TIMEOUT, ECONNRESET oder EAI_AGAIN auftreten, liegt das sehr wahrscheinlich an Netzwerk, DNS, Proxy oder npm-Registry-Erreichbarkeit.${NC}"
        echo -e "${YELLOW}Wenn nur die Workspace-Warnung bleibt, prüfen Sie das Repo-Layout oder hinterlegen Sie dauerhaft eine pnpm-workspace.yaml im Upstream-Repository.${NC}"
        exit 1
    fi
fi

# 3. Clawhub CLI bauen
if project_prefers_bun; then
    echo -e "${BLUE}Baue Clawhub CLI mit bun...${NC}"
    if ! bun run build; then
        echo -e "${RED}Fehler: bun run build für Clawhub CLI fehlgeschlagen.${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}Baue Clawhub CLI mit pnpm...${NC}"
    if ! pnpm build; then
        echo -e "${RED}Fehler: pnpm build für Clawhub CLI fehlgeschlagen.${NC}"
        exit 1
    fi
fi

# 4. Verknüpfung erstellen (optional)
echo -e "${BLUE}Erstelle symbolische Verknüpfung für einfachen Zugriff...${NC}"
if [ -f "$CLAWHUB_CLI_DIR/bin/run" ]; then
    sudo ln -sf "$CLAWHUB_CLI_DIR/bin/run" /usr/local/bin/clawhub
else
    echo -e "${YELLOW}Hinweis: Kein dediziertes CLI-Binary unter bin/run gefunden. Möglicherweise ist die CLI bereits in Clawhub integriert.${NC}"
fi

echo -e "${GREEN}Clawhub CLI Installation abgeschlossen. Du kannst es jetzt mit 'clawhub' aufrufen.${NC}"
mark_current_tool_installed
