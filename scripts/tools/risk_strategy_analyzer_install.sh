#!/bin/bash
TOOL_NAME="Risk_Strategy_Analyzer"
TOOL_KEY="Risk_Strategy_Analyzer"
TOOL_SLUG="risk_strategy_analyzer"
TOOL_DESCRIPTION="Trading-Modul für Risiko- und Strategieauswertung."
TOOL_MODULE_TYPE="Trading-Modul"
TOOL_OPENCLAW_NOTE="Passt zu Trading_AI für Signale, Strategievergleiche und Warnschwellen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
