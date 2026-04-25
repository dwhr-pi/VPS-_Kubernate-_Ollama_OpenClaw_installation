#!/bin/bash
# ==============================================================================
# OPENCLAW_RL_UNINSTALL.SH - Deinstallation von OpenClaw RL
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
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
