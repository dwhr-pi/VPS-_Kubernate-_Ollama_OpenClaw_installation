#!/bin/bash
#
# Skript: Texter_Werbung_Marketing_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum Texter, Werbung & Marketing Profil gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Texter, Werbung & Marketing Profil deinstalliert wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Deinstallation des Texter, Werbung & Marketing Profils...${NC}"

# Beispiel: Deinstallation von n8n (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/n8n_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere n8n als Teil des Texter, Werbung & Marketing Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/n8n_uninstall.sh"
else
    echo -e "${YELLOW}n8n Deinstallationsskript nicht gefunden. Überspringe n8n Deinstallation.${NC}"
fi

# Beispiel: Deinstallation von Activepieces (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/activepieces_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Activepieces als Teil des Texter, Werbung & Marketing Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/activepieces_uninstall.sh"
else
    echo -e "${YELLOW}Activepieces Deinstallationsskript nicht gefunden. Überspringe Activepieces Deinstallation.${NC}"
fi

# Weitere Texter, Werbung & Marketing spezifische Tools hier deinstallieren

echo -e "${GREEN}Texter, Werbung & Marketing Profil Deinstallation abgeschlossen.${NC}"
