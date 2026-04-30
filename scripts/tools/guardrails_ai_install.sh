#!/bin/bash
TOOL_NAME="Guardrails_AI"
TOOL_KEY="Guardrails_AI"
TOOL_SLUG="guardrails_ai"
TOOL_DESCRIPTION="Guardrails-Framework für LLM-Validierung, Schutzregeln und Prompt-/Output-Sicherheit."
TOOL_MODULE_TYPE="AI-Security-Scaffold"
TOOL_GIT_REPO="https://github.com/guardrails-ai/guardrails.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; else pip install guardrails-ai; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Guardrails AI

```txt
Lege Eingabe- und Ausgabeprüfungen für OpenClaw-Agenten an und erkläre, wie Prompt Injection, PII und unsichere Toolausgaben abgefangen werden.
```'
TOOL_OPENCLAW_NOTE="Guardrails AI ist der zentrale Policy- und Validierungsbaustein für sichere Agentenläufe im Plattform-Stack."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
