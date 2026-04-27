#!/bin/bash
TOOL_NAME="Zenbot_API"
TOOL_KEY="Zenbot_API"
TOOL_SLUG="zenbot_api"
TOOL_DESCRIPTION="Integrationsmodul für Zenbot-nahe Strategien, Daten und Signale."
TOOL_MODULE_TYPE="Trading-Modul"
TOOL_OPENCLAW_NOTE="Ergänzt Zenbot_trader um strukturierte Übergaben an andere Agenten."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
