#!/bin/bash
TOOL_NAME="Runway_API"
TOOL_KEY="Runway_API"
TOOL_SLUG="runway_api"
TOOL_DESCRIPTION="Connector-Modul für Runway-nahe Visual- und Videoworkflows."
TOOL_MODULE_TYPE="API-Connector"
TOOL_OPENCLAW_NOTE="Kann im Visual_Creator-Profil als externer Render- oder Generationspfad dienen."
TOOL_ENV_TEMPLATE='RUNWAY_API_KEY=\nRUNWAY_API_BASE_URL=https://api.runwayml.com'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
