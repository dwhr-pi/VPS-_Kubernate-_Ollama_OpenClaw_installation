# Contributing

Pull Requests sind willkommen. Dieses Projekt nutzt bevorzugt das klassische GitHub-Modell:

1. Repository forken
2. Feature-Branch erstellen
3. Aenderungen im Fork oder lokal durchfuehren
4. Pull Request gegen `main` oeffnen
5. Review, Diskussion und Anpassungen
6. Merge nach Freigabe

Direkte Pushes auf `main` sollen moeglichst vermieden werden.

## Empfohlene Branch-Namen

- `feature/<name>` fuer Features
- `docs/<name>` fuer Dokumentation
- `fix/<name>` fuer Fehlerbehebungen
- `experimental/<name>` fuer Experimente

Beispiele:

- `feature/langgraph-tools`
- `docs/security-model`
- `fix/openclaw-token-check`
- `experimental/voice-agents`

## Willkommen

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

## Sicherheitsregeln

Nicht committen:

- echte API-Keys
- echte Tokens
- Passwoerter
- produktive Secrets
- private SSH-Keys
- sensible personenbezogene Daten

Nutze stattdessen:

- `.env.example`
- Platzhalter
- lokale User-Dateien ausserhalb des Repositories

## Entwicklungsprinzipien

- read-only-first
- dry-run-first
- least privilege
- local-first
- keine autonomen Schreibaktionen ohne Zustimmung
- keine offenen Container-Sockets
- keine ungeschuetzten oeffentlichen APIs

## Vor groesseren PRs

- vorhandene Dokumentation lesen
- bestehende Struktur beachten
- aehnliche Tools/Profile pruefen
- Sicherheitsmodell respektieren
- neue Integrationen dokumentieren
- keine schweren Installer ohne Opt-in einfuehren
