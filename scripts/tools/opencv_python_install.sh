#!/bin/bash
set -euo pipefail
TOOL_NAME="OpenCV Python"
TOOL_KEY="OpenCV_Python"
TOOL_SLUG="opencv_python"
TOOL_PACKAGES="opencv-python"
TOOL_DESCRIPTION="Computer-Vision-Bibliothek für Kamera-, Bild- und Edge-AI-Workflows."
TOOL_OPENCLAW_NOTE="Ergänzt Robotics-, Browser- und Dokument-Workflows bei lokaler Bildanalyse."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
