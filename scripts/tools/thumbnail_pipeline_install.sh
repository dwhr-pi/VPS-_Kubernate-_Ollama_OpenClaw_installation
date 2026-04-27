#!/bin/bash
TOOL_NAME="Thumbnail_Pipeline"
TOOL_KEY="Thumbnail_Pipeline"
TOOL_SLUG="thumbnail_pipeline"
TOOL_DESCRIPTION="Bild- und Thumbnail-Pipeline für Content-Automation und visuelle Publishing-Flows."
TOOL_MODULE_TYPE="Workflow-Modul"
TOOL_OPENCLAW_NOTE="Gedacht für Content_Automation zusammen mit Stable Diffusion, ComfyUI und RealESRGAN."
TOOL_PROMPT_EXAMPLE=$'# Beispielprompts für Thumbnail_Pipeline\n\n```txt\nErzeuge eine YouTube-Thumbnail-Pipeline mit Bildgenerierung, Textoverlay und Upscaling.\n```'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
