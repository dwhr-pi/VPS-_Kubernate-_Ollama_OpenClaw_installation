#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
# shellcheck disable=SC1091
source "$INSTALL_DIR/scripts/helpers/status_tracking.sh"
init_profile_tracking "Agent_Orchestrator"

echo -e "${BLUE}Starte Deinstallation des Agent_Orchestrator-Profils...${NC}"

for tool_script in loki_uninstall.sh grafana_uninstall.sh prometheus_uninstall.sh weaviate_uninstall.sh qdrant_uninstall.sh nats_uninstall.sh redis_uninstall.sh chromadb_uninstall.sh autogen_uninstall.sh crewai_uninstall.sh langgraph_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des Agent_Orchestrator-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Agent_Orchestrator-Profil Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
