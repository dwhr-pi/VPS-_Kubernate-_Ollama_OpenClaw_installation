#!/bin/bash
# ==============================================================================
# N8N_UNINSTALL.SH - Deinstallation von n8n
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

N8N_DIR="/opt/n8n"

echo -e "${BLUE}Starte Deinstallation von n8n...${NC}"

if [ -d "$N8N_DIR" ]; then
    echo -e "${YELLOW}Lösche n8n Verzeichnis $N8N_DIR...${NC}"
    sudo rm -rf "$N8N_DIR"
    echo -e "${GREEN}n8n erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}n8n ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}n8n Deinstallation abgeschlossen.${NC}"
