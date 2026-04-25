#!/bin/bash
# ==============================================================================
# OPENCLAW_RL_UNINSTALL.SH - Deinstallation von OpenClaw RL
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

OPENCLAW_RL_DIR="/opt/openclaw-rl"

echo -e "${BLUE}Starte Deinstallation von OpenClaw RL...${NC}"

if [ -d "$OPENCLAW_RL_DIR" ]; then
    echo -e "${YELLOW}Lösche OpenClaw RL Verzeichnis $OPENCLAW_RL_DIR...${NC}"
    sudo rm -rf "$OPENCLAW_RL_DIR"
    echo -e "${GREEN}OpenClaw RL erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}OpenClaw RL ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}OpenClaw RL Deinstallation abgeschlossen.${NC}"
