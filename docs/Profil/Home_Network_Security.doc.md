# Fachprofil: Home_Network_Security

## Zweck

Defensives Profil fuer FRITZ!Box-, LAN-, WLAN-, DNS-, Pi-hole-/AdGuard-, Tailscale- und Cloudflare-Tunnel-Analyse. Es hilft, das eigene Heimnetz sichtbar und sicherer zu machen.

## Typische Aufgaben

- lokale Port- und Dienstuebersicht erstellen
- Tailscale-Subnet-Routes und Advertised Routes dokumentieren
- DNS- und Adblock-Setup pruefen
- UFW-/CrowdSec-/Fail2Ban-Status auswerten
- interne Dashboards nur auf `127.0.0.1`, LAN oder Tailnet begrenzen

## Empfohlene Tools

- `tailscale`
- `cloudflared`
- `ufw`
- `crowdsec`
- `prometheus`
- `grafana`
- optional Pi-hole, AdGuard Home, Zeek oder Suricata als Advanced-Modul

## Grenzen

Nur eigene Netze und erlaubte Geraete pruefen. Keine Scans fremder IP-Bereiche, keine Credential-Tests, keine Intrusion-Automation.

## Status

`beta`.
