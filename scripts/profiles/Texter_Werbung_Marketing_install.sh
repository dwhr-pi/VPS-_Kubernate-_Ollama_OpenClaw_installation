#!/bin/bash
#
# Skript: Texter_Werbung_Marketing_install.sh
# Beschreibung: Dieses Skript installiert Tools und Konfigurationen, die speziell für Texter, Werbefachleute und Marketingexperten nützlich sind.
# Es umfasst Content-Generierungs-Tools, SEO-Analyse-Tools, Social Media Management und KI-gestützte Marketing-Plattformen.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Texter, Werbung & Marketing Profil ausgewählt wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Installation des Texter, Werbung & Marketing Profils...${NC}"

# Beispiel: Installation von n8n (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/n8n_install.sh" ]; then
    echo -e "${BLUE}Installiere n8n als Teil des Texter, Werbung & Marketing Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/n8n_install.sh"
else
    echo -e "${YELLOW}n8n Installationsskript nicht gefunden. Überspringe n8n Installation.${NC}"
fi

# Beispiel: Installation von Activepieces (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/activepieces_install.sh" ]; then
    echo -e "${BLUE}Installiere Activepieces als Teil des Texter, Werbung & Marketing Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/activepieces_install.sh"
else
    echo -e "${YELLOW}Activepieces Installationsskript nicht gefunden. Überspringe Activepieces Installation.${NC}"
fi

# Weitere Texter, Werbung & Marketing spezifische Tools hier hinzufügen
# z.B. Skripte für Content-Management-Systeme, SEO-Tools oder spezialisierte KI-Textgeneratoren

echo -e "${GREEN}Texter, Werbung & Marketing Profil Installation abgeschlossen.${NC}"
