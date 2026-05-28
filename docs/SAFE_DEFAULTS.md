# Safe Defaults

## Netzwerk

- Dienste standardmaessig nur an `127.0.0.1` binden.
- Remotezugriff nur ueber Tailscale, Cloudflare Access oder Reverse Proxy mit Auth.
- Keine offenen Admin-Ports fuer Grafana, Open WebUI, n8n, Node-RED, Paperless, Nextcloud oder Kubernetes.

## Secrets

- Keine API-Keys, Tokens, Passwoerter oder `.env`-Dateien ins Repo.
- `.env.example` und Benutzerkonfigurationen unter `~/.openclaw_ultimate_user_data` verwenden.
- Diagnoseberichte vor Versand redigieren oder verschluesseln.

## Human Approval

- Security-, Smart-Home-, Trading-, Robotik-, Browser-Agenten-, E-Mail- und Shell-Aktionen brauchen Freigabe.
- Keine automatischen Zahlungen, Trades, Tueroeffnungen, Firewall-Aenderungen oder Deployments.

## Installationen

- Schwere Tools nie automatisch installieren.
- Vor grossen Tools RAM, Swap, Linux-Speicher und unter WSL2 Windows-C:-Speicher pruefen.
- Nach Fehlern Batch stoppen, Log/Diagnose anbieten und nicht blind zum naechsten schweren Tool springen.

## Cleanup

- Immer erst `--dry-run`.
- Docker-Volumes und Userdaten nie automatisch loeschen.
- `/opt`-Toolreste nur einzeln bestaetigen.
