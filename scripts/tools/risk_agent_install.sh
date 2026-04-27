#!/bin/bash
TOOL_NAME="Risk_Agent"
TOOL_KEY="Risk_Agent"
TOOL_SLUG="risk_agent"
TOOL_DESCRIPTION="Agentenmodul für Risikoanalyse, Priorisierung und Warnhinweise."
TOOL_MODULE_TYPE="Agentenmodul"
TOOL_OPENCLAW_NOTE="Kann in Legal-, Trading- und Security-Profilen wiederverwendet werden."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
