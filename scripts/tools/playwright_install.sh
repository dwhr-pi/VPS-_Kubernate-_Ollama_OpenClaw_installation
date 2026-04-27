#!/bin/bash
TOOL_NAME="Playwright"
TOOL_KEY="Playwright"
TOOL_SLUG="playwright"
TOOL_PACKAGES="playwright"
TOOL_POST_INSTALL="python -m playwright install chromium"
TOOL_DESCRIPTION="Browser-Automatisierung für Web-Tests, Scraping und UI-Workflows."
TOOL_OPENCLAW_NOTE="Sinnvoll für Programmierer- und Marketing-Profile bei Browser-Workflows."
TOOL_PROMPT_EXAMPLE='```txt
Nutze Playwright, um die lokale OpenClaw-Weboberfläche zu testen und die wichtigsten Navigationspfade zu prüfen.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
