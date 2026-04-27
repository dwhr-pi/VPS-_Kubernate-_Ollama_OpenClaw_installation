#!/bin/bash
TOOL_NAME="Piper"
TOOL_KEY="Piper"
TOOL_SLUG="piper"
TOOL_PACKAGES="piper-tts"
TOOL_DESCRIPTION="Lokale Text-to-Speech Engine für Audio- und Content-Automation-Workflows."
TOOL_OPENCLAW_NOTE="Passt gut zu Audio- und Content_Automation-Profilen für Voiceover und lokale Sprachsynthese."
TOOL_PROMPT_EXAMPLE='```txt
Erzeuge aus einem Skript ein natürlich klingendes deutsches Voiceover und bereite es für einen OpenClaw-Workflow vor.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
