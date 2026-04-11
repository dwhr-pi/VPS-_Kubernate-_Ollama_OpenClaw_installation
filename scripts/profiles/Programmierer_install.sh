#!/bin/bash
# ==============================================================================
# Programmierer_install.sh - Installationsskript für das Programmierer-Profil
# ==============================================================================

GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Installiere Programmierer-Profil...${NC}"

# Beispiel: Ollama Modell für Code-Generierung herunterladen
echo -e "${GREEN}Lade Ollama Modell 'deepseek-coder:6.7b' herunter...${NC}"
ollama pull deepseek-coder:6.7b

# Beispiel: Build-Tools installieren
echo -e "${GREEN}Installiere Build-Tools (build-essential)...${NC}"
sudo apt install -y build-essential

# Beispiel: Weitere Programmierer-Tools oder Konfigurationen
echo -e "${YELLOW}Hinweis: Hier können weitere Programmierer-Tools oder Konfigurationen hinzugefügt werden.${NC}"

echo -e "${GREEN}Programmierer-Profil Installation abgeschlossen.${NC}"
