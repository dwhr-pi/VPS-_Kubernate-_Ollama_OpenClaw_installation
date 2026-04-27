#!/bin/bash
TOOL_NAME="Image_Upscaler_Pipeline"
TOOL_KEY="Image_Upscaler_Pipeline"
TOOL_SLUG="image_upscaler_pipeline"
TOOL_DESCRIPTION="Workflow-Modul für Upscaling, Nachschärfen und Asset-Finalisierung."
TOOL_MODULE_TYPE="Workflow-Modul"
TOOL_OPENCLAW_NOTE="Bündelt RealESRGAN und weitere künftige Upscaler im Visual_Creator-Profil."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
