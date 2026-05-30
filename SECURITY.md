# Security Policy

## Grundsatz

Dieses Projekt ist local-first und sicherheitsbewusst. Es akzeptiert keine echten Secrets im Repository.

## Nicht erlaubt

- echte API-Keys
- Tokens
- Passwoerter
- private SSH-Keys
- produktive `.env`
- sensible personenbezogene Daten

## Meldung von Sicherheitsproblemen

Bitte keine sensiblen Details in oeffentlichen Issues posten. Erstelle stattdessen einen privaten Kontaktweg ueber den Maintainer oder einen minimalen, nicht-ausnutzbaren Hinweis im Issue.

## Erwartete Defaults

- Dienste binden lokal an `127.0.0.1`.
- Remotezugriff bevorzugt via WireGuard/Tailscale oder bewusst gehaertetem Reverse Proxy.
- Cloudflare Access/Tunnel ist optional, aber nicht Pflichtbestandteil.
- Docker-/Podman-Sockets nicht oeffentlich freigeben.
- Agenten standardmaessig read-only.
- Schreibende Aktionen nur mit Human Approval.

## Besonders sensible Bereiche

- `scripts/security/`
- `scripts/tools/`
- `scripts/wireguard/`
- `tools/mail/`
- `config/`
- `.github/`

Fuer diese Bereiche sollen PRs besonders sorgfaeltig geprueft werden.

## Security PRs

Security-PRs sind willkommen, wenn sie defensiv, autorisiert und nachvollziehbar sind.
