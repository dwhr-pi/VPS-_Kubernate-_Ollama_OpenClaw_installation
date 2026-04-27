#!/bin/bash
TOOL_NAME="Risk_Scoring"
TOOL_KEY="Risk_Scoring"
TOOL_SLUG="risk_scoring"
TOOL_DESCRIPTION="Scoring-Modul für Risiko, Priorität und Warnstufen in Agentenworkflows."
TOOL_MODULE_TYPE="Scoring-Modul"
TOOL_OPENCLAW_NOTE="Verwendbar in Legal-, Trading-, Security- und Research-Profilen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
