#!/bin/bash
# ==============================================================================
# OPENCLAW_RL_INSTALL.SH - Installation von OpenClaw RL
# OpenClaw RL ist die Reinforcement Learning Erweiterung für OpenClaw.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

OPENCLAW_RL_DIR="/opt/openclaw-rl"
OPENCLAW_RL_REPOS=(
    "${OPENCLAW_RL_REPO_URL:-}"
    "https://github.com/Gen-Verse/OpenClaw-RL.git"
    "https://github.com/dwhr-pi/OpenClaw-RL.git"
)

echo -e "${BLUE}Starte Installation von OpenClaw RL...${NC}"

OPENCLAW_RL_REPO_URL=""
for repo in "${OPENCLAW_RL_REPOS[@]}"; do
    [ -z "$repo" ] && continue
    if git ls-remote "$repo" HEAD >/dev/null 2>&1; then
        OPENCLAW_RL_REPO_URL="$repo"
        break
    fi
done

if [ -z "$OPENCLAW_RL_REPO_URL" ]; then
    echo -e "${RED}Fehler: Kein erreichbares OpenClaw RL Repository gefunden.${NC}"
    echo -e "${YELLOW}Geprüft wurden Gen-Verse/OpenClaw-RL und dwhr-pi/OpenClaw-RL.${NC}"
    echo -e "${YELLOW}Setzen Sie bei Bedarf OPENCLAW_RL_REPO_URL auf die korrekte Git-URL und starten Sie das Skript erneut.${NC}"
    exit 1
fi

# 1. OpenClaw RL aus GitHub klonen
if [ -d "$OPENCLAW_RL_DIR" ]; then
    echo -e "${YELLOW}OpenClaw RL Verzeichnis $OPENCLAW_RL_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$OPENCLAW_RL_DIR"
    git pull --ff-only
else
    echo -e "${BLUE}Klone OpenClaw RL in $OPENCLAW_RL_DIR...${NC}"
    sudo mkdir -p "$OPENCLAW_RL_DIR"
    sudo chown -R $USER:$USER "$OPENCLAW_RL_DIR"
    git clone "$OPENCLAW_RL_REPO_URL" "$OPENCLAW_RL_DIR"
    cd "$OPENCLAW_RL_DIR"
fi

# 2. Python-Abhängigkeiten installieren
echo -e "${BLUE}Installiere Python-Abhängigkeiten für OpenClaw RL...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

# 3. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: OpenClaw RL Konfiguration muss eventuell manuell angepasst werden.${NC}"

echo -e "${GREEN}OpenClaw RL Installation abgeschlossen.${NC}"
