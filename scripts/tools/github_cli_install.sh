#!/bin/bash
TOOL_NAME="GitHub_CLI"
TOOL_KEY="GitHub_CLI"
TOOL_SLUG="github_cli"
TOOL_DESCRIPTION="GitHub CLI für Branches, Commits, Pull Requests, Actions und repo-nahe Entwicklerworkflows."
TOOL_MODULE_TYPE="GitHub-CLI-Scaffold"
TOOL_GIT_REPO="https://github.com/cli/cli.git"
TOOL_APT_PACKAGES="git golang-go make"
TOOL_POST_INSTALL='make bin/gh && sudo install -m 0755 bin/gh /usr/local/bin/gh'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für GitHub CLI

```txt
Erzeuge einen Feature-Branch, prüfe den Repo-Status und bereite einen Pull-Request-Workflow für diese Änderung vor.
```'
TOOL_OPENCLAW_NOTE="Ergänzt den Codex-Nachbau für Repo-Automation, PR-Flows und Sandbox-nahe Entwicklungsabläufe. Die Installation erfolgt direkt aus dem offiziellen GitHub-Quellrepo."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
