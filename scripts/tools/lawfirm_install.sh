#!/bin/bash
TOOL_NAME="Lawfirm"
TOOL_KEY="Lawfirm"
TOOL_SLUG="lawfirm"
TOOL_DESCRIPTION="Rechtsfall- und Kanzlei-Workflow-Modul für Akten, Mandate und Entwürfe."
TOOL_MODULE_TYPE="Rechts-Workflow-Modul"
TOOL_OPENCLAW_NOTE="Ergänzt juristische Profile um strukturierte Workflow-Bausteine."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
