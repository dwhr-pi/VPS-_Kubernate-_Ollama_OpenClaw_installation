#!/bin/bash
TOOL_NAME="Hook_Detection"
TOOL_KEY="Hook_Detection"
TOOL_SLUG="hook_detection"
TOOL_PACKAGES="numpy scipy librosa"
TOOL_DESCRIPTION="Audioanalyse-Modul für Hook- und Highlight-Erkennung."
TOOL_OPENCLAW_NOTE="Ergänzt Media_Musik um virale Hook-Analysen und Schnittvorschläge."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
