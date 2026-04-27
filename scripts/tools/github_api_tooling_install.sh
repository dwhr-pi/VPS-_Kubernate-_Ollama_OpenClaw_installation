#!/bin/bash
TOOL_NAME="GitHub_API_Tooling"
TOOL_KEY="GitHub_API_Tooling"
TOOL_SLUG="github_api_tooling"
TOOL_PACKAGES="PyGithub ghapi"
TOOL_DESCRIPTION="Python-Tooling für GitHub-API-Workflows, Repo-Automation und Metadatenabfragen."
TOOL_OPENCLAW_NOTE="Passt zum Programmierer- und Research_Agent-Profil für Repo-Checks, PR-Analysen und Automatisierung."
TOOL_PROMPT_EXAMPLE='```txt
Analysiere die offenen Issues und PRs eines Repos und fasse die wichtigsten Risiken für das Entwicklerprofil zusammen.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
