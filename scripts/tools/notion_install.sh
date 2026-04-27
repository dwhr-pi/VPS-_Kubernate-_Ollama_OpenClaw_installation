#!/bin/bash
TOOL_NAME="Notion"
TOOL_KEY="Notion"
TOOL_SLUG="notion"
TOOL_DESCRIPTION="Connector-Modul für Notion-Seiten, Datenbanken und Content-Backlogs."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='NOTION_API_KEY=\nNOTION_DATABASE_ID='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
