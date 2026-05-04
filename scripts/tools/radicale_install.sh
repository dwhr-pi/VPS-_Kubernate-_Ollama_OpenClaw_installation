#!/bin/bash
set -euo pipefail
TOOL_NAME="Radicale"
TOOL_KEY="Radicale"
TOOL_SLUG="radicale"
TOOL_PACKAGES="radicale"
TOOL_DESCRIPTION="Leichter CalDAV- und CardDAV-Server für lokale Kalender- und Kontakt-Synchronisation."
TOOL_OPENCLAW_NOTE="Passt zu Office- und persönlichen Agentenprofilen. Externe Freigabe nur mit Reverse Proxy und Auth."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
