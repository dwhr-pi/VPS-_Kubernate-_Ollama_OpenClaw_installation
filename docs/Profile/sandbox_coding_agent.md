# sandbox_coding_agent

## Zweck

Stellt einen produktiven Coding-Agent-Stack mit Sandbox, GitHub-Workflow und lokalem oder hybridem Modellzugriff bereit.

## Use Cases

- Repository-Analyse
- Multi-File-Edits
- Build-/Test-Sandboxes
- Branch-/PR-Workflows

## Enthaltene Tools

- `Aider`
- `OpenHands`
- `OpenCode`
- `Continue_Dev`
- `GitHub_CLI`
- `Docker`
- `Podman`
- `Code_Sandbox`

## Installation

```bash
scripts/tools/aider_install.sh
scripts/tools/openhands_install.sh
scripts/tools/opencode_install.sh
scripts/tools/continue_dev_install.sh
scripts/tools/github_cli_install.sh
scripts/tools/docker_install.sh
scripts/tools/podman_install.sh
scripts/tools/code_sandbox_install.sh
```

## Ports

- projektabhängig

## Modelle

- `qwen2.5-coder:7b`
- `qwen3-coder:30b`
- `devstral:24b`
- `codestral:22b`

## Abhängigkeiten

- Ollama
- Git
- Docker oder Podman

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: mittel bis hoch
- RAM: ab 16 GB, für große Coding-Modelle ab 32 GB
- Storage: je nach Repos und Container-Images ab 20 GB

## Sicherheitshinweise

- Sandbox niemals mit unnötigen Host-Rechten starten
- private Repos und Secrets vom Agentenlauf trennen

## Start / Stop / Status Befehle

```bash
gh --version
docker ps
podman ps
```

## Test-Command

```bash
gh repo view || true
```

## Deinstallation

```bash
scripts/tools/aider_uninstall.sh
scripts/tools/openhands_uninstall.sh
scripts/tools/opencode_uninstall.sh
scripts/tools/continue_dev_uninstall.sh
scripts/tools/github_cli_uninstall.sh
scripts/tools/docker_uninstall.sh
scripts/tools/podman_uninstall.sh
scripts/tools/code_sandbox_uninstall.sh
```
