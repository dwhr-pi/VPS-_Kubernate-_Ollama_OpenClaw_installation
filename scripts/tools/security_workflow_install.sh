#!/bin/bash
TOOL_NAME="Security_Workflow"
TOOL_KEY="Security_Workflow"
TOOL_SLUG="security_workflow"
TOOL_DESCRIPTION="Workflow-Modul für Sicherheitschecks, Findings, Abhilfen und Ticket-Übergaben."
TOOL_MODULE_TYPE="Security-Modul"
TOOL_OPENCLAW_NOTE="Bündelt Security-Analysen, Container-Scans und Exposure-Checks."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
