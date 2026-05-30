# DNS und DDoS Guide

Standard ist Hurricane Electric DNS/DDNS plus Oracle VPS und WireGuard.
Cloudflare ist optional, aber kein Pflichtpfad.

## Regeln

- Nur notwendige Hostnamen veroeffentlichen.
- Keine Admin-Panels oeffentlich.
- SSH nur per WireGuard/Tailscale/Allowlist.
- Reverse Proxy nur fuer notwendige Dienste.
- Rate-Limits aktivieren.
- UFW/nftables, CrowdSec und Fail2Ban nutzen.

## DDoS-Hinweis

HE DNS ist kein vollstaendiger DDoS-Schutz. Fuer groessere Angriffe braucht es
Provider-Massnahmen, Scrubbing oder BGP-Mitigation.
