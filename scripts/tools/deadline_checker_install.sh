#!/bin/bash
TOOL_NAME="Deadline_Checker"
TOOL_KEY="Deadline_Checker"
TOOL_SLUG="deadline_checker"
TOOL_DESCRIPTION="Fristen- und Terminprüfmodul für juristische und operative Workflows."
TOOL_MODULE_TYPE="Prüfmodul"
TOOL_OPENCLAW_NOTE="Passt ins Rechtsprofil, kann aber auch als allgemeiner Workflow-Guard genutzt werden."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
