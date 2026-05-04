#!/bin/bash
set -euo pipefail
TOOL_NAME="Distilabel"
TOOL_KEY="Distilabel"
TOOL_SLUG="distilabel"
TOOL_DESCRIPTION="Framework für synthetische Daten, Dataset-Generierung und LLM-gestützte Datenpipelines."
TOOL_MODULE_TYPE="Synthetic-Data-Scaffold"
TOOL_GIT_REPO="https://github.com/argilla-io/distilabel.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip build-essential"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && pip install -e .'
TOOL_OPENCLAW_NOTE="Sinnvoll für lokale Testdaten, RAG-Fragen und Fine-Tuning-Datensätze aus Modellpipelines."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
