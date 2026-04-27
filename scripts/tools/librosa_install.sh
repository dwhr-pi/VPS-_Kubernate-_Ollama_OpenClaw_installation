#!/bin/bash
TOOL_NAME="librosa"
TOOL_KEY="librosa"
TOOL_SLUG="librosa"
TOOL_PACKAGES="librosa soundfile"
TOOL_DESCRIPTION="Audioanalyse für BPM, Spektren, Harmonik und Signal-Merkmale."
TOOL_OPENCLAW_NOTE="Gut für Media_Musik, um Audiodateien in OpenClaw-Workflows analytisch auszuwerten."
TOOL_PROMPT_EXAMPLE='```txt
Analysiere eine Audiodatei auf BPM, Key und Energielevel und gib die Werte für einen Music-Prompt aus.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
