#!/bin/bash
# ==============================================================================
# PORT_CHECK.SH - Überprüfung auf Port-Konflikte
# Dieses Skript prüft, ob die benötigten Ports bereits belegt sind.
# ==============================================================================

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

PORTS=("11434" "18789" "8123" "8080")
SERVICES=("Ollama" "OpenClaw Gateway" "Home Assistant" "Zenbot Web")

find_port_command() {
    local port="$1"

    if command -v ss >/dev/null 2>&1; then
        ss -ltnp "( sport = :$port )" 2>/dev/null
        return $?
    fi

    if command -v lsof >/dev/null 2>&1; then
        lsof -nP -iTCP:"$port" -sTCP:LISTEN 2>/dev/null
        return $?
    fi

    echo ""
    return 2
}

echo -e "${BLUE}Starte Port-Konflikt-Überprüfung...${NC}"

if ! command -v ss >/dev/null 2>&1 && ! command -v lsof >/dev/null 2>&1; then
    echo -e "${RED}Fehler: Weder 'ss' noch 'lsof' sind verfügbar. Eine Port-Prüfung ist nicht möglich.${NC}"
    exit 1
fi

for i in "${!PORTS[@]}"; do
    port="${PORTS[$i]}"
    service="${SERVICES[$i]}"

    echo -e "${YELLOW}Prüfe Port $port für $service...${NC}"
    port_output="$(find_port_command "$port")"
    port_status=$?

    if [ $port_status -eq 0 ] && [ -n "$port_output" ]; then
        echo -e "${RED}WARNUNG: Port $port ($service) ist bereits belegt!${NC}"
        echo -e "${RED}Bitte beenden Sie den Prozess, der diesen Port verwendet, oder ändern Sie die Konfiguration.${NC}"
        echo "$port_output"
        echo ""
    elif [ $port_status -eq 2 ]; then
        echo -e "${YELLOW}Hinweis: Für die Detailausgabe ist weder 'ss' noch 'lsof' korrekt verfügbar.${NC}"
    else
        echo -e "${GREEN}Port $port ($service) ist frei.${NC}"
    fi
done

echo -e "${GREEN}Port-Überprüfung abgeschlossen.${NC}"
