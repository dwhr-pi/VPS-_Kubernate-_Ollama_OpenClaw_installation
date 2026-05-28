# VPS Safe Install Path

## Reihenfolge

1. SSH-Zugriff und Snapshot/Backup sichern.
2. UFW/Fail2Ban/Tailscale oder cloudflared vorbereiten.
3. Keine Admin-UIs oeffentlich starten.
4. Leichte Dienste installieren.
5. Monitoring und Backup pruefen.

## Empfohlen

- Tailscale oder Cloudflare Tunnel
- UFW, Fail2Ban, CrowdSec optional
- Uptime Kuma/Healthchecks
- Restic/Rclone
- Kleine Web-UIs nur hinter Auth

## Nicht empfohlen auf kleiner VPS

- ComfyUI, Forge, vLLM, Blender
- Airbyte ohne dedizierte Ressourcen
- offene Datenbank-, Grafana-, n8n- oder Open-WebUI-Ports
