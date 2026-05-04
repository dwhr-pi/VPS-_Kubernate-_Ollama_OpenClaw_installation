#!/bin/bash
set -euo pipefail
TOOL_NAME="Dev Container CLI"
TOOL_KEY="Devcontainer_CLI"
TOOL_SLUG="devcontainer_cli"
TOOL_NPM_PACKAGES="@devcontainers/cli"
TOOL_DESCRIPTION="CLI für Development Containers zur lokalen Reproduktion von Container-Workspaces und CI-nahen Coding-Umgebungen."
TOOL_OPENCLAW_NOTE="Hilfreich für lokale Codex-, OpenHands- und Sandbox-Nachbauten mit reproduzierbaren Dev-Containern."
source "$(dirname "$0")/helpers/node_tool_common.sh"
install_node_tool
