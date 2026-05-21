#!/bin/bash
# ==============================================================================
# GBOX_INSTALL.SH - GitHub-basierte Integration von babelcloud/gbox
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
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/lib/common.sh"

TOOL_KEY="GBOX"
GBOX_DIR="${GBOX_DIR:-/opt/gbox}"
GBOX_REPO_URL="$(get_custom_repo_url "GBOX" "https://github.com/babelcloud/gbox.git")"
GBOX_BUILD_FROM_SOURCE="${GBOX_BUILD_FROM_SOURCE:-0}"
GBOX_RUN_SETUP="${GBOX_RUN_SETUP:-0}"

init_tool_tracking "$TOOL_KEY"

echo -e "${BLUE}Starte Installation von GBOX...${NC}"
echo -e "${BLUE}Quelle: ${GBOX_REPO_URL}${NC}"
echo -e "${YELLOW}Hinweis: Dieses Setup nutzt die GitHub-Quelle. npm/Homebrew-Fertigpakete werden hier nicht installiert.${NC}"

if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}Fehler: git ist erforderlich, um GBOX aus GitHub zu klonen.${NC}"
    exit 1
fi

if [ -d "$GBOX_DIR/.git" ]; then
    echo -e "${YELLOW}GBOX-Verzeichnis existiert bereits. Aktualisiere per git pull --ff-only...${NC}"
    git -C "$GBOX_DIR" pull --ff-only
else
    sudo mkdir -p "$GBOX_DIR"
    sudo chown -R "$USER:$USER" "$GBOX_DIR"
    git clone "$GBOX_REPO_URL" "$GBOX_DIR"
fi

cat > "$GBOX_DIR/ULTIMATE_KI_SETUP_NOTES.md" <<'EOF'
# GBOX im Ultimate KI Setup

GBOX ist als GitHub-Source-Integration fuer Android-, Browser-/Desktop- und MCP-nahe Agenten-Workflows vorgesehen.

Empfohlene Profile:

- `Android_App_Builder`
- `MCP_Agent_Tools`
- `Browser_Automation_Agent`
- `Local_AI_App_Builder`

Wichtige Sicherheitsregel:

- GBOX kann Agenten Zugriff auf Android-/Desktop-/Browser-Umgebungen geben.
- Nutze es zuerst mit Testgeraeten, Testkonten und lokalen Projekten.
- Login zu externen GBOX-/Cloud-Umgebungen nur bewusst und nie mit produktiven Zugangsdaten ohne Kostenlimit.
- MCP-Zugriff nicht offen ins Netzwerk stellen.

Source-Build:

```bash
GBOX_BUILD_FROM_SOURCE=1 bash scripts/tools/gbox_install.sh
```
EOF

if [ "$GBOX_BUILD_FROM_SOURCE" = "1" ]; then
    echo -e "${BLUE}Baue GBOX aus Source...${NC}"

    for cmd in go make node corepack; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}Fehler: ${cmd} fehlt. Installiere Build-Abhaengigkeiten bewusst und starte erneut.${NC}"
            echo -e "${YELLOW}Erwartet laut Upstream: Go 1.21+, make, Node.js 16.13+, pnpm via corepack.${NC}"
            exit 1
        fi
    done

    (
        cd "$GBOX_DIR"
        corepack enable
        make build
    )
else
    echo -e "${YELLOW}Source-Build uebersprungen. Setze GBOX_BUILD_FROM_SOURCE=1, um `make build` auszufuehren.${NC}"
fi

if [ "$GBOX_RUN_SETUP" = "1" ]; then
    if command -v gbox >/dev/null 2>&1; then
        echo -e "${BLUE}Fuehre gbox setup -y aus...${NC}"
        gbox setup -y
    else
        echo -e "${YELLOW}gbox liegt noch nicht als Befehl im PATH. GBOX_RUN_SETUP wurde uebersprungen.${NC}"
    fi
fi

mark_current_tool_installed
echo -e "${GREEN}GBOX wurde vorbereitet unter: ${GBOX_DIR}${NC}"
echo -e "${YELLOW}Naechster Schritt fuer myBox: docs/myBOX_GBOX_INTEGRATION.md lesen und erst mit Testgeraet/Testkonto starten.${NC}"
