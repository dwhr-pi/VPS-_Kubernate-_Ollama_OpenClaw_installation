#!/bin/bash
TOOL_NAME="Buffer_API"
TOOL_KEY="Buffer_API"
TOOL_SLUG="buffer_api"
TOOL_DESCRIPTION="Connector-Modul für Buffer-basierte Scheduling- und Posting-Workflows."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='BUFFER_ACCESS_TOKEN='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
