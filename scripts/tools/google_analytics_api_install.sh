#!/bin/bash
TOOL_NAME="Google_Analytics_API"
TOOL_KEY="Google_Analytics_API"
TOOL_SLUG="google_analytics_api"
TOOL_DESCRIPTION="Connector-Modul für Google Analytics APIs."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_OPENCLAW_NOTE="Kann Kampagnen- und Inhaltsmetriken in Marketing-Workflows einbringen."
TOOL_ENV_TEMPLATE='GOOGLE_ANALYTICS_PROPERTY_ID=\nGOOGLE_APPLICATION_CREDENTIALS='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
