#!/bin/bash
TOOL_NAME="HubSpot"
TOOL_KEY="HubSpot"
TOOL_SLUG="hubspot"
TOOL_DESCRIPTION="Connector-Modul für HubSpot CRM- und Marketing-Automation."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='HUBSPOT_ACCESS_TOKEN='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
