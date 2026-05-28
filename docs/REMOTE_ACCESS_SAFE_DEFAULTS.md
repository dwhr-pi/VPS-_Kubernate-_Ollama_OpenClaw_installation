# Remote Access Safe Defaults

## Grundregel

Dienste binden standardmaessig an `127.0.0.1`. Oeffentliche Freigaben werden nicht automatisch erzeugt.

## Empfohlen

- Adminzugriff: Tailscale.
- Oeffentlicher Webzugriff: Cloudflare Tunnel plus Cloudflare Access.
- Reverse Proxy nur mit HTTPS, Auth, Rate-Limits und Logging.

## Nicht empfohlen

- Admin-UIs direkt auf `0.0.0.0` freigeben.
- Datenbankports oeffentlich expose'n.
- Docker Socket remote freigeben.
- Kubernetes Dashboard oeffentlich freigeben.

## Mindestcheck

- Port-Matrix pruefen.
- Firewall-Regeln pruefen.
- Auth aktivieren.
- Logs aktivieren.
- Backup vor Remote-Freigabe.
