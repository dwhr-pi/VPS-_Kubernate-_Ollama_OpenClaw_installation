# Local_Codex_IDE_Agent

## Zweck
Lokaler Coding-Agent mit Repo-Analyse, Patches, Testläufen, Dev-Containern und editornahen Workflows.

## Typische Aufgaben
- Multi-File-Refactorings
- Tests und Linting vor Commit
- reproduzierbare Sandbox-Läufe
- PR-nahe Review- und Fix-Zyklen

## Empfohlene Tools
Aider, OpenHands, Continue.dev, Dev Container CLI, act, pre-commit, GitHub CLI, ShellCheck, Ruff, Black, Prettier, ESLint, pytest.

## Optionale Tools
Tabby, code-server, Podman.

## Benötigte Ports
Keine Pflichtports, optional Editor-/Sandbox-Ports lokal binden.

## Ressourcenbedarf
8 GB RAM empfohlen, Docker für reproduzierbare Container-Workspaces.

## Sicherheitsrisiken
Schreibende Agenten nur auf Test-Repositories oder bewusst freigegebene Verzeichnisse loslassen. Keine Secrets im Workspace.

## Ollama/OpenClaw-Fit
Sehr gut für lokale Codex-/Agenten-Sandbox-Nachbauten und Repo-nahe Automatisierung.

## LiteLLM/Open WebUI-Fit
LiteLLM kann Modelle zentral bereitstellen; Open WebUI ist optional für Chat-Assistenz, aber nicht Kern des Profils.

## Quickstart
`bash scripts/profiles/Local_Codex_IDE_Agent_install.sh`

## Deinstallation
`bash scripts/profiles/Local_Codex_IDE_Agent_uninstall.sh`

## Sinnvolle lokale Modelle
`qwen2.5-coder`, `deepseek-coder`, `devstral`, `codestral`-ähnliche lokale Modelle.

## Grenzen und Warnhinweise
Agenten- und Patch-Workflows brauchen Review. Keine automatische Freigabe für produktive Deployments.
