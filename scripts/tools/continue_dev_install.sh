#!/bin/bash
TOOL_NAME="Continue_Dev"
TOOL_KEY="Continue_Dev"
TOOL_SLUG="continue_dev"
TOOL_DESCRIPTION="Open-Source Coding-Assistant-Workspace von Continue für IDE- und Agenten-Workflows."
TOOL_MODULE_TYPE="Coding-Assistant-Scaffold"
TOOL_GIT_REPO="https://github.com/continuedev/continue.git"
TOOL_APT_PACKAGES="git nodejs npm"
TOOL_POST_INSTALL='if [ -f package.json ]; then
  echo "Continue.dev: installiere Node-Abhaengigkeiten mit npm."
  echo "Hinweis: npm-Warnungen zu deprecated Paketen oder npm audit stammen aus dem Upstream-Abhaengigkeitsbaum."
  echo "Sie sind kein Installationsabbruch, solange npm install mit Exitcode 0 endet."
  npm install
  echo "Optionaler Audit-Hinweis: Details koennen spaeter manuell mit npm audit in /opt/continue_dev geprueft werden."
fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Continue.dev

```txt
Nutze Continue.dev mit einem lokalen Ollama-Modell, um Repository-Fragen, Refactorings und Multi-File-Änderungen in einer Editor-Umgebung zu unterstützen.
```'
TOOL_OPENCLAW_NOTE="Continue.dev ergänzt den Codex-Nachbau für editornahe Entwicklung. Die eigentliche IDE-Integration hängt vom späteren Client-System ab."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
