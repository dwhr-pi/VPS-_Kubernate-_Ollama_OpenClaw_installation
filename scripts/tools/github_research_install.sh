#!/bin/bash
TOOL_NAME="GitHub_Research"
TOOL_KEY="GitHub_Research"
TOOL_SLUG="github_research"
TOOL_DESCRIPTION="Workflow-Modul für GitHub-zentrierte Recherche, Repo-Screening und Änderungsbeobachtung."
TOOL_MODULE_TYPE="Research-Modul"
TOOL_OPENCLAW_NOTE="Ergänzt Research_Agent und Programmiererprofil um gezielte Repo-Beobachtung."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
