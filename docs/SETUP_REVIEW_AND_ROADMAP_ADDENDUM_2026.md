# Setup Review and Roadmap Addendum 2026

Dieses Addendum ergaenzt `docs/SETUP_REVIEW_AND_ROADMAP.md`, ohne den bestehenden Review zu ersetzen.

## Zusaetzliche Prioritaeten

- Aider, OpenCode, GitHub CLI, Podman, Clawbake als optionale Developer-Pfade dokumentieren.
- LangGraph, CrewAI, AutoGen als Agent-Frameworks mit Tool-Gates dokumentieren.
- Authentik/Authelia/OIDC als optionaler SSO-Pfad hinter Reverse Proxy aufnehmen.
- Tool-Lifecycle fuer `--dry-run`, `--status`, `--repair`, Smoke-Test und Logs schrittweise nachziehen.
- K3s/Argo CD/Renovate nur fuer VPS/Homelab mit Backup und Rollback.

## Sicherheitslinie

- Keine Secrets ins Repo.
- Dienste lokal auf `127.0.0.1`.
- Schwere Tools nie automatisch installieren.
- Agenten bleiben read-only, bis eine Freigabe erfolgt.
