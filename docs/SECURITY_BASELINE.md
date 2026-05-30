# Security Baseline

## Standardregeln

- Keine echten Secrets ins Repository.
- Nur `.env.example`, echte `.env` unter `~/.openclaw_ultimate_user_data` oder lokalen Servicepfaden.
- Dienste standardmaessig nur auf `127.0.0.1` binden.
- Admin-UIs nie direkt ins Internet freigeben.
- Remote-Zugriff nur via Tailscale, Cloudflare Access oder Reverse Proxy mit Auth.
- Installationslogs muessen Tokens, Cookies und Passwoerter redigieren.
- Trading, Security, Robotik und Smart Home brauchen Human-Approval-Gates.

## Ports

- Oeffentliche Ports muessen in `docs/PORT_SECURITY_MATRIX.md` dokumentiert sein.
- Neue Tools duerfen keine Wildcard-Bindings als Default setzen.

## Agenten mit Shell-Zugriff

- Shell-Zugriff nur lokal und protokolliert.
- Keine destruktiven Befehle ohne explizite Freigabe.
- Kein automatisches Ausfuehren von Code aus unbekannten Repositories.
# Next-Level Safe Defaults

Diese Regeln gelten fuer neue Profile, Tools und Installer:

- Keine Secrets, Tokens, Private Keys oder echte `.env` ins Repository.
- `.env.example` bleibt Vorlage; echte `.env` gehoert nach `~/.openclaw_ultimate_user_data`.
- Dienste binden standardmaessig an `127.0.0.1`.
- Oeffentlicher Zugriff nur per Tailscale, Cloudflare Access oder bewusst gehärtetem Reverse Proxy.
- Keine Docker-Socket-, Kubernetes-Dashboard-, Datenbank- oder Admin-UI-Freigabe ins oeffentliche Internet.
- Schwere Tools brauchen Speicher/RAM/Swap-Preflight und explizite Zustimmung.
- Security-, Trading-, Robotik-, Smart-Home- und Browser-Agenten brauchen Human Approval fuer schreibende oder externe Aktionen.
- Forks oder manipulierte Setup-Kopien erhalten keine automatische Selbstheilung ohne Herkunfts-/Integritaetspruefung.
# Zusatz 2026: HE/Oracle/WireGuard Standard

Cloudflare ist nicht mehr Pflichtbestandteil. Der empfohlene Standard ist:

- Hurricane Electric DNS/DDNS
- Oracle VPS als Control Node/DMZ
- WireGuard ins Heimnetz
- Raspberry Pi/Mini-PC als Heimnetz-Waechter
- CrowdSec/Fail2Ban/UFW oder nftables

Admin-Panels und sensible APIs duerfen nicht direkt oeffentlich erreichbar sein.

Weitere Details:

- [Hurricane Electric DNS/DDOS Guide](HURRICANE_ELECTRIC_DNS_DDOS_GUIDE.md)
- [Port Security Matrix](PORT_SECURITY_MATRIX.md)
- [HE/Oracle/Homecluster Start](architecture/he-oracle-homecluster.md)
