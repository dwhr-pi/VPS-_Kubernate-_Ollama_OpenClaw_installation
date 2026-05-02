# Profil: Repo_Maintainer

## Zweck
Profil für GitHub-Repo-Pflege, Lints, Releases, Pre-Commit und lokale CI-Prüfungen.

## Use Cases
- Pull Requests prüfen
- Release-Arbeit
- Shell-/Markdown-/Action-Linting
- lokale CI-Nachbildung

## Enthaltene Tools
- GitHub CLI
- pre-commit
- act
- markdownlint
- shellcheck
- shfmt
- hadolint
- actionlint
- release-please
- changelog-generator

## Installation
```bash
scripts/profiles/Repo_Maintainer_install.sh
```

## Ports
- keine festen Ports nötig

## Modelle
- optional lokale Coding-Modelle

## Abhängigkeiten
- Git
- Docker für `act`

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: ab 10 GB

## Sicherheitshinweise
- Release- und GitHub-Token nie im Repo ablegen
- Secret-Scans vor Commit ausführen

## Start / Stop / Status Befehle
```bash
gh --version 2>/dev/null || true
act --version 2>/dev/null || true
shellcheck --version 2>/dev/null || true
```

## Test-Command
```bash
bash scripts/profiles/Repo_Maintainer_install.sh
```

## Deinstallation
```bash
scripts/profiles/Repo_Maintainer_uninstall.sh
```
