#!/bin/bash
# ==============================================================================
# N8N_INSTALL.SH - Installation von n8n
# n8n ist ein Workflow-Automatisierungstool, das viele Apps und Dienste verbindet.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

N8N_DIR="/opt/n8n"

echo -e "${BLUE}Starte Installation von n8n...${NC}"

# 1. n8n aus GitHub klonen
if [ -d "$N8N_DIR" ]; then
    echo -e "${YELLOW}n8n Verzeichnis $N8N_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$N8N_DIR"
    git pull
else
    echo -e "${BLUE}Klone n8n in $N8N_DIR...${NC}"
    sudo mkdir -p "$N8N_DIR"
    sudo chown -R $USER:$USER "$N8N_DIR"
    git clone https://github.com/n8n-io/n8n.git "$N8N_DIR"
    cd "$N8N_DIR"
fi

# 2. Abhängigkeiten installieren mit pnpm
echo -e "${BLUE}Installiere Abhängigkeiten für n8n mit pnpm...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm install für n8n fehlgeschlagen.${NC}"
    exit 1
fi

# 3. n8n bauen
echo -e "${BLUE}Baue n8n mit pnpm...${NC}"
pnpm build
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: pnpm build für n8n fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Konfiguration und Start (Platzhalter)
echo -e "${YELLOW}Hinweis: n8n Konfiguration und Start als Service müssen eventuell manuell angepasst werden.${NC}"
echo -e "${YELLOW}Standardmäßig startet n8n auf Port 5678.${NC}"

echo -e "${GREEN}n8n Installation abgeschlossen.${NC}"
