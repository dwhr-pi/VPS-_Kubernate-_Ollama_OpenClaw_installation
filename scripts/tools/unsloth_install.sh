#!/bin/bash
TOOL_NAME="Unsloth"
TOOL_KEY="Unsloth"
TOOL_SLUG="unsloth"
TOOL_DESCRIPTION="GitHub-basierter Fine-Tuning-Baustein für effizientes LoRA- und QLoRA-Training lokaler LLMs."
TOOL_MODULE_TYPE="LLM-Fine-Tuning-Toolchain"
TOOL_GIT_REPO="https://github.com/unslothai/unsloth.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Unsloth

```txt
Bereite ein QLoRA-Fine-Tuning für ein bestehendes Open-Source-Modell mit eigenen Instruktionsdaten vor und dokumentiere Hyperparameter, Adapter und Testschritte.
```'
TOOL_OPENCLAW_NOTE="Gedacht für den LLM-Builder-Workflow: Datensatz vorbereiten, LoRA/QLoRA trainieren, Modell testen und später nach GGUF/Ollama überführen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
