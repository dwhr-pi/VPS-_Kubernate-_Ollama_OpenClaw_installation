#!/bin/bash
TOOL_NAME="Code_Sandbox"
TOOL_KEY="Code_Sandbox"
TOOL_SLUG="code_sandbox"
TOOL_DESCRIPTION="Lokal vorbereitetes Sandbox-Modul für isolierte Codeausführung, Tests und agentische Sicherheitsgrenzen."
TOOL_MODULE_TYPE="Sicherheits- und Workflow-Modul"
TOOL_OPENCLAW_NOTE="Gedacht als sicherer Ausführungsbaustein für OpenClaw, Programmierer- und Security-Workflows."
TOOL_ENV_TEMPLATE='SANDBOX_RUNTIME=docker\nSANDBOX_TIMEOUT_SECONDS=30\nSANDBOX_MEMORY_LIMIT=1g'
TOOL_RUN_SCRIPT='#!/bin/bash\nset -euo pipefail\necho "Nutze Docker-Container oder ein eigenes Jail-System als Sandbox-Backend."'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
