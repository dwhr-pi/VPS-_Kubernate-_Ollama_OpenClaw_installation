#!/bin/bash
set -euo pipefail
TOOL_NAME="DeepEval"
TOOL_KEY="DeepEval"
TOOL_SLUG="deepeval"
TOOL_PACKAGES="deepeval"
TOOL_DESCRIPTION="Framework für LLM-, Agenten- und RAG-Tests mit Metriken, Testfällen und Regressionserkennung."
TOOL_OPENCLAW_NOTE="Ergänzt Promptfoo und LM Harness um anwendungsnahe Evaluationsmetriken."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
