#!/bin/bash
set -euo pipefail
TOOL_NAME="Trafilatura"
TOOL_KEY="Trafilatura"
TOOL_SLUG="trafilatura"
TOOL_PACKAGES="trafilatura"
TOOL_DESCRIPTION="Text- und Inhalts-Extraktion aus Web-Seiten für Crawl-, Research- und RAG-Vorverarbeitung."
TOOL_OPENCLAW_NOTE="Sinnvoll für sichere Web-Extraktion ohne Browser-Zwang. Gut für OSINT-, Dokument- und RAG-Vorbereitung."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
