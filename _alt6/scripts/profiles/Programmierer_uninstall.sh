#!/bin/bash
# ==============================================================================
# Programmierer_uninstall.sh - Deinstallationsskript für das Programmierer-Profil
# ==============================================================================

GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Deinstalliere Programmierer-Profil...${NC}"

# Beispiel: Ollama Modell entfernen (optional, da Modelle groß sein können)
# echo -e "${GREEN}Entferne Ollama Modell 'deepseek-coder:6.7b'...${NC}"
# ollama rm deepseek-coder:6.7b

# Beispiel: Build-Tools deinstallieren (nur wenn sie nicht von anderen Profilen benötigt werden)
# echo -e "${GREEN}Deinstalliere Build-Tools (build-essential)...${NC}"
# sudo apt remove -y build-essential

echo -e "${YELLOW}Hinweis: Die Deinstallation von Profilen ist oft komplex, da Abhängigkeiten geteilt werden können.${NC}"
echo -e "${YELLOW}Bitte prüfen Sie manuell, ob alle Komponenten entfernt wurden, die nicht mehr benötigt werden.${NC}"

echo -e "${GREEN}Programmierer-Profil Deinstallation abgeschlossen.${NC}"
