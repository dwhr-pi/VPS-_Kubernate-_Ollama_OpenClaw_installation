#!/bin/bash
TOOL_NAME="Podman"
TOOL_KEY="Podman"
APT_PACKAGES="podman"
TOOL_DESCRIPTION="Daemonfreie Container-Laufzeit als Alternative oder Ergänzung zu Docker für Sandbox-Workspaces."
TOOL_OPENCLAW_NOTE="Nützlich für den Codex-Nachbau, wenn eine isolierte lokale Sandbox ohne klassischen Docker-Daemon gewünscht ist."
source "$(dirname "$0")/helpers/apt_tool_common.sh"
install_apt_tool
