#!/bin/bash
# ==============================================================================
# AUTOGPT_UNINSTALL.SH - Deinstallation von AutoGPT
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

AUTOGPT_DIR="/opt/autogpt"
AUTOGPT_PLATFORM_DIR="$AUTOGPT_DIR/autogpt_platform"

echo -e "${BLUE}Starte Deinstallation von AutoGPT...${NC}"

if [ -d "$AUTOGPT_PLATFORM_DIR" ] && command -v docker >/dev/null 2>&1; then
    echo -e "${BLUE}Stoppe laufende AutoGPT Container...${NC}"
    cd "$AUTOGPT_PLATFORM_DIR"
    sudo docker compose down --remove-orphans >/dev/null 2>&1 || true
fi

if [ -d "$AUTOGPT_DIR" ]; then
    echo -e "${YELLOW}Lösche AutoGPT Verzeichnis $AUTOGPT_DIR...${NC}"
    sudo rm -rf "$AUTOGPT_DIR"
    echo -e "${GREEN}AutoGPT erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}AutoGPT ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}AutoGPT Deinstallation abgeschlossen.${NC}"
