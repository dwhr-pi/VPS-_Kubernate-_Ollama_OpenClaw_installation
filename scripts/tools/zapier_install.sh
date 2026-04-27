#!/bin/bash
TOOL_NAME="Zapier"
TOOL_KEY="Zapier"
TOOL_SLUG="zapier"
TOOL_DESCRIPTION="Connector-Modul für Zapier-Webhook- und Übergabepunkte."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='ZAPIER_WEBHOOK_URL='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
