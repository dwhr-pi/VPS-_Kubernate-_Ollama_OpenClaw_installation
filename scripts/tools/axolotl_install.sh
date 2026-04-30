#!/bin/bash
TOOL_NAME="Axolotl"
TOOL_KEY="Axolotl"
TOOL_SLUG="axolotl"
TOOL_DESCRIPTION="GitHub-basierte Fine-Tuning-Toolchain für lokale LLM-Trainingsläufe und Adapter-Workflows."
TOOL_MODULE_TYPE="LLM-Fine-Tuning-Toolchain"
TOOL_GIT_REPO="https://github.com/axolotl-ai-cloud/axolotl.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f requirements.txt ]; then pip install -r requirements.txt; fi && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Axolotl

```txt
Plane ein lokales Adapter-Fine-Tuning mit Axolotl, validiere den Datensatz und beschreibe den Schritt bis zum Merge der Adapter.
```'
TOOL_OPENCLAW_NOTE="Alternative Trainings-Toolchain für den LLM-Builder, wenn verschiedene Fine-Tuning-Wege miteinander verglichen werden sollen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
