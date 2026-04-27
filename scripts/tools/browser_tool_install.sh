#!/bin/bash
TOOL_NAME="Browser_Tool"
TOOL_KEY="Browser_Tool"
TOOL_SLUG="browser_tool"
TOOL_DESCRIPTION="Lokales Connector-Modul für Browser-gestützte Recherchen, QA und Navigationsaufgaben."
TOOL_MODULE_TYPE="Connector-Modul"
TOOL_OPENCLAW_NOTE="Kann mit Playwright oder Puppeteer kombiniert werden, um Marketing- und Research-Tasks zu strukturieren."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
