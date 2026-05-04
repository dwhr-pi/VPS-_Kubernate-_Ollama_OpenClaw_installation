#!/bin/bash
set -euo pipefail
TOOL_NAME="Prettier"
TOOL_KEY="Prettier"
TOOL_SLUG="prettier"
TOOL_NPM_PACKAGES="prettier"
TOOL_DESCRIPTION="Formatter für Markdown-, JSON-, YAML-, CSS- und JavaScript/TypeScript-Dateien."
TOOL_OPENCLAW_NOTE="Hilfreich für Doku-, Web- und Repo-Maintainer-Profile."
source "$(dirname "$0")/helpers/node_tool_common.sh"
install_node_tool
