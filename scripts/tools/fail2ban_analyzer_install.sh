#!/bin/bash
TOOL_NAME="Fail2Ban_Analyzer"
TOOL_KEY="Fail2Ban_Analyzer"
TOOL_SLUG="fail2ban_analyzer"
TOOL_DESCRIPTION="Analysemodul für Fail2Ban-Logs, Trigger und Muster."
TOOL_MODULE_TYPE="Security-Modul"
TOOL_OPENCLAW_NOTE="Passt zum Security_Analyst-Profil für Logreview und Alarmbeobachtung."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
