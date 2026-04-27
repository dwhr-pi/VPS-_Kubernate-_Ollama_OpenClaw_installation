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
init_profile_tracking "Trading_AI"

echo -e "${BLUE}Starte Deinstallation des Trading_AI-Profils...${NC}"

for tool_script in backtest_workflow_uninstall.sh risk_strategy_analyzer_uninstall.sh zenbot_api_uninstall.sh exchange_apis_uninstall.sh web3_apis_uninstall.sh zenbot_trader_uninstall.sh; do
    if [ -f "$INSTALL_DIR/scripts/tools/$tool_script" ]; then
        echo -e "${BLUE}Deinstalliere ${tool_script%.sh} als Teil des Trading_AI-Profils...${NC}"
        bash "$INSTALL_DIR/scripts/tools/$tool_script"
    else
        echo -e "${YELLOW}${tool_script} nicht gefunden. Überspringe diesen Baustein.${NC}"
    fi
done

echo -e "${GREEN}Trading_AI-Profil Deinstallation abgeschlossen.${NC}"
mark_current_profile_removed
