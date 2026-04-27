#!/bin/bash
TOOL_NAME="Music2P_Pipeline"
TOOL_KEY="Music2P_Pipeline"
TOOL_SLUG="music2p_pipeline"
TOOL_DESCRIPTION="Workflow-Modul für musikgetriebene Prompt-, Prompt-to-Performance- oder Clip-Pipelines."
TOOL_MODULE_TYPE="Workflow-Modul"
TOOL_OPENCLAW_NOTE="Bündelt MusicGen, Riffusion und Analysebausteine für das Media_Musik-Profil."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
