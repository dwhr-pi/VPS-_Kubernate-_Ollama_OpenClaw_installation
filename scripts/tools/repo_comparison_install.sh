#!/bin/bash
TOOL_NAME="Repo_Comparison"
TOOL_KEY="Repo_Comparison"
TOOL_SLUG="repo_comparison"
TOOL_DESCRIPTION="Vergleichsmodul für Repositories, Diffs, Features und Strukturähnlichkeiten."
TOOL_MODULE_TYPE="Research-Modul"
TOOL_OPENCLAW_NOTE="Nützlich für Research_Agent und Programmiererprofil zur Produkt- und Codebasisanalyse."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
