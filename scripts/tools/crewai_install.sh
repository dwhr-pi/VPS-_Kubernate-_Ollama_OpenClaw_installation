#!/bin/bash
TOOL_NAME="CrewAI"
TOOL_SLUG="crewai"
TOOL_PACKAGES="crewai"
TOOL_DESCRIPTION="Multi-Agent Framework für aufgabenbasierte Zusammenarbeit mehrerer spezialisierter Agents."
TOOL_OPENCLAW_NOTE="Passt besonders zum Programmierer-Profil für Planer-, Coder- und Reviewer-Rollen."
TOOL_PROMPT_EXAMPLE='```txt
Simuliere ein CrewAI-Team aus Planner, Senior Developer und Code Reviewer für die Aufgabe:
"Baue einen OpenClaw Skill für GitHub-Issue-Triage."
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
