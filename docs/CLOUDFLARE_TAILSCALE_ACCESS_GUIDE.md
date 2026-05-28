# Cloudflare and Tailscale Access Guide

## Empfehlung

- Adminzugriff: Tailscale.
- Oeffentlicher Zugriff: Cloudflare Tunnel plus Cloudflare Access.
- Keine Admin-UIs direkt oeffentlich freigeben.

## Tailscale

Geeignet fuer:

- Setup-Admin
- SSH
- Grafana/Uptime Kuma intern
- myNextCloud Adminzugang
- Home Assistant Adminzugang

## Cloudflare Access

Geeignet fuer:

- geschuetzte Web-UIs
- One-Time-PIN oder Identity Provider
- WAF/Rate-Limits
- keine offenen Origin-Ports

## Nicht tun

- Datenbankports oeffentlich machen
- Docker Socket freigeben
- Kubernetes Dashboard oeffentlich machen
- API-Keys in Tunnel-Konfiguration committen
