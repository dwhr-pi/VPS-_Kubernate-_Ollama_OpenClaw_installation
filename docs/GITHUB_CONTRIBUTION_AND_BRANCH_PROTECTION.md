# GitHub Pull Requests, Contribution-Regeln und Branch-Schutz

Dieses Projekt nutzt das klassische GitHub-Pull-Request-Modell.

## Pull Requests

Beitraege sollen bevorzugt ueber:

- Forks
- Feature-Branches
- Pull Requests

eingereicht werden.

Direkte Pushes auf `main` sollen moeglichst vermieden werden.

## Ablauf fuer externe Beitraege

1. Repository forken.
2. Aenderungen lokal oder im Fork durchfuehren.
3. Feature-Branch erstellen.
4. Pull Request gegen `main` oeffnen.
5. Review, Diskussion und Anpassungen.
6. Merge nach Freigabe.

## PRs willkommen

- Dokumentation
- Sicherheitsverbesserungen
- neue Profile
- neue Tool-Integrationen
- Doctor-Checks
- Installer-Fixes
- Kubernetes/K3s-Erweiterungen
- Ollama/OpenClaw-Integrationen
- Monitoring/Observability
- VPS/Homelab-Optimierungen

## Empfohlene Branch-Namen

- `feature/<name>`
- `docs/<name>`
- `fix/<name>`
- `experimental/<name>`

Beispiele:

- `feature/langgraph-tools`
- `feature/monitoring-stack`
- `docs/security-model`
- `docs/k3s-guide`
- `fix/openclaw-token-check`
- `fix/podman-permissions`
- `experimental/autogen-workers`
- `experimental/voice-agents`

## Branch-Schutz fuer `main`

Empfohlene GitHub Branch Protection Rules:

- direkte Pushes deaktivieren
- Merge nur per Pull Request
- Reviews verlangen
- optional CI/Checks verlangen
- Force-Push verbieten
- Branch-Loeschung verhindern
- CODEOWNERS-Review fuer sensible Pfade aktivieren

## Sicherheitsregeln fuer Beitraege

Nicht erlaubt:

- echte API-Keys
- echte Tokens
- Passwoerter
- produktive Secrets
- private SSH-Keys
- sensible personenbezogene Daten

Verwende stattdessen:

- `.env.example`
- Platzhalter
- lokale User-Dateien ausserhalb des Repositories

## Standard-Sicherheitsmodell

Dieses Projekt verfolgt standardmaessig:

- read-only-first
- dry-run-first
- least-privilege
- lokale Dienste bevorzugt
- keine autonomen Schreibaktionen ohne Zustimmung
- keine offenen Container-Sockets
- keine ungeschuetzten oeffentlichen APIs

## Empfehlung fuer Mitwirkende

Vor einem groesseren PR:

- vorhandene Dokumentation lesen
- bestehende Struktur beachten
- aehnliche Tools/Profile pruefen
- Sicherheitsmodell respektieren
- neue Integrationen dokumentieren

## Hinweis

Dieses Projekt befindet sich in aktiver Entwicklung. Experimentelle Komponenten
koennen sich schnell aendern. Neue PRs, Ideen, Sicherheitsverbesserungen und
Dokumentationsverbesserungen sind willkommen.
