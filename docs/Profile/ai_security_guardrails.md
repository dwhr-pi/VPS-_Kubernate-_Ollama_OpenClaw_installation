# ai_security_guardrails

## Zweck

Härtet Modellzugriffe, Prompts, Secrets und Tool-Nutzung für produktionsreife Agentenplattformen.

## Use Cases

- Prompt-Injection-Schutz
- Output-Validierung
- Secrets-Scanning
- Container- und Repo-Sicherheit

## Enthaltene Tools

- `Guardrails_AI`
- `Promptfoo`
- `Trivy`
- `Gitleaks`
- `Fail2Ban`

## Installation

```bash
scripts/tools/guardrails_ai_install.sh
scripts/tools/promptfoo_install.sh
scripts/tools/trivy_install.sh
scripts/tools/gitleaks_install.sh
scripts/tools/fail2ban_install.sh
```

## Ports

- keine festen Pflichtports

## Modelle

- modellunabhängig

## Abhängigkeiten

- Python
- Node.js
- Docker für Container-Scans

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: gering bis moderat

## Sicherheitshinweise

- Secrets nie im Repo
- Red-Teaming nur auf eigenen Systemen
- Guardrails nicht als Ersatz für Netzwerkgrenzen betrachten

## Start / Stop / Status Befehle

```bash
trivy --help
gitleaks version
```

## Test-Command

```bash
gitleaks detect --no-git --source .
```

## Deinstallation

```bash
scripts/tools/guardrails_ai_uninstall.sh
scripts/tools/promptfoo_uninstall.sh
scripts/tools/trivy_uninstall.sh
scripts/tools/gitleaks_uninstall.sh
scripts/tools/fail2ban_uninstall.sh
```
