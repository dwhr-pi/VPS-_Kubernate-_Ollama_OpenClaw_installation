#!/bin/bash
TOOL_NAME="SEMrush"
TOOL_KEY="SEMrush"
TOOL_SLUG="semrush"
TOOL_DESCRIPTION="Connector-Modul für SEMrush SEO- und Wettbewerbsdaten."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='SEMRUSH_API_KEY='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
