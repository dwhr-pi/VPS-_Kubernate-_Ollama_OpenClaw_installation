#!/bin/bash
TOOL_NAME="YT_DLP"
TOOL_KEY="YT_DLP"
TOOL_SLUG="yt_dlp"
TOOL_PACKAGES="yt-dlp"
TOOL_DESCRIPTION="Downloader- und Medien-Eingangswerkzeug für Content-Automation-Pipelines."
TOOL_OPENCLAW_NOTE="Hilft beim Einspeisen von Video- oder Audioquellen in automatisierte Content-Workflows."
TOOL_PROMPT_EXAMPLE='```txt
Lade ein Video als Quelle herunter, extrahiere den Audiostream und bereite daraus eine OpenClaw-Pipeline vor.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
