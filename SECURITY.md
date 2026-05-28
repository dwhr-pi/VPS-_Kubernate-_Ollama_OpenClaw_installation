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
- Remotezugriff nur via Tailscale, Cloudflare Access oder bewusst gehaertetem Reverse Proxy.
- Docker-/Podman-Sockets nicht oeffentlich freigeben.
- Agenten standardmaessig read-only.
- Schreibende Aktionen nur mit Human Approval.

## Security PRs

Security-PRs sind willkommen, wenn sie defensiv, autorisiert und nachvollziehbar sind.
