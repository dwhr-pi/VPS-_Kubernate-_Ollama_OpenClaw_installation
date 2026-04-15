#!/bin/bash
# ==============================================================================
# LANGFLOW_UNINSTALL.SH - Deinstallation von LangFlow
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

LANGFLOW_DIR="/opt/langflow"

echo -e "${BLUE}Starte Deinstallation von LangFlow...${NC}"

if [ -d "$LANGFLOW_DIR" ]; then
    echo -e "${YELLOW}Lösche LangFlow Verzeichnis $LANGFLOW_DIR...${NC}"
    sudo rm -rf "$LANGFLOW_DIR"
    echo -e "${GREEN}LangFlow erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}LangFlow ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}LangFlow Deinstallation abgeschlossen.${NC}"
