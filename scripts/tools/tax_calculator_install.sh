#!/bin/bash
TOOL_NAME="Tax_Calculator"
TOOL_KEY="Tax_Calculator"
TOOL_SLUG="tax_calculator"
TOOL_DESCRIPTION="Scaffold-Modul für steuerliche Berechnungsvorlagen und Kontrollpunkte."
TOOL_MODULE_TYPE="Rechts-Workflow-Modul"
TOOL_OPENCLAW_NOTE="Dient im Rechtsberatung_Steuerrecht-Profil als lokaler Platzhalter für steuerliche Kalkulationslogik."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
