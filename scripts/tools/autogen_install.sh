#!/bin/bash
TOOL_NAME="AutoGen"
TOOL_SLUG="autogen"
TOOL_PACKAGES="pyautogen"
TOOL_DESCRIPTION="Microsoft AutoGen für strukturierte Multi-Agent-Dialoge und Tool-Use-Workflows."
TOOL_OPENCLAW_NOTE="Kann als zusätzlicher Agenten-Backbone neben OpenClaw verwendet werden."
TOOL_PROMPT_EXAMPLE='```txt
Baue ein AutoGen-Setup mit Architect, Debugger und Security Reviewer für ein lokales OpenClaw/Ollama-Projekt.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
