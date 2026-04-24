#!/bin/bash
#
# Skript: Programmierer_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum Programmierer-Profil gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Programmierer-Profil deinstalliert wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Deinstallation des Programmierer-Profils...${NC}"

# Beispiel: Deinstallation von Huginn (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/huginn_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Huginn als Teil des Programmierer-Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/huginn_uninstall.sh"
else
    echo -e "${YELLOW}Huginn Deinstallationsskript nicht gefunden. Überspringe Huginn Deinstallation.${NC}"
fi

# Beispiel: Deinstallation von Clawhub CLI
if [ -f "$INSTALL_DIR/scripts/tools/clawhub_cli_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Clawhub CLI als Teil des Programmierer-Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/clawhub_cli_uninstall.sh"
else
    echo -e "${YELLOW}Clawhub CLI Deinstallationsskript nicht gefunden. Überspringe Clawhub CLI Deinstallation.${NC}"
fi

# Weitere programmiererspezifische Tools hier deinstallieren

echo -e "${GREEN}Programmierer-Profil Deinstallation abgeschlossen.${NC}"
