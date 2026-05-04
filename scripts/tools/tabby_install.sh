#!/bin/bash
set -euo pipefail
TOOL_NAME="Tabby"
TOOL_KEY="Tabby"
TOOL_SLUG="tabby"
TOOL_DESCRIPTION="Self-Hosted Coding-Assistant-Workspace für lokale Code-Vervollständigung, Repository-Kontext und Team-Assistenz."
TOOL_MODULE_TYPE="Coding-Assistant-Scaffold"
TOOL_GIT_REPO="https://github.com/TabbyML/tabby.git"
TOOL_APT_PACKAGES="git curl"
TOOL_OPENCLAW_NOTE="Tabby ergänzt lokale Coding-Profile als self-hosted Code-Assistenz. Für produktive Serverläufe GPU und Modellstrategie separat planen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
