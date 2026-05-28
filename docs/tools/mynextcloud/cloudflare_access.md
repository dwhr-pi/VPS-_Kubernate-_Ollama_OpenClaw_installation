# Cloudflare Access fuer myNextCloud

## Empfehlung

Oeffentlicher Webzugriff nur mit Cloudflare Tunnel plus Cloudflare Access.

## Regeln

- Admin-Bereiche zusaetzlich schuetzen.
- One-Time-PIN oder Identity Provider erzwingen.
- WAF und Rate-Limits aktivieren.
- Keine Direktfreigabe von Datenbank, SSH, n8n oder Admin-Ports.

## Konzept

```text
Internet -> Cloudflare Access -> Tunnel -> 127.0.0.1:myNextCloud
```

## Secrets

Tunnel-Tokens niemals ins Repo. Konfiguration unter `~/.openclaw_ultimate_user_data`.
