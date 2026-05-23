#!/bin/bash
# ==============================================================================
# ACTIVEPIECES_INSTALL.SH - Installation von Activepieces
# Activepieces ist eine Open-Source-Alternative zu Zapier für Workflow-Automatisierung.
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
init_tool_tracking "Activepieces"

ACTIVEPIECES_DIR="/opt/activepieces"
ACTIVEPIECES_REPO_URL="${ACTIVEPIECES_REPO_URL:-https://github.com/activepieces/activepieces.git}"

echo -e "${BLUE}Starte Installation von Activepieces...${NC}"
echo -e "${YELLOW}Primaerquelle: ${ACTIVEPIECES_REPO_URL}${NC}"

if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git ca-certificates curl build-essential unzip
fi

ensure_node22_for_activepieces() {
    local node_major=""

    if command -v node >/dev/null 2>&1; then
        node_major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || true)"
    fi

    if [ -n "$node_major" ] && [ "$node_major" -ge 22 ] 2>/dev/null; then
        return 0
    fi

    echo -e "${YELLOW}Activepieces benoetigt fuer native Abhaengigkeiten eine moderne Node/V8-Toolchain. Gefunden: Node ${node_major:-nicht vorhanden}. Installiere Node.js 22 als System-Build-Abhaengigkeit.${NC}"
    echo -e "${YELLOW}Hinweis: Activepieces selbst bleibt GitHub-Quelle; Node.js ist hier notwendige Runtime-/Build-Basis.${NC}"

    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Fehler: apt-get fehlt. Bitte Node.js 22 manuell bereitstellen.${NC}"
        return 1
    fi

    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
    hash -r 2>/dev/null || true

    node_major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || true)"
    if [ -z "$node_major" ] || [ "$node_major" -lt 22 ] 2>/dev/null; then
        echo -e "${RED}Fehler: Node.js 22 konnte nicht bereitgestellt werden. Aktuell: $(node --version 2>/dev/null || echo fehlt)${NC}"
        return 1
    fi
}

ensure_node22_for_activepieces || exit 1

install_bun_from_github() {
    local arch
    local bun_zip
    local tmp_dir
    local bun_url

    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)
            bun_zip="bun-linux-x64-baseline.zip"
            ;;
        aarch64|arm64)
            bun_zip="bun-linux-aarch64.zip"
            ;;
        *)
            echo -e "${RED}Fehler: Bun GitHub-Release fuer Architektur '$arch' ist im Installer nicht hinterlegt.${NC}"
            return 1
            ;;
    esac

    bun_url="https://github.com/oven-sh/bun/releases/latest/download/${bun_zip}"
    tmp_dir="$(mktemp -d)"
    echo -e "${YELLOW}Bun fehlt. Installiere Bun als Build-Werkzeug aus GitHub-Release:${NC} $bun_url"
    curl -fsSL "$bun_url" -o "$tmp_dir/bun.zip"
    unzip -q "$tmp_dir/bun.zip" -d "$tmp_dir"
    sudo mkdir -p /opt/bun
    sudo cp "$tmp_dir"/*/bun /opt/bun/bun
    sudo chmod 0755 /opt/bun/bun
    sudo ln -sf /opt/bun/bun /usr/local/bin/bun
    rm -rf "$tmp_dir"
}

if ! command -v bun >/dev/null 2>&1; then
    install_bun_from_github || {
        echo -e "${RED}Fehler: Bun konnte nicht installiert werden. Activepieces verlangt laut Upstream Bun.${NC}"
        exit 1
    }
fi

clone_activepieces() {
    rm -rf "$ACTIVEPIECES_DIR"
    echo -e "${BLUE}Klone Activepieces in $ACTIVEPIECES_DIR...${NC}"
    if git clone --depth 1 --filter=blob:none "$ACTIVEPIECES_REPO_URL" "$ACTIVEPIECES_DIR"; then
        return 0
    fi

    echo -e "${YELLOW}Erster Clone-Versuch fehlgeschlagen. Versuche erneut mit HTTP/1.1 gegen HTTP/2-Abbrueche...${NC}"
    rm -rf "$ACTIVEPIECES_DIR"
    git -c http.version=HTTP/1.1 clone --depth 1 --filter=blob:none "$ACTIVEPIECES_REPO_URL" "$ACTIVEPIECES_DIR"
}

# 1. Activepieces aus GitHub klonen
sudo mkdir -p "$(dirname "$ACTIVEPIECES_DIR")"
sudo chown -R "$USER:$USER" "$(dirname "$ACTIVEPIECES_DIR")"

if [ -d "$ACTIVEPIECES_DIR/.git" ]; then
    echo -e "${YELLOW}Activepieces Verzeichnis $ACTIVEPIECES_DIR existiert bereits. Aktualisiere Repository...${NC}"
    if ! git -C "$ACTIVEPIECES_DIR" pull --ff-only; then
        echo -e "${RED}Fehler: Activepieces Repository konnte nicht aktualisiert werden.${NC}"
        echo -e "${YELLOW}Bitte lokale Aenderungen pruefen oder Activepieces deinstallieren und neu installieren.${NC}"
        exit 1
    fi
elif [ -e "$ACTIVEPIECES_DIR" ]; then
    echo -e "${YELLOW}Vorhandenes Activepieces-Verzeichnis ist kein vollstaendiger Git-Clone. Raeume unvollstaendige Installation auf...${NC}"
    clone_activepieces || {
        echo -e "${RED}Fehler: GitHub-Clone von Activepieces ist fehlgeschlagen.${NC}"
        rm -rf "$ACTIVEPIECES_DIR"
        exit 1
    }
else
    clone_activepieces || {
        echo -e "${RED}Fehler: GitHub-Clone von Activepieces ist fehlgeschlagen.${NC}"
        rm -rf "$ACTIVEPIECES_DIR"
        exit 1
    }
fi

cd "$ACTIVEPIECES_DIR"
if [ ! -f package.json ]; then
    echo -e "${RED}Fehler: Activepieces-Clone ist unvollstaendig, package.json fehlt in $ACTIVEPIECES_DIR.${NC}"
    echo -e "${YELLOW}pnpm wird bewusst nicht gestartet, damit der eigentliche Git-Fehler sichtbar bleibt.${NC}"
    exit 1
fi

export NPM_TOKEN="${NPM_TOKEN:-}"

# 2. Abhängigkeiten installieren mit Bun
echo -e "${BLUE}Installiere Abhängigkeiten für Activepieces mit Bun...${NC}"
if ! bun install; then
    echo -e "${RED}Fehler: bun install für Activepieces fehlgeschlagen.${NC}"
    exit 1
fi

# 3. Activepieces bauen
echo -e "${BLUE}Baue Activepieces mit Bun...${NC}"
if node -e 'const scripts=require("./package.json").scripts||{}; process.exit(Object.prototype.hasOwnProperty.call(scripts,"build") ? 0 : 1)' >/dev/null 2>&1; then
    if ! bun run build; then
        echo -e "${RED}Fehler: bun run build für Activepieces fehlgeschlagen.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Hinweis: Der aktuelle Activepieces-Upstream definiert keinen root-build Script in package.json.${NC}"
    echo -e "${YELLOW}Abhaengigkeiten wurden installiert; Start/Build muss projektbezogen nach Upstream-Dokumentation erfolgen.${NC}"
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: Activepieces Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet Activepieces auf Port 3000.${NC}"

echo -e "${GREEN}Activepieces Installation abgeschlossen.${NC}"
mark_current_tool_installed
