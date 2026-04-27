#!/bin/bash
TOOL_NAME="BPM_Analyzer"
TOOL_KEY="BPM_Analyzer"
TOOL_SLUG="bpm_analyzer"
TOOL_PACKAGES="librosa numpy scipy"
TOOL_DESCRIPTION="BPM-, Energy- und Tempo-Analysemodul für Audiotracks."
TOOL_OPENCLAW_NOTE="Passt zu Audio- und Media-Profilen für Klassifizierung und Workflow-Routing."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
