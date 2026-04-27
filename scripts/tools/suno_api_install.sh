#!/bin/bash
TOOL_NAME="Suno_API"
TOOL_KEY="Suno_API"
TOOL_SLUG="suno_api"
TOOL_DESCRIPTION="Connector-Modul für Suno-nahe Musikgenerierungs-Workflows."
TOOL_MODULE_TYPE="API-Connector"
TOOL_OPENCLAW_NOTE="Passt zum Media_Musik-Profil für Songideen, Hook-Experimente und Audio-Pipelines."
TOOL_ENV_TEMPLATE='SUNO_API_KEY=\nSUNO_API_BASE_URL=https://api.suno.ai'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
