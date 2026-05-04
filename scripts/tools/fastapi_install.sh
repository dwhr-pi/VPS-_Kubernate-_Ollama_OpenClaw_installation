#!/bin/bash
set -euo pipefail
TOOL_NAME="FastAPI"
TOOL_KEY="FastAPI"
TOOL_SLUG="fastapi"
TOOL_PACKAGES="fastapi uvicorn[standard]"
TOOL_DESCRIPTION="Leichtes Python-Webframework für APIs, interne Agenten-Services und KI-Microservices."
TOOL_OPENCLAW_NOTE="Geeignet für lokale App-Builder, Tool-APIs und Agenten-Hilfsdienste."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
