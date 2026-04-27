#!/bin/bash
TOOL_NAME="SQLite"
TOOL_KEY="SQLite"
APT_PACKAGES="sqlite3"
TOOL_DESCRIPTION="Leichtgewichtige Datenbank für lokale Agenten-, Workflow- und Testdaten."
TOOL_OPENCLAW_NOTE="Nützlich für kleine lokale OpenClaw-Skills, Statusdaten und Prototypen."
source "$(dirname "$0")/helpers/apt_tool_common.sh"
install_apt_tool
