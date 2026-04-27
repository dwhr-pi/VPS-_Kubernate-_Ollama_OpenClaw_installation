#!/bin/bash
TOOL_NAME="Coqui_TTS"
TOOL_KEY="Coqui_TTS"
TOOL_SLUG="coqui_tts"
TOOL_PACKAGES="TTS"
TOOL_DESCRIPTION="Lokale Text-to-Speech Pipeline für Voiceover, Assistenzsysteme und Content-Automation."
TOOL_OPENCLAW_NOTE="Ergänzt Audio- und Content-Automation-Profile mit lokaler Sprachsynthese."
TOOL_PROMPT_EXAMPLE='```txt
Erzeuge ein deutschsprachiges Voiceover für ein Video-Skript und gib die empfohlenen Syntheseparameter aus.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
