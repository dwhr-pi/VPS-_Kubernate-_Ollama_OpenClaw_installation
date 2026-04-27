#!/bin/bash
TOOL_NAME="Puppeteer"
TOOL_KEY="Puppeteer"
TOOL_SLUG="puppeteer"
TOOL_NPM_PACKAGES="puppeteer"
TOOL_DESCRIPTION="Node-basierte Browserautomatisierung für Tests, Screenshots und Web-Workflows."
TOOL_OPENCLAW_NOTE="Ergänzt Playwright im Programmiererprofil und kann lokale OpenClaw-Webtests übernehmen."
TOOL_PROMPT_EXAMPLE='```txt
Öffne eine lokale Weboberfläche, führe einen Smoke-Test aus und dokumentiere eventuelle UI-Fehler.
```'
source "$(dirname "$0")/helpers/node_tool_common.sh"
install_node_tool
