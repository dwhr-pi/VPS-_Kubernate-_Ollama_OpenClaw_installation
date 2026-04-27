#!/bin/bash
TOOL_NAME="Trend_Monitor"
TOOL_KEY="Trend_Monitor"
TOOL_SLUG="trend_monitor"
TOOL_PACKAGES="pytrends feedparser requests beautifulsoup4"
TOOL_DESCRIPTION="Trend- und Feed-Monitoring für Research- und Content-Pipelines."
TOOL_OPENCLAW_NOTE="Passt zum Research_Agent für Themenradar und zum Content_Automation-Profil für Trend-getriebte Inhalte."
TOOL_PROMPT_EXAMPLE='```txt
Beobachte Trends zu einem Themenbereich, priorisiere Quellen und skizziere daraus eine Research- oder Content-Pipeline.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
