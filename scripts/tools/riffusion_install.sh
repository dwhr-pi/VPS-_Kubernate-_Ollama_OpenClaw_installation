#!/bin/bash
TOOL_NAME="Riffusion"
TOOL_KEY="Riffusion"
TOOL_SLUG="riffusion"
TOOL_PACKAGES="diffusers transformers accelerate safetensors"
TOOL_DESCRIPTION="Experimenteller Audio-Generierungsbaustein im Stil von Riffusion."
TOOL_OPENCLAW_NOTE="Ergänzt Media_Musik um spektrogramm-basierte Audioexperimente."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
