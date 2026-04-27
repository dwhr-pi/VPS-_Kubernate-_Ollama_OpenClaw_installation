#!/bin/bash
TOOL_NAME="File_System_Tool"
TOOL_KEY="File_System_Tool"
TOOL_SLUG="file_system_tool"
TOOL_DESCRIPTION="Lokales Dateisystem-Modul für geordnete Asset-, Prompt- und Kampagnenordner."
TOOL_MODULE_TYPE="Workflow-Modul"
TOOL_OPENCLAW_NOTE="Hilft Content-, Research- und Marketingprofilen bei konsistenter Ablage."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
