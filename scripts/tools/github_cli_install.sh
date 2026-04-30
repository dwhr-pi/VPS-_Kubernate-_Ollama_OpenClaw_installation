#!/bin/bash
TOOL_NAME="GitHub_CLI"
TOOL_KEY="GitHub_CLI"
APT_PACKAGES="gh"
TOOL_DESCRIPTION="GitHub CLI für Branches, Commits, Pull Requests, Actions und Issue-/PR-Workflows."
TOOL_OPENCLAW_NOTE="Ergänzt den Codex-Nachbau für Repo-Automation, PR-Flows und Sandbox-nahe Entwicklungsabläufe."
source "$(dirname "$0")/helpers/apt_tool_common.sh"
install_apt_tool
