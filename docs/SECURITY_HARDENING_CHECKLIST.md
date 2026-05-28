# Security Hardening Checklist

## Repo und Secrets

- Keine echten `.env`-Dateien committen.
- `.env.example` statt produktiver Werte.
- Gitleaks/Trivy/Semgrep vor Releases ausfuehren.
- Support-E-Mails vor Versand redigieren oder verschluesseln.

## Netzwerk

- Admin-UIs default auf `127.0.0.1`.
- Remote nur ueber Tailscale, Cloudflare Access oder Reverse Proxy mit Auth.
- Port-Matrix vor jedem neuen Dienst pruefen.

## Agenten

- Shell, Docker, Git, Smart Home, E-Mail, Trading und Security nur mit Human Approval.
- Multi-Agent-Flows brauchen Abbruchbedingungen und Kostenlimits.
- Browser-/Scraping-Profile nur mit Allowlist und Rate-Limits.

## Betrieb

- Backups testen, nicht nur erstellen.
- Docker-Volumes nicht automatisch loeschen.
- Schwergewichtige Tools einzeln installieren und Messwerte notieren.
