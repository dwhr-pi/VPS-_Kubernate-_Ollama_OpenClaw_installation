# VPS Oracle Cloud Free Guide

## Ziel

Oracle Free VPS kann fuer leichte Remote-Dienste, Monitoring, Tunnels, Backups und kleine Automationen dienen. Schwere KI-/GPU-/Kubernetes-Pfade sind nicht automatisch geeignet.

## Geeignet

- Tailscale/cloudflared
- UFW/Fail2ban
- Uptime Kuma/Healthchecks
- leichte n8n/Huginn-Workflows
- rclone/restic Backup-Ziel

## Nicht als Default

- offene Admin-Ports
- grosse Docker-Stacks
- Airbyte/kind
- ComfyUI/Video-KI
- offene Datenbanken

## Mindesthardening

- SSH Key-Login
- Passwortlogin deaktivieren
- UFW aktivieren
- Updates planen
- Backups testen
- Ports dokumentieren
