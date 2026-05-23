# Zero Trust Remote Access

Profil fuer sicheren Remote-Zugriff auf Open WebUI, Grafana, Home Assistant, SSH, n8n und interne Dashboards.

## Fokus

- Tailscale fuer privaten Admin-Zugriff
- Cloudflare Tunnel nur fuer bewusst veroeffentlichte Dienste
- UFW, CrowdSec, Fail2ban und Auth-Schichten
- Port- und Expositionspruefung vor Freigabe

## Entscheidung

Standard ist: localhost oder privates Netz. Oeffentliche Tunnel nur mit Auth, Rollen, Logging und klarer Zieladresse.

## Installation

```bash
bash scripts/profiles/Zero_Trust_Remote_Access_install.sh
```
