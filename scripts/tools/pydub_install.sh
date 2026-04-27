#!/bin/bash
TOOL_NAME="pydub"
TOOL_SLUG="pydub"
TOOL_PACKAGES="pydub"
TOOL_DESCRIPTION="Einfache Audio-Manipulation für Splits, Fades und Vorverarbeitung."
TOOL_OPENCLAW_NOTE="Nutzt idealerweise FFmpeg im Hintergrund und passt daher gut in das Media_Musik-Profil."
TOOL_PROMPT_EXAMPLE='```txt
Schneide Intro und Outro einer Datei, normalisiere die Lautheit und exportiere eine Social-Media-Vorschau.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
