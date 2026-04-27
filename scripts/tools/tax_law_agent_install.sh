#!/bin/bash
TOOL_NAME="Tax_Law_Agent"
TOOL_KEY="Tax_Law_Agent"
TOOL_SLUG="tax_law_agent"
TOOL_DESCRIPTION="Profilmodul für steuerrechtliche Fragestellungen, Recherche und Entwurfshilfen."
TOOL_MODULE_TYPE="Agentenmodul"
TOOL_OPENCLAW_NOTE="Gedacht für das Rechtsberatung_Steuerrecht-Profil mit Ollama/OpenClaw als Kern."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
