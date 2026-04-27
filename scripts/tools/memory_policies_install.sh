#!/bin/bash
TOOL_NAME="Memory_Policies"
TOOL_KEY="Memory_Policies"
TOOL_SLUG="memory_policies"
TOOL_DESCRIPTION="Policy-Sammlung für Agenten-Memory, Retention, Konfliktauflösung und Kontextübergaben."
TOOL_MODULE_TYPE="Konfigurationsmodul"
TOOL_OPENCLAW_NOTE="Ergänzt Qdrant, Weaviate, Redis und OpenClaw-Rollen mit klaren Memory-Policies."
TOOL_CONFIG_JSON='{\n  "retention": "task_scoped",\n  "conflict_resolution": "latest_verified_wins",\n  "dead_letter_policy": "manual_review"\n}'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
