#!/bin/bash
TOOL_NAME="OpenCode"
TOOL_KEY="OpenCode"
TOOL_SLUG="opencode"
TOOL_DESCRIPTION="Offener Coding-Agent-Workspace mit Fokus auf lokale oder providerbasierte Modellanbindung, passend als Codex-ähnliche Ergänzung."
TOOL_MODULE_TYPE="Coding-Agent-Scaffold"
TOOL_GIT_REPO="https://github.com/sst/opencode.git"
TOOL_ENV_TEMPLATE='OPENCODE_PROVIDER=ollama
OPENCODE_MODEL=qwen3-coder:30b
OLLAMA_HOST=http://127.0.0.1:11434'
TOOL_RUN_SCRIPT='#!/bin/bash
set -euo pipefail
echo "Prüfe README, Package-Manager und Startkommando des geklonten OpenCode-Repos. Das genaue Startkommando kann sich upstream ändern."'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für OpenCode

```txt
Analysiere dieses Repository, schlage einen minimalen Patch vor und führe mich durch die Änderungen in mehreren Dateien.
```

```txt
Nutze Ollama mit qwen3-coder:30b als Hauptmodell und arbeite den Fehler im aktuellen Setup Schritt für Schritt ab.
```'
TOOL_OPENCLAW_NOTE="Gedacht als Codex-ähnlicher Coding-Agent über lokales Ollama oder andere Provider. Für stabile Nutzung zuerst README und Upstream-Startbefehl prüfen."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
