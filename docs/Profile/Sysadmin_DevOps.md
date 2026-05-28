# Sysadmin_DevOps

Status: `documentation-first`

## Zweck
Server, VPS, Dienste, Updates, Backups und Deployments sicher betreiben.

## Typische Aufgaben
Preflight, Update-Planung, Portpruefung, Service-Status, Backup/Restore, Loganalyse.

## Empfohlene Tools
GitHub CLI, Ansible optional, UFW, Fail2ban, Uptime Kuma, Restic, BorgBackup, rclone.

## Erlaubte Aktionen
Read-only Diagnose, Reports, dry-run Plaene, Konfigurationsvorschlaege.

## Verbotene/gefaehrliche Aktionen
Keine Portfreigabe, kein `rm -rf`, kein Service-Restart, kein Update ohne Freigabe.

## Umgebungsvariablen
`OPENCLAW_USER_DATA_DIR`, optional `BACKUP_TARGET`, `TAILSCALE_AUTHKEY`.

## Beispiel-Prompts
`Erstelle einen sicheren Wartungsplan fuer diesen VPS mit Backup vor Updates.`

## Modellvorschlaege
Ollama: `llama3.2:1b` fuer Checks, groesseres lokales Modell fuer Reports.

## Speicherort
`~/.openclaw_ultimate_user_data/reports/sysadmin_devops`
