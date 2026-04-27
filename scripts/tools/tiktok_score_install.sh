#!/bin/bash
TOOL_NAME="TikTok_Score"
TOOL_KEY="TikTok_Score"
TOOL_SLUG="tiktok_score"
TOOL_DESCRIPTION="Heuristik-Modul für Viralitäts- und Kurzvideo-Scoring."
TOOL_MODULE_TYPE="Analysemodul"
TOOL_OPENCLAW_NOTE="Kann Content- und Media-Pipelines priorisieren, bevor Assets veröffentlicht werden."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
