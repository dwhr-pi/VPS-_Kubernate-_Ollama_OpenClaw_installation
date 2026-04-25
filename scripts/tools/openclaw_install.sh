#!/bin/bash
# ==============================================================================
# OPENCLAW_INSTALL.SH - Installation von OpenClaw
# OpenClaw ist ein KI-Agenten-Framework mit Reinforcement Learning (RL) und
# Skill-Integration (z.B. gcali).
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

OPENCLAW_DIR="/opt/openclaw"

echo -e "${BLUE}Starte Installation von OpenClaw...${NC}"

# 1. OpenClaw aus GitHub klonen
if [ -d "$OPENCLAW_DIR" ]; then
    echo -e "${YELLOW}OpenClaw Verzeichnis $OPENCLAW_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$OPENCLAW_DIR"
    git pull
else
    echo -e "${BLUE}Klone OpenClaw in $OPENCLAW_DIR...${NC}"
    sudo mkdir -p "$OPENCLAW_DIR"
    sudo chown -R $USER:$USER "$OPENCLAW_DIR"
    git clone https://github.com/openclaw/openclaw.git "$OPENCLAW_DIR"
    cd "$OPENCLAW_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für OpenClaw mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für OpenClaw fehlgeschlagen.${NC}"
    exit 1
fi

# 3. OpenClaw bauen
echo -e "${BLUE}Baue OpenClaw mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für OpenClaw fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration (Platzhalter)
echo -e "${YELLOW}Hinweis: OpenClaw Konfiguration muss eventuell manuell angepasst werden (z.B. API-Keys, Skills).${NC}"

echo -e "${GREEN}OpenClaw Installation abgeschlossen.${NC}"
