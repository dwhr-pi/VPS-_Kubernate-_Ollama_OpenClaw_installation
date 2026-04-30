#!/bin/bash
TOOL_NAME="OpenLIT"
TOOL_KEY="OpenLIT"
TOOL_SLUG="openlit"
TOOL_DESCRIPTION="OpenTelemetry-native LLM Observability und Instrumentierung für lokale und hybride KI-Systeme."
TOOL_MODULE_TYPE="LLMOps-Observability-Scaffold"
TOOL_GIT_REPO="https://github.com/openlit/openlit.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für OpenLIT

```txt
Instrumentiere lokale LLM- und RAG-Aufrufe mit OpenTelemetry und dokumentiere, welche Traces und Spans im Setup erfasst werden sollen.
```'
TOOL_OPENCLAW_NOTE="OpenLIT dient hier als Instrumentierungs- und Tracing-Baustein. Die eigentliche UI-/Analyseebene wird typischerweise mit Langfuse und Grafana ergänzt."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
