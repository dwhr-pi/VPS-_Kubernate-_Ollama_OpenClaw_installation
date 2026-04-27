#!/bin/bash
TOOL_NAME="vLLM"
TOOL_KEY="vLLM"
TOOL_SLUG="vllm"
TOOL_PACKAGES="vllm"
TOOL_DESCRIPTION="Inference-Engine für leistungsfähige LLM-Serving-Workloads."
TOOL_OPENCLAW_NOTE="Passt zum KI_Forschung-Profil für schnellere Modellserving-Experimente neben Ollama."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
