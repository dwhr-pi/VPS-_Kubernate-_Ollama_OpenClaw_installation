#!/bin/bash
TOOL_NAME="LangGraph"
TOOL_SLUG="langgraph"
TOOL_PACKAGES="langgraph langchain"
TOOL_DESCRIPTION="Workflow- und Graph-Orchestrierung für Agentenketten im OpenClaw/Ollama-Umfeld."
TOOL_OPENCLAW_NOTE="Geeignet für Agent-Routing und Workflow-Definitionen im Programmierer- und KI-Forschung-Profil."
TOOL_PROMPT_EXAMPLE='```txt
Erstelle einen LangGraph-Workflow für: Planer -> Entwickler -> Reviewer -> Fixer.
Nutze Ollama für lokale Aufgaben und gib die Knotendefinitionen als Python-Code aus.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
