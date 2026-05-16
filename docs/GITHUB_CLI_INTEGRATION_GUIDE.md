# GitHub CLI Integration Guide

## Zweck

GitHub CLI (`gh`) ist das zentrale Terminalwerkzeug fuer GitHub-nahe Arbeitsablaeufe:

- Repository-Status und Branches pruefen
- Issues und Pull Requests verwalten
- GitHub Actions ansehen
- Release- und Workflow-Informationen abrufen
- spaeter OpenClaw-/Codex-aehnliche Repo-Automation unterstuetzen

Im Setup wird `GitHub_CLI` als optionales Coding-/DevOps-Tool installiert.

## Installation im Setup

Der Installer klont das offizielle GitHub-CLI-Repository nach `/opt/github_cli`, baut `gh` und installiert das Binary nach `/usr/local/bin/gh`.

Wenn eine alte oder abgebrochene Installation `/opt/github_cli` mit Root-Rechten angelegt hat, kann eine alte Helper-Version mit folgendem Fehler abbrechen:

```txt
rm: cannot remove '/opt/github_cli': Permission denied
```

Aktueller Fix:

- Der gemeinsame Scaffold-Helper entfernt alte `/opt/<tool>`-Reste mit `sudo`.
- Der Loeschpfad ist auf sichere Ziele wie `/opt/*` oder den User-Home-Bereich begrenzt.
- Im neuen Installationslog muss erscheinen: `Scaffold-Helper: sichere /opt-Aufraeumroutine aktiv.`

Wenn diese Zeile fehlt, wurde noch eine alte Setup-Kopie gestartet.

## Schnelltest

```bash
gh --version
gh auth status
```

Wenn `gh auth status` noch nicht angemeldet ist, interaktiv anmelden:

```bash
gh auth login
```

Tokens duerfen nicht ins Repository. Wenn ein Token noetig ist, gehoert er in den sicheren User-Bereich oder in den GitHub-CLI-Keyring/Host-Speicher, nicht in `.env` im Repo.

## Typische Nutzung

```bash
cd ~/openclaw_ultimate_setup
git status --short
gh repo view
gh issue list
gh pr list
gh run list
```

## Kombinationen

- `Aider` und `OpenCode`: Coding-Agenten koennen nach lokalen Aenderungen PR-Kontext und Issue-Informationen ueber `gh` bekommen.
- `OpenClaw`: spaeter als erlaubtes Tool fuer Issues, PRs und Actions nutzbar.
- `act`: lokale GitHub-Actions-Tests ergaenzen die echten `gh run`-Informationen.
- `scripts/doctor.sh`: kann `gh --version` und Auth-Status pruefen.

## Sicherheitsregeln

- Keine Tokens in Logs, Markdown, `.env` oder Prompts kopieren.
- Vor Push/PR immer `git diff` und `git status --short` pruefen.
- Automatische PR-/Issue-Aktionen nur nach expliziter Freigabe.
- Auf VPS/Shared-Systemen besonders vorsichtig mit `gh auth login`, weil Zugangsdaten benutzerspezifisch gespeichert werden.

## TODO fuer OpenClaw

- Wrapper `scripts/github_cli/gh_safe.sh` mit erlaubten Unterbefehlen erstellen.
- Read-only Default fuer `repo view`, `issue list`, `pr list`, `run list`.
- Schreibende Aktionen wie `pr create`, `issue edit`, `workflow run` nur nach expliziter Freigabe.
- Doctor-Check fuer `gh --version` und optional `gh auth status`.
