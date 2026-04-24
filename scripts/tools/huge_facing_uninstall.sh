#!/bin/bash
#
# Skript: huge_facing_uninstall.sh
# Beschreibung: Dieses Skript entfernt die Konfigurationen und Hinweise zur Nutzung von Hugging Face Modellen.
# Da Hugging Face keine direkt installierbare Software ist, werden hier primär die Konfigurationen und Verweise entfernt.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn 'Huge Facing' über das Tool-Management deinstalliert wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Deinstallation der Hugging Face (Huge Facing) Integration...${NC}"

echo -e "${YELLOW}Hugging Face ist eine Plattform und keine direkt installierte Software. Es gibt keine spezifische Software zu deinstallieren.${NC}"
echo -e "${YELLOW}Dieses Skript entfernt lediglich die Konfigurationshinweise und Verweise auf Hugging Face aus dem Setup.${NC}"

# Hier könnten Skripte stehen, die spezifische Konfigurationen in anderen Tools entfernen,
# die auf Hugging Face verweisen. Da dies sehr anwendungsspezifisch ist,
# wird hier nur ein allgemeiner Hinweis gegeben.

echo -e "${GREEN}Hugging Face Integration Deinstallation abgeschlossen. Bitte prüfe manuelle Konfigurationen in anderen Tools.${NC}"
