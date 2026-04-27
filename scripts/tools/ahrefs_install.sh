#!/bin/bash
TOOL_NAME="Ahrefs"
TOOL_KEY="Ahrefs"
TOOL_SLUG="ahrefs"
TOOL_DESCRIPTION="Connector-Modul für Ahrefs-SEO-Daten und Keyword-Workflows."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='AHREFS_API_KEY='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
