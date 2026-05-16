#!/bin/bash
# ==============================================================================
# CLAWBAKE_INSTALL.SH - Installation von Clawbake
# Clawbake ist ein Tool zur Automatisierung von Builds und Deployments.
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
init_tool_tracking "Clawbake"

CLAWBAKE_DIR="/opt/clawbake"
CLAWBAKE_REPO_URL="${CLAWBAKE_REPO_URL:-https://github.com/NeurometricAI/clawbake.git}"
CLAWBAKE_SKIP_BUILD="${CLAWBAKE_SKIP_BUILD:-false}"

clone_clawbake_repo() {
    local target_dir="$1"

    sudo rm -rf "$target_dir"
    sudo mkdir -p "$target_dir"
    sudo chown -R "$USER:$USER" "$target_dir"
    git clone "$CLAWBAKE_REPO_URL" "$target_dir"
    sudo chown -R "$USER:$USER" "$target_dir"
}

echo -e "${BLUE}Starte Installation von Clawbake...${NC}"
echo -e "${BLUE}Clawbake Quelle: ${CLAWBAKE_REPO_URL}${NC}"
echo -e "${YELLOW}Hinweis: Clawbake ist ein Kubernetes-/OpenClaw-Operator-Projekt. Fuer produktive Nutzung werden Go, Docker/K3s und spaeter Helm-Werte/OIDC-Secrets benoetigt.${NC}"

if ! git ls-remote "$CLAWBAKE_REPO_URL" HEAD >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Clawbake Repository nicht erreichbar: ${CLAWBAKE_REPO_URL}${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf CLAWBAKE_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

# 1. Clawbake aus GitHub klonen
if [ -d "$CLAWBAKE_DIR" ]; then
    if [ -d "$CLAWBAKE_DIR/.git" ]; then
        echo -e "${YELLOW}Clawbake Verzeichnis $CLAWBAKE_DIR existiert bereits. Aktualisiere Repository...${NC}"
        cd "$CLAWBAKE_DIR"
        current_remote="$(git remote get-url origin 2>/dev/null || true)"
        if [ "$current_remote" != "$CLAWBAKE_REPO_URL" ]; then
            backup_dir="${CLAWBAKE_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "${YELLOW}Bestehende Clawbake-Quelle weicht ab: ${current_remote}${NC}"
            echo -e "${YELLOW}Sichere bestehendes Verzeichnis nach ${backup_dir} und klone die neue Quelle.${NC}"
            cd /
            sudo mv "$CLAWBAKE_DIR" "$backup_dir"
            clone_clawbake_repo "$CLAWBAKE_DIR"
            cd "$CLAWBAKE_DIR"
        else
            git pull --ff-only
        fi
    else
        backup_dir="${CLAWBAKE_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Clawbake-Verzeichnis existiert, ist aber kein Git-Repo. Sichere nach ${backup_dir}.${NC}"
        sudo mv "$CLAWBAKE_DIR" "$backup_dir"
        clone_clawbake_repo "$CLAWBAKE_DIR"
        cd "$CLAWBAKE_DIR"
    fi
else
    echo -e "${BLUE}Klone Clawbake in $CLAWBAKE_DIR...${NC}"
    clone_clawbake_repo "$CLAWBAKE_DIR"
    cd "$CLAWBAKE_DIR"
fi

echo -e "${BLUE}Clawbake Git-Stand:${NC}"
git --no-pager log -1 --oneline || true

# 2. Abhängigkeiten prüfen
if ! command -v go >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Go ist nicht verfügbar. Clawbake benötigt laut Upstream Go 1.25+ für lokale Builds.${NC}"
    echo -e "${YELLOW}Installieren Sie eine passende Go-Version oder nutzen Sie später den Helm/OCI-Deployment-Pfad aus der Clawbake-Doku.${NC}"
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo -e "${RED}Fehler: make ist nicht verfügbar.${NC}"
    exit 1
fi

# 3. Clawbake bauen
if [ "$CLAWBAKE_SKIP_BUILD" = "true" ]; then
    echo -e "${YELLOW}CLAWBAKE_SKIP_BUILD=true gesetzt. Build wird uebersprungen; Repository ist vorbereitet.${NC}"
else
    echo -e "${BLUE}Baue Clawbake mit make build...${NC}"
    if ! make build; then
        echo -e "${RED}Fehler: make build für Clawbake fehlgeschlagen.${NC}"
        echo -e "${YELLOW}Hinweis: Upstream nennt Go 1.25+, Docker, k3d und mise als Entwicklungsabhängigkeiten. Prüfen Sie docs/development.md im Clawbake-Repo.${NC}"
        exit 1
    fi
fi

# 4. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: Clawbake braucht für echten Betrieb Kubernetes, PostgreSQL/OIDC-Secrets und Helm-/Values-Konfiguration. Keine Secrets ins Repo schreiben.${NC}"

echo -e "${GREEN}Clawbake Installation abgeschlossen.${NC}"
mark_current_tool_installed
