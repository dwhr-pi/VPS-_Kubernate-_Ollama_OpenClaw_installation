#!/bin/bash
TOOL_NAME="Postgres"
TOOL_KEY="Postgres"
APT_PACKAGES="postgresql postgresql-contrib"
TOOL_ENABLE_SERVICE="postgresql"
TOOL_DESCRIPTION="PostgreSQL für strukturierte Workflow-Daten, Integrationen und Agenten-Backends."
TOOL_OPENCLAW_NOTE="Geeignet für größere OpenClaw-Setups, Marketing-Daten und Orchestrierungszustände."
source "$(dirname "$0")/helpers/apt_tool_common.sh"
install_apt_tool
