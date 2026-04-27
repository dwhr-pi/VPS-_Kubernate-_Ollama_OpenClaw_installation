#!/bin/bash
TOOL_NAME="Udio_API"
TOOL_KEY="Udio_API"
TOOL_SLUG="udio_api"
TOOL_DESCRIPTION="Connector-Modul für Udio-nahe Musik- und Prompt-Workflows."
TOOL_MODULE_TYPE="API-Connector"
TOOL_OPENCLAW_NOTE="Ergänzt das Media_Musik-Profil um einen zweiten API-Pfad für Musikideen."
TOOL_ENV_TEMPLATE='UDIO_API_KEY=\nUDIO_API_BASE_URL=https://api.udio.example'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
