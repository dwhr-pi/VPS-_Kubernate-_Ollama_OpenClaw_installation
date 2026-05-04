#!/bin/bash
set -euo pipefail
TOOL_NAME="Ruff"
TOOL_KEY="Ruff"
TOOL_SLUG="ruff"
TOOL_PACKAGES="ruff"
TOOL_DESCRIPTION="Schneller Python-Linter und Formatter für Coding-, Agenten- und Eval-Repositories."
TOOL_OPENCLAW_NOTE="Empfohlen für lokale Coding-Agenten, Dataset-Pipelines und Python-Tooling."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
