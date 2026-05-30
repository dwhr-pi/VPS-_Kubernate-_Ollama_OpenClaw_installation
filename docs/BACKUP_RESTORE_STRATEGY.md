# Backup Restore Strategy

## Backup ist erst fertig, wenn Restore getestet ist

Zu sichern: Repo-Konfiguration, `~/.openclaw_ultimate_user_data`, Ollama-Modellliste, n8n-Workflows, OpenClaw-State, Mailserver, Nextcloud, Queue-Status und wichtige Doku.

## Tools

Restic, BorgBackup, Rclone, Kopia, Litestream fuer SQLite.

## Restore-Test

Mindestens monatlich kleinen Restore in Testordner ausfuehren und protokollieren.
