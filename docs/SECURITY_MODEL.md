# Security Model

## Defaults

- Keine API-Keys im Repo.
- `.env.example` statt echter `.env`.
- Secrets unter `~/.openclaw_ultimate_user_data/`.
- Services lokal auf `127.0.0.1`.
- Remotezugriff nur via Tailscale, Cloudflare Access oder bewusst gehaertetem Reverse Proxy.
- Keine offenen Podman-/Docker-Sockets.
- Agenten standardmaessig read-only.

## Human Approval

Pflicht fuer:

- schreibende Systemaktionen
- Install/Update/Uninstall
- Cloud-/API-Aufrufe
- Smart Home
- Security-Aktionen
- Browser-Agenten
- Kubernetes/Podman/Docker-Aenderungen

## Diagnose

Secret-Scan und Port-Audit sind read-only. Funde werden gemeldet, nicht automatisch repariert.
