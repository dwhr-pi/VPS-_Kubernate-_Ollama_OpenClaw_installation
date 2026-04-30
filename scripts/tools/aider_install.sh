#!/bin/bash
TOOL_NAME="Aider"
TOOL_KEY="Aider"
TOOL_SLUG="aider"
TOOL_PACKAGES="aider-chat"
TOOL_DESCRIPTION="Terminal-Pair-Programming-Agent für Coding, Refactoring, Git-Diffs und Repository-Arbeit."
TOOL_OPENCLAW_NOTE="Passt zum Codex-Nachbau mit Ollama, GitHub CLI und OpenClaw-Orchestrierung. API- oder Modellwahl erfolgt später über die jeweilige Anbieter- oder Ollama-Konfiguration."
TOOL_PROMPT_EXAMPLE='```txt
Nutze Aider, um einen minimalen Patch für einen Bash-Fehler zu erzeugen, den Diff zu erklären und die Änderung commit-fähig zu machen.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
