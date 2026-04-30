#!/bin/bash
TOOL_NAME="Data_Juicer"
TOOL_KEY="Data_Juicer"
TOOL_SLUG="data_juicer"
TOOL_DESCRIPTION="GitHub-basierter Datensatz-Baustein für Bereinigung, Strukturierung und Qualitätskontrolle vor dem Fine-Tuning."
TOOL_MODULE_TYPE="Dataset-Preparation-Toolchain"
TOOL_GIT_REPO="https://github.com/modelscope/data-juicer.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Data Juicer

```txt
Bereinige diesen Fine-Tuning-Datensatz, entferne Duplikate und strukturiere ihn für ein Instruktionsmodell im Chat-Format.
```'
TOOL_OPENCLAW_NOTE="Nützlich im LLM-Builder-Profil, um Trainingsdaten vor LoRA/QLoRA sauber und reproduzierbar vorzubereiten."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
