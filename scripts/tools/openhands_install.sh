#!/bin/bash
TOOL_NAME="OpenHands"
TOOL_KEY="OpenHands"
TOOL_SLUG="openhands"
TOOL_DESCRIPTION="Offenes Software-Engineering-Agentensystem mit stärkerer Sandbox- und Arbeitsbereichs-Ausrichtung."
TOOL_MODULE_TYPE="Coding-Agent- und Sandbox-Scaffold"
TOOL_GIT_REPO="https://github.com/OpenHands/OpenHands.git"
TOOL_APT_PACKAGES="docker.io docker-compose-v2"
TOOL_ENV_TEMPLATE='OPENHANDS_LLM_PROVIDER=ollama
OPENHANDS_LLM_MODEL=devstral:24b
OLLAMA_HOST=http://127.0.0.1:11434'
TOOL_RUN_SCRIPT='#!/bin/bash
set -euo pipefail
echo "Prüfe README und Compose-Dateien im OpenHands-Repo. Für echte Sandbox-Läufe werden meist Docker und zusätzliche Konfiguration benötigt."'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für OpenHands

```txt
Bearbeite eine mehrstufige Repository-Aufgabe mit Branching, Testlauf und Change-Review in einer isolierten Sandbox.
```'
TOOL_OPENCLAW_NOTE="Passt als größerer Sandbox-Agentenlauf zum Codex-Nachbau. Für produktive Nutzung sind Docker, Modellzugang und Repo-spezifische Startkommandos wichtig."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
