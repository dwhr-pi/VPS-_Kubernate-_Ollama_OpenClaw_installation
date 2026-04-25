#!/bin/bash
# ==============================================================================
# PIPEDREAM_UNINSTALL.SH - Deinstallation von Pipedream (Self-Hosted)
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

PIPEDREAM_DIR="/opt/pipedream"

echo -e "${BLUE}Starte Deinstallation von Pipedream (Self-Hosted)...${NC}"

if [ -d "$PIPEDREAM_DIR" ]; then
    echo -e "${YELLOW}Lösche Pipedream Verzeichnis $PIPEDREAM_DIR...${NC}"
    sudo rm -rf "$PIPEDREAM_DIR"
    echo -e "${GREEN}Pipedream erfolgreich deinstalliert (falls lokal geklont).${NC}"
else
    echo -e "${YELLOW}Pipedream ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${YELLOW}Hinweis: Wenn Pipedream über Docker/Kubernetes installiert wurde, müssen Sie die entsprechenden Container/Pods/Deployments manuell entfernen.${NC}"

echo -e "${GREEN}Pipedream Deinstallation abgeschlossen.${NC}"
