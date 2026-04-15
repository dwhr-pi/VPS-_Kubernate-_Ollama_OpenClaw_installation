#!/bin/bash
# ==============================================================================
# PORT_CHECK.SH - Überprüfung auf Port-Konflikte
# Dieses Skript prüft, ob die benötigten Ports bereits belegt sind.
# ==============================================================================

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Port-Konflikt-Überprüfung...${NC}"

PORTS=("11434" "18789" "8123" "8080")
SERVICES=("Ollama" "OpenClaw Gateway" "Home Assistant" "Zenbot Web")

for i in "${!PORTS[@]}"; do
    PORT=${PORTS[$i]}
    SERVICE=${SERVICES[$i]}
    
    echo -e "${YELLOW}Prüfe Port $PORT für $SERVICE...${NC}"
    if sudo lsof -i :$PORT >/dev/null 2>&1; then
        echo -e "${RED}WARNUNG: Port $PORT ($SERVICE) ist bereits belegt!${NC}"
        echo -e "${RED}Bitte beenden Sie den Prozess, der diesen Port verwendet, oder ändern Sie die Konfiguration.${NC}"
        sudo lsof -i :$PORT
        echo ""
    else
        echo -e "${GREEN}Port $PORT ($SERVICE) ist frei.${NC}"
    fi
done

echo -e "${GREEN}Port-Überprüfung abgeschlossen.${NC}"
