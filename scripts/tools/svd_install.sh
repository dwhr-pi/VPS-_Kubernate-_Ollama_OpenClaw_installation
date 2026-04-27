#!/bin/bash
TOOL_NAME="SVD"
TOOL_KEY="SVD"
TOOL_SLUG="svd"
TOOL_PACKAGES="diffusers transformers accelerate safetensors"
TOOL_DESCRIPTION="Scaffold für Stable Video Diffusion-nahe lokale Experimente."
TOOL_OPENCLAW_NOTE="Passt zum Visual_Creator-Profil für kurze Video- oder Motion-Prototypen."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
