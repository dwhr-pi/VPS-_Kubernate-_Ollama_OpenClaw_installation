# GitHub Contribution and Branch Protection

## Pull Requests

Dieses Projekt nutzt das klassische GitHub-Pull-Request-Modell. Beitraege sollen bevorzugt ueber Forks, Feature-Branches und Pull Requests eingereicht werden. Direkte Pushes auf `main` sollen moeglichst vermieden werden.

## Externe Beitraege

Externe Mitwirkende benoetigen normalerweise keine direkten Schreibrechte.

Typischer Ablauf:

1. Repository forken
2. Feature-Branch erstellen
3. Aenderungen lokal oder im Fork durchfuehren
4. Pull Request gegen `main` oeffnen
5. Review, Diskussion und Anpassungen
6. Merge nach Freigabe

## Branch-Namen

- `feature/<name>`
- `docs/<name>`
- `fix/<name>`
- `experimental/<name>`

## Branch-Schutz

Empfohlene GitHub Branch Protection Rules fuer `main`:

- direkte Pushes deaktivieren
- Merge nur per PR
- Reviews verlangen
- optional CI/Checks verlangen
- Force-Push verbieten
- Branch-Loeschung verhindern

Diese Regeln werden nicht per Setup-Skript erzwungen. Sie sollen bewusst in GitHub aktiviert werden.

## Sicherheitsregeln

Nicht erlaubt:

- echte API-Keys
- echte Tokens
- Passwoerter
- produktive Secrets
- private SSH-Keys
- sensible personenbezogene Daten

Stattdessen:

- `.env.example`
- Platzhalter
- lokale User-Dateien ausserhalb des Repositories

## Projektziel

Modulares, sicheres, lokales und erweiterbares KI-/Agenten-/Homelab-/VPS-System mit Ollama, OpenClaw, Kubernetes/K3s, Podman, LangGraph, CrewAI, AutoGen, n8n und lokalen Open-Source-Komponenten.
