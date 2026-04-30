#!/bin/bash
#
# Skript: Programmierer_uninstall.sh
# Beschreibung: Dieses Skript deinstalliert Tools und Konfigurationen, die zum Programmierer-Profil gehören.
# Es entfernt die entsprechenden Softwarepakete und Konfigurationsdateien.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das Programmierer-Profil deinstalliert wird.
#

# Farben
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_profile_tracking "Programmierer"

echo -e "${BLUE}Starte Deinstallation des Programmierer-Profils...${NC}"

# Beispiel: Deinstallation von Huginn (falls installiert)
if [ -f "$INSTALL_DIR/scripts/tools/huginn_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Huginn als Teil des Programmierer-Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/huginn_uninstall.sh"
else
    echo -e "${YELLOW}Huginn Deinstallationsskript nicht gefunden. Überspringe Huginn Deinstallation.${NC}"
fi

# Beispiel: Deinstallation von Clawhub CLI
if [ -f "$INSTALL_DIR/scripts/tools/clawhub_cli_uninstall.sh" ]; then
    echo -e "${BLUE}Deinstalliere Clawhub CLI als Teil des Programmierer-Profils...${NC}"
    bash "$INSTALL_DIR/scripts/tools/clawhub_cli_uninstall.sh"
else
    echo -e "${YELLOW}Clawhub CLI Deinstallationsskript nicht gefunden. Überspringe Clawhub CLI Deinstallation.${NC}"
fi

for tool_script in nats_uninstall.sh rabbitmq_uninstall.sh redis_uninstall.sh qdrant_uninstall.sh weaviate_uninstall.sh postgres_uninstall.sh sqlite_uninstall.sh vault_uninstall.sh opentelemetry_uninstall.sh loki_uninstall.sh grafana_uninstall.sh prometheus_uninstall.sh puppeteer_uninstall.sh vs_code_server_uninstall.sh code_sandbox_uninstall.sh github_api_tooling_uninstall.sh k3s_uninstall.sh kubernetes_uninstall.sh docker_uninstall.sh chromadb_uninstall.sh playwright_uninstall.sh autogen_uninstall.sh crewai_uninstall.sh langgraph_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des Programmierer-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${YELLOW}Hinweis:${NC} Optional installierte Codex-Nachbau-Bausteine wie Aider, OpenCode, OpenHands, GitHub CLI oder Podman werden separat über den Block 'Codex-Nachbau' verwaltet."

echo -e "${GREEN}Programmierer-Profil Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
