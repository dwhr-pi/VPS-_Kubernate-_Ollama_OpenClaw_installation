# Web App Builder

Profil fuer lokale WebUIs, Dashboards, Admin-Panels und interne KI-Apps mit Node.js, pnpm, Vite/React und optional Next.js.

## Fokus

- OpenClaw/Codex fuer Codegenerierung und Review
- n8n/API-Anbindung, Grafana oder eigene Dashboards
- Security-Checks mit gitleaks, semgrep und trivy
- lokale Entwicklung vor Deployment

## Sicherheit

Keine echten Secrets in Frontend-Code, `.env.example` und echte `.env` sauber trennen, Admin-UIs nicht offen ins Internet stellen.

## Installation

```bash
bash scripts/profiles/Web_App_Builder_install.sh
```
