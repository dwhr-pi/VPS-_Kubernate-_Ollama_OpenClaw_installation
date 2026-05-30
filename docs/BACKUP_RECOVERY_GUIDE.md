# Backup Recovery Guide

## Ziel

Backups muessen vor Updates, schweren Installationen und Mailserver-Aenderungen
existieren.

## Empfohlene Tools

- Restic
- BorgBackup
- Kopia
- Rclone
- MinIO optional

## Sichern

- `~/.openclaw_ultimate_user_data`
- Konfigurationen ohne Secrets oder verschluesselt
- n8n Daten
- OpenClaw State
- Stalwart Mail Daten
- Docker Volumes nur bewusst

## Restore-Test

Ein Backup ist erst wertvoll, wenn ein Restore getestet wurde.
