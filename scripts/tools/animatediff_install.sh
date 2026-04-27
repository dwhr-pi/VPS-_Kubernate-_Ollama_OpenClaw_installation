#!/bin/bash
TOOL_NAME="AnimateDiff"
TOOL_KEY="AnimateDiff"
TOOL_SLUG="animatediff"
TOOL_PACKAGES="diffusers transformers accelerate safetensors"
TOOL_DESCRIPTION="Baustein für bewegte Diffusionssequenzen und visuelle Motion-Pipelines."
TOOL_OPENCLAW_NOTE="Ergänzt Visual_Creator für einfache lokale Bewegtbild-Experimente."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
