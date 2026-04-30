#!/bin/bash
TOOL_NAME="MCPO"
TOOL_KEY="MCPO"
TOOL_SLUG="mcpo"
TOOL_DESCRIPTION="MCP-zu-OpenAPI-Proxy für Toolserver, passend für Open WebUI und agentische HTTP-Integration."
TOOL_MODULE_TYPE="MCP-Toolserver-Scaffold"
TOOL_GIT_REPO="https://github.com/open-webui/mcpo.git"
TOOL_APT_PACKAGES="git python3 python3-venv python3-pip"
TOOL_POST_INSTALL='python3 -m venv venv && . venv/bin/activate && pip install --upgrade pip setuptools wheel && if [ -f pyproject.toml ] || [ -f setup.py ]; then pip install -e .; else pip install mcpo; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für MCPO

```txt
Lege einen MCP-Proxy für lokale Toolserver an und beschreibe, wie Open WebUI und OpenClaw sicher über HTTP/OpenAPI darauf zugreifen.
```'
TOOL_OPENCLAW_NOTE="MCPO ist der zentrale Brückenbaustein, um stdio-basierte MCP-Server für Open WebUI, OpenClaw und andere OpenAPI-fähige Clients zugänglich zu machen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
