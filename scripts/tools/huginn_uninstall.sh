#!/bin/bash
# ==============================================================================
# HUGINN_UNINSTALL.SH - Deinstallation von Huginn
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

HUGINN_DIR="/opt/huginn"

echo -e "${BLUE}Starte Deinstallation von Huginn...${NC}"

if [ -d "$HUGINN_DIR" ]; then
    echo -e "${YELLOW}Lösche Huginn Verzeichnis $HUGINN_DIR...${NC}"
    sudo rm -rf "$HUGINN_DIR"
    echo -e "${GREEN}Huginn erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Huginn ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

# Datenbank-Cleanup (optional und manuell)
echo -e "${YELLOW}Hinweis: Datenbank-Einträge für Huginn müssen eventuell manuell entfernt werden.${NC}"

echo -e "${GREEN}Huginn Deinstallation abgeschlossen.${NC}"
