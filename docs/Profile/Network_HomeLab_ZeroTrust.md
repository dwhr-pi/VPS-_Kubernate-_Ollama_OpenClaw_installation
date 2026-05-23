# Network HomeLab ZeroTrust

Status: `planned`  
Hardwarebedarf: `low` bis `server`  
Installationsart: MiniPC, VPS, Raspberry Pi, WSL2 eingeschraenkt

## Zweck

FritzBox-/HomeLab-Dokumentation, Zero-Trust-Zugriff, DNS-Schutz, Monitoring und sichere Remote-Zugaenge.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| Tailscale | privater Remote-Zugriff | empfohlen |
| Headscale | self-hosted Tailscale-Controlplane | optional |
| cloudflared | Cloudflare Tunnel/Access | empfohlen |
| Uptime Kuma/Netdata | Healthchecks und Monitoring | empfohlen |
| Pi-hole/AdGuard Home | DNS-Schutz | optional |

## Sicherheitsregeln

- Admin-UIs nie direkt oeffentlich freigeben.
- Tailscale/Cloudflare Access vor WebUIs.
- Nmap nur im eigenen Netz und defensiv dokumentieren.
