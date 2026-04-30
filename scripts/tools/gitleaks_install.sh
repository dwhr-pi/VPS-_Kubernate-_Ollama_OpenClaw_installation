#!/bin/bash
TOOL_NAME="Gitleaks"
TOOL_KEY="Gitleaks"
TOOL_SLUG="gitleaks"
TOOL_DESCRIPTION="Secrets-Scanner für Repositories, Historie und Dateien."
TOOL_MODULE_TYPE="Security-Scanner-Scaffold"
TOOL_GIT_REPO="https://github.com/gitleaks/gitleaks.git"
TOOL_APT_PACKAGES="git golang-go make"
TOOL_POST_INSTALL='make build && sudo install -m 0755 gitleaks /usr/local/bin/gitleaks'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Gitleaks

```txt
Scanne dieses Setup auf versehentlich eingecheckte Secrets und formuliere konkrete Gegenmaßnahmen für den Benutzer-Workspace und das Git-Repository.
```'
TOOL_OPENCLAW_NOTE="Gitleaks ist der passende Secrets-Scanner für Repo- und CI-nahe Sicherheitsprüfungen im Plattform-Setup."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
