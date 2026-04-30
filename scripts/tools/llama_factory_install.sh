#!/bin/bash
TOOL_NAME="LLaMA_Factory"
TOOL_KEY="LLaMA_Factory"
TOOL_SLUG="llama_factory"
TOOL_DESCRIPTION="GitHub-basierter Trainings- und Evaluationsstack für Fine-Tuning, Adapterschichten und Modelltests."
TOOL_MODULE_TYPE="LLM-Fine-Tuning-Toolchain"
TOOL_GIT_REPO="https://github.com/hiyouga/LLaMA-Factory.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für LLaMA Factory

```txt
Richte ein LoRA-Fine-Tuning für einen Instruktionsdatensatz ein, erkläre die Trainingskonfiguration und schlage Evaluationsschritte vor.
```'
TOOL_OPENCLAW_NOTE="Passt zum LLM-Builder-Profil als strukturierter Trainings- und Evaluationspfad aus GitHub-Quellen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
