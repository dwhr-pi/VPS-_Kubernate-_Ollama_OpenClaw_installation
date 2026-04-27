#!/bin/bash
#
# Skript: clawhub_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Clawhub, den zentralen Server für die Orchestrierung und Verwaltung von KI-Agenten.
# Es entfernt das Installationsverzeichnis und alle zugehörigen Dateien. Eventuell eingerichtete Datenbanken oder Dienste müssen manuell bereinigt werden.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn Clawhub über das Tool-Management deinstalliert wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_tool_tracking "Clawhub"

CLAWHUB_DIR="/opt/clawhub"

echo -e "${BLUE}Starte Deinstallation von Clawhub (Server)...${NC}"

# 1. Clawhub Verzeichnis löschen
if [ -d "$CLAWHUB_DIR" ]; then
    echo -e "${YELLOW}Lösche Clawhub Verzeichnis $CLAWHUB_DIR...${NC}"
    sudo rm -rf "$CLAWHUB_DIR"
    echo -e "${GREEN}Clawhub erfolgreich deinstalliert.${NC}"
else
    echo -e "${YELLOW}Clawhub ist nicht installiert oder Verzeichnis nicht gefunden.${NC}"
fi

echo -e "${GREEN}Clawhub Deinstallation abgeschlossen.${NC}"
mark_current_tool_removed

