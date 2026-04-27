#!/bin/bash
TOOL_NAME="Agent_Router"
TOOL_KEY="Agent_Router"
TOOL_SLUG="agent_router"
TOOL_DESCRIPTION="Routing-Modul für Multi-Agent-Entscheidungen, Rollenverteilung und Übergaben."
TOOL_MODULE_TYPE="Laufzeitmodul"
TOOL_OPENCLAW_NOTE="Passt zum Agent_Orchestrator-Profil und nutzt OpenClaw/Ollama als LLM-Layer für Routing-Regeln."
TOOL_PROMPT_EXAMPLE=$'# Beispielprompts für Agent_Router\n\n```txt\nEntscheide anhand der Aufgabe, ob Programmierer-, Research- oder Security-Agent zuerst übernehmen soll, und begründe das Routing.\n```'
TOOL_CONFIG_JSON='{\n  "router_model": "llama3.2:1b",\n  "ollama_host": "http://localhost:11434",\n  "strategy": "priority_then_confidence"\n}'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
