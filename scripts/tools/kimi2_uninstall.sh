#!/bin/bash
# ==============================================================================
# KIMI2_UNINSTALL.SH - Deinstalliert Kimi 2 (Moonshot AI)
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

KIMI2_DIR="/opt/kimi2"

echo -e "${BLUE}Starte Deinstallation von Kimi 2...${NC}"

# Prüfen, ob Kimi 2 installiert ist
if [ ! -d "$KIMI2_DIR" ]; then
    echo -e "${YELLOW}Kimi 2 ist nicht installiert unter ${KIMI2_DIR}. Überspringe Deinstallation.${NC}"
    exit 0
fi

# Installationsverzeichnis entfernen
echo -e "${BLUE}Entferne Kimi 2 Installationsverzeichnis: ${KIMI2_DIR}${NC}"
sudo rm -rf "$KIMI2_DIR"
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler beim Entfernen des Kimi 2 Installationsverzeichnisses.${NC}"
    exit 1
fi

echo -e "${GREEN}Kimi 2 erfolgreich deinstalliert.${NC}"
