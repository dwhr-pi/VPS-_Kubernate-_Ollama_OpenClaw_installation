# Profil: AI_Project_Manager

## Zweck

Projektplanung, Repo-Hygiene, Releases, lokale CI und Architekturentscheidungen fuer AI-/LLMOps-Repositories.

## Installierbare Kern-Tools

- `github_cli`
- `act`
- `pre_commit`
- `release_please`
- `changelog_generator`

## Optionale / noch nicht sauber verdrahtete Tools

- GitHub Issues/Projects als manueller Organisationslayer
- spaeter moeglich: `Taskfile`, `just`, `Linear`- oder `Notion`-Anbindung

## Hardware / Plattform

- sehr gut fuer `WSL2`, `MiniPC`, `VPS`
- kaum GPU-Bedarf

## Risiken und Grenzen

- keine GitHub-Tokens oder PATs ins Repo schreiben
- lokale CI mit `act` kann Secrets und Build-Artefakte beruehren

## Quickstart

```bash
bash scripts/profiles/AI_Project_Manager_install.sh
```
