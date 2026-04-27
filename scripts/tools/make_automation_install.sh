#!/bin/bash
TOOL_NAME="Make"
TOOL_KEY="Make"
TOOL_SLUG="make_automation"
TOOL_DESCRIPTION="Connector-Modul für Make.com-Workflows und Webhook-Pfade."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='MAKE_WEBHOOK_URL='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
