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

echo -e "${BLUE}Starte Installation von OpenClaw RL...${NC}"

# 1. OpenClaw RL aus GitHub klonen
if [ -d "$OPENCLAW_RL_DIR" ]; then
    echo -e "${YELLOW}OpenClaw RL Verzeichnis $OPENCLAW_RL_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$OPENCLAW_RL_DIR"
    git pull
else
    echo -e "${BLUE}Klone OpenClaw RL in $OPENCLAW_RL_DIR...${NC}"
    sudo mkdir -p "$OPENCLAW_RL_DIR"
    sudo chown -R $USER:$USER "$OPENCLAW_RL_DIR"
    git clone https://github.com/openclaw/openclaw-rl.git "$OPENCLAW_RL_DIR"
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
