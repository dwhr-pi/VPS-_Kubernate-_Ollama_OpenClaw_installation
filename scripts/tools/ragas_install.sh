#!/bin/bash
set -euo pipefail
TOOL_NAME="Ragas"
TOOL_KEY="Ragas"
TOOL_SLUG="ragas"
TOOL_PACKAGES="ragas"
TOOL_DESCRIPTION="RAG-Evaluationsframework für Retrieval-, Antwort- und Grounding-Qualität."
TOOL_OPENCLAW_NOTE="Passt zu lokalen RAG-Stacks mit Qdrant, ChromaDB, LightRAG und Langfuse."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
