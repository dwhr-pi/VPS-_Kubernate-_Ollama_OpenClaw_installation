#!/bin/bash
TOOL_NAME="Aider"
TOOL_KEY="Aider"
TOOL_SLUG="aider"
TOOL_DESCRIPTION="GitHub-basierter Terminal-Pair-Programming-Agent für Coding, Refactoring, Git-Diffs und Repository-Arbeit."
TOOL_MODULE_TYPE="Coding-Agent-Scaffold"
TOOL_GIT_REPO="https://github.com/Aider-AI/aider.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Aider

```txt
Nutze Aider, um einen minimalen Patch für einen Bash-Fehler zu erzeugen, den Diff zu erklären und die Änderung commit-fähig zu machen.
```'
TOOL_OPENCLAW_NOTE="Passt zum Codex-Nachbau mit Ollama, GitHub CLI und OpenClaw-Orchestrierung. Die Installation erfolgt aus dem GitHub-Quellrepo und wird lokal in einer Python-Umgebung gebaut."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
