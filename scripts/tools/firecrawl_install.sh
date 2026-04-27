#!/bin/bash
TOOL_NAME="Firecrawl"
TOOL_KEY="Firecrawl"
TOOL_SLUG="firecrawl"
TOOL_DESCRIPTION="Connector-Modul für Firecrawl- oder ähnliche Web-Scraping-Integrationen."
TOOL_MODULE_TYPE="API-Connector"
TOOL_OPENCLAW_NOTE="Passt zu Research_Agent und Marketingprofilen für strukturierte Webquellen."
TOOL_ENV_TEMPLATE='FIRECRAWL_API_KEY=\nFIRECRAWL_BASE_URL=https://api.firecrawl.dev'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
