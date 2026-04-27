#!/bin/bash
TOOL_NAME="Backtest_Workflow"
TOOL_KEY="Backtest_Workflow"
TOOL_SLUG="backtest_workflow"
TOOL_DESCRIPTION="Workflow-Modul für Backtests, Strategievarianten und Simulationsläufe."
TOOL_MODULE_TYPE="Trading-Modul"
TOOL_OPENCLAW_NOTE="Ergänzt Trading_AI um einen sauberen Platz für wiederholbare Testläufe."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
