#!/bin/bash
set -euo pipefail
TOOL_NAME="TruLens"
TOOL_KEY="TruLens"
TOOL_SLUG="trulens"
TOOL_PACKAGES="trulens"
TOOL_DESCRIPTION="Evaluations- und Tracing-Toolkit für LLM-Anwendungen, RAG und agentische Pipelines."
TOOL_OPENCLAW_NOTE="Sinnvoll für produktionsnahe Qualitätskontrolle und Tracing in lokalen Agenten-Stacks."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
