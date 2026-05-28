# VPS Homelab K3s Guide

## Wann k3s?

- mehrere Dienste
- klare Backups
- Monitoring
- genug RAM/Speicher
- Adminzugriff via Tailscale/Cloudflare Access

## Wann nicht?

- WSL2-Erstinstallation
- unter 8 GB RAM
- unter 20 GB frei
- keine Backupstrategie

## Minimalpfad

1. VPS hardening
2. Tailscale
3. UFW/Fail2ban
4. Backup
5. k3s dry-run/Plan
6. Helm erst danach

## GPU spaeter

GPU-Nodes sind advanced und brauchen Treiber, Runtime und Ressourcenlimits.
