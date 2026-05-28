# myNextCloud Server: Oracle VPS

## Ziel
Sicherer VPS-Pfad mit HTTPS, Backup und eingeschraenktem Admin-Zugriff.

## Grundregeln

- HTTPS Pflicht.
- Admin bevorzugt nur ueber Tailscale.
- Oeffentlicher Zugriff nur ueber Cloudflare Access/WAF/Rate-Limits.
- UFW/Fail2Ban vor Webfreigabe konfigurieren.
- Backups vor Updates testen.

## Minimaler Ablauf

```bash
git clone https://github.com/dwhr-pi/myNextCloud-server.git
cd myNextCloud-server
git remote add upstream https://github.com/nextcloud/server.git || true
cp .env.example .env
```

Danach Webserver, PHP, Datenbank und Cron nach Nextcloud-kompatibler Anleitung konfigurieren. Docker/Compose bleibt optional und ist kein Pflichtpfad.

## Quellcodezugang

Wenn der modifizierte AGPL-Server oeffentlich angeboten wird, muss der passende Quellcodezugang dokumentiert werden, z. B. im Footer oder Impressum/Legal-Bereich.
