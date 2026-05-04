#!/bin/bash
set -euo pipefail
TOOL_NAME="ESLint"
TOOL_KEY="ESLint"
TOOL_SLUG="eslint"
TOOL_NPM_PACKAGES="eslint"
TOOL_DESCRIPTION="Linter für JavaScript- und TypeScript-Code in Web-, Agenten- und UI-Projekten."
TOOL_OPENCLAW_NOTE="Empfohlen für Browser-Agenten, App-Builder und IDE-nahe Coding-Setups."
source "$(dirname "$0")/helpers/node_tool_common.sh"
install_node_tool
