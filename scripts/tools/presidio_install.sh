#!/bin/bash
set -euo pipefail
TOOL_NAME="Microsoft Presidio"
TOOL_KEY="Presidio"
TOOL_SLUG="presidio"
TOOL_PACKAGES="presidio-analyzer presidio-anonymizer"
TOOL_DESCRIPTION="PII-Erkennung und Anonymisierung für Text- und Dokument-Workflows."
TOOL_OPENCLAW_NOTE="Geeignet für DSGVO-nahe Verarbeitung, Redaction-Pipelines und sensible Agenten-Workflows."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
