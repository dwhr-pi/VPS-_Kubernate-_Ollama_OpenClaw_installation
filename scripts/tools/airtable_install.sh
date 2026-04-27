#!/bin/bash
TOOL_NAME="Airtable"
TOOL_KEY="Airtable"
TOOL_SLUG="airtable"
TOOL_DESCRIPTION="Connector-Modul für Airtable-Bases und Kampagnendaten."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='AIRTABLE_API_KEY=\nAIRTABLE_BASE_ID='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
