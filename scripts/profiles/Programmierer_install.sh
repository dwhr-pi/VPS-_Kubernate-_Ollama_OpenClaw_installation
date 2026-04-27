#!/bin/bash
#
# Skript: Programmierer_install.sh
# Beschreibung: Dieses Skript installiert Tools und Konfigurationen, die speziell für Softwareentwickler und Programmierer nützlich sind.
# Es umfasst Entwicklungsumgebungen, Code-Analyse-Tools, Versionskontrolle und spezifische KI-Entwicklungstools.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Programmierer-Profil ausgewählt wird.
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
init_profile_tracking "Programmierer"

echo -e "${BLUE}Starte Installation des Programmierer-Profils...${NC}"

# Beispiel: Installation von Huginn (falls noch nicht geschehen)
# Huginn ist ein Agentensystem, das für Programmierer nützlich sein kann, um Workflows zu automatisieren.
if [ -f "$INSTALL_DIR/scripts/tools/huginn_install.sh" ]; then
    echo -e "${BLUE}Installiere Huginn als Teil des Programmierer-Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/huginn_install.sh"
else
    echo -e "${YELLOW}Huginn Installationsskript nicht gefunden. Überspringe Huginn Installation.${NC}"
fi

# Beispiel: Installation von Clawhub CLI
if [ -f "$INSTALL_DIR/scripts/tools/clawhub_cli_install.sh" ]; then
    echo -e "${BLUE}Installiere Clawhub CLI als Teil des Programmierer-Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/clawhub_cli_install.sh"
else
    echo -e "${YELLOW}Clawhub CLI Installationsskript nicht gefunden. Überspringe Clawhub CLI Installation.${NC}"
fi

for tool_script in langgraph_install.sh crewai_install.sh autogen_install.sh playwright_install.sh chromadb_install.sh docker_install.sh kubernetes_install.sh k3s_install.sh github_api_tooling_install.sh code_sandbox_install.sh vs_code_server_install.sh puppeteer_install.sh prometheus_install.sh grafana_install.sh loki_install.sh opentelemetry_install.sh vault_install.sh sqlite_install.sh postgres_install.sh weaviate_install.sh qdrant_install.sh redis_install.sh rabbitmq_install.sh nats_install.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Installiere ${tool_script%.sh} als Teil des Programmierer-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Programmierer-Profil Installation abgeschlossen.${NC}"
mark_current_profile_installed
