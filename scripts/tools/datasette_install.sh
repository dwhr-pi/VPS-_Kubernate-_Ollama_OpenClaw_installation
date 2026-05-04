#!/bin/bash
set -euo pipefail
TOOL_NAME="Datasette"
TOOL_KEY="Datasette"
TOOL_SLUG="datasette"
TOOL_PACKAGES="datasette"
TOOL_DESCRIPTION="Leichte SQL- und Datenpublikations-Oberfläche für SQLite/DuckDB-nahe Analyse- und Archivdaten."
TOOL_OPENCLAW_NOTE="Sinnvoll für lokale Datenexploration, Agenten-Auswertungen und kleine BI-Sandboxes."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
