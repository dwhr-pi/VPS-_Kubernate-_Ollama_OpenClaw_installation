#!/bin/bash
TOOL_NAME="ControlNet"
TOOL_KEY="ControlNet"
TOOL_SLUG="controlnet"
TOOL_PACKAGES="diffusers controlnet-aux transformers accelerate safetensors"
TOOL_DESCRIPTION="ControlNet-Helfer für konditionierte Bildpipelines."
TOOL_OPENCLAW_NOTE="Ergänzt Visual- und Media-Pipelines mit stärker steuerbarer Bildgenerierung."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
