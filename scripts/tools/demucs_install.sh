#!/bin/bash
TOOL_NAME="Demucs"
TOOL_SLUG="demucs"
TOOL_PACKAGES="demucs"
TOOL_DESCRIPTION="Stem-Separation für Audio in Gesang, Drums, Bass und weitere Spuren."
TOOL_OPENCLAW_NOTE="Sinnvoll im Media_Musik-Profil für Remix-, Analyse- und Stem-Workflows."
TOOL_PROMPT_EXAMPLE='```txt
Trenne eine Songdatei in Vocals, Drums und Bass und bereite die Spuren für einen Remix-Workflow vor.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
