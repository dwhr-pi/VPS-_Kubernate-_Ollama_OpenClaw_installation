#!/bin/bash
#
# Skript: Media_Musik_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum Media & Musik Profil gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Media & Musik Profil deinstalliert wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Deinstallation des Media & Musik Profils...${NC}"

# Beispiel: Deinstallation von Clawbake (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/clawbake_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Clawbake als Teil des Media & Musik Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/clawbake_uninstall.sh"
else
    echo -e "${YELLOW}Clawbake Deinstallationsskript nicht gefunden. Überspringe Clawbake Deinstallation.${NC}"
fi

# Weitere medien- und musikspezifische Tools hier deinstallieren

echo -e "${GREEN}Media & Musik Profil Deinstallation abgeschlossen.${NC}"
