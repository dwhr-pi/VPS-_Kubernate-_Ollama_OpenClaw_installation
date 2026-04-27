#!/bin/bash
TOOL_NAME="EULLM"
TOOL_KEY="EULLM"
TOOL_SLUG="eullm"
TOOL_DESCRIPTION="Connector-Modul für europäische juristische LLM- oder Compliance-nahe Workflows."
TOOL_MODULE_TYPE="Rechts-Connector"
TOOL_OPENCLAW_NOTE="Passt zum Rechtsberatung_Steuerrecht-Profil als externer juristischer Modellpfad."
TOOL_ENV_TEMPLATE='EULLM_API_KEY=\nEULLM_BASE_URL='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
