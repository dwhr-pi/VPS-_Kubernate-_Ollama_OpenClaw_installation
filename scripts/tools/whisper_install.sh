#!/bin/bash
TOOL_NAME="Whisper"
TOOL_KEY="Whisper"
TOOL_SLUG="whisper"
TOOL_PACKAGES="openai-whisper"
TOOL_DESCRIPTION="Lokale Speech-to-Text-Pipeline für Multimedia- und Forschungs-Workflows."
TOOL_OPENCLAW_NOTE="Passend für KI_Forschung und Media_Musik bei Audio-Transkription."
TOOL_PROMPT_EXAMPLE='```txt
Transkribiere eine Aufnahme und extrahiere daraus Themen, Stimmungen und mögliche Kapitelmarker für OpenClaw.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
