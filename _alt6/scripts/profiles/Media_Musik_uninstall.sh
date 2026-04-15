#!/bin/bash
# ==============================================================================
# Media_Musik_uninstall.sh - Deinstallationsskript für das Media & Musik Profil
# ==============================================================================

GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Deinstalliere Media & Musik Profil...${NC}"

# Beispiel: FFmpeg deinstallieren (nur wenn es nicht von anderen Profilen benötigt wird)
# echo -e "${GREEN}Deinstalliere FFmpeg...${NC}"
# sudo apt remove -y ffmpeg

echo -e "${YELLOW}Hinweis: Die Deinstallation von Profilen ist oft komplex, da Abhängigkeiten geteilt werden können.${NC}"
echo -e "${YELLOW}Bitte prüfen Sie manuell, ob alle Komponenten entfernt wurden, die nicht mehr benötigt werden.${NC}"

echo -e "${GREEN}Media & Musik Profil Deinstallation abgeschlossen.${NC}"
