# Security Baseline Next Level

## Harte Defaults

- Ollama, OpenClaw, Home Assistant, Grafana, Qdrant, Datenbanken und Kubernetes API nicht oeffentlich freigeben.
- Standardbindung: `127.0.0.1`.
- Externe Freigabe nur ueber WireGuard, Tailscale oder Reverse Proxy mit Auth.
- Keine Tokens in Logs, Markdown-Beispielen oder Queue-Kommandos.
- `scripts/check_secrets.sh --dry-run` vor Commits nutzen.
