#!/bin/bash
set -euo pipefail
TOOL_NAME="Haystack"
TOOL_KEY="Haystack"
TOOL_SLUG="haystack"
TOOL_PACKAGES="haystack-ai"
TOOL_DESCRIPTION="Modulare RAG- und Pipeline-Bibliothek für Retrieval, Indexierung, Search und Agenten-Bausteine."
TOOL_OPENCLAW_NOTE="Geeignet für dokumentennahe Pipelines, Hybrid-Retrieval und produktionsnahe RAG-Flows."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
