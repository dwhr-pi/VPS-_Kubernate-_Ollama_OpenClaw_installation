#!/bin/bash
TOOL_NAME="EnviroLLM"
TOOL_KEY="EnviroLLM"
TOOL_SLUG="envirollm"
TOOL_DESCRIPTION="Scaffold-Modul für umgebungs- und simulationsnahe LLM-Experimente."
TOOL_MODULE_TYPE="Forschungsmodul"
TOOL_OPENCLAW_NOTE="Dient als Platz für EnviroLLM-nahe Pipelines, Datenschemata und OpenClaw-Tests."
TOOL_ENV_TEMPLATE='ENVIROLLM_BACKEND=ollama\nOLLAMA_HOST=http://localhost:11434\nENVIROLLM_MODEL=llama3.2:1b'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
