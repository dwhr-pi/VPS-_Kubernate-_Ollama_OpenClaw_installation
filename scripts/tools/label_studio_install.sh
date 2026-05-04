#!/bin/bash
set -euo pipefail
TOOL_NAME="Label Studio"
TOOL_KEY="Label_Studio"
TOOL_SLUG="label_studio"
TOOL_PACKAGES="label-studio"
TOOL_DESCRIPTION="Self-Hosted Annotation- und Labeling-Werkzeug für Text, Bild, Audio und Dokumente."
TOOL_OPENCLAW_NOTE="Hilfreich für Dataset-Kuration, Dokumentenannotation und Human-in-the-Loop-Workflows."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
