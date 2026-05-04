#!/bin/bash
set -euo pipefail
TOOL_NAME="PlatformIO"
TOOL_KEY="PlatformIO"
TOOL_SLUG="platformio"
TOOL_PACKAGES="platformio"
TOOL_DESCRIPTION="IoT- und Embedded-Toolchain für ESP32-, Arduino- und Edge-AI-Projekte."
TOOL_OPENCLAW_NOTE="Passt zu Smart-Home-, Robotics- und Edge-AI-Profilen. Hardware-Zugriffe nur bewusst auf echten Geräten verwenden."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
