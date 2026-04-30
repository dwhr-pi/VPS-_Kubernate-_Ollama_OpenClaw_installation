# Profil: Backup_Recovery

## Zweck
Backup-, Restore- und Snapshot-Workflow für Repo, Workspace und zentrale Daten.

## Use Cases
- lokale Backups
- VPS-Backups
- S3-kompatible Ziele
- Restore-Test

## Enthaltene Tools
- Restic
- BorgBackup
- Rclone
- MinIO

## Installation
```bash
scripts/profiles/Backup_Recovery_install.sh
```

## Ports
- 9000 MinIO API
- 9001 MinIO Console

## Modelle
- keine

## Abhängigkeiten
- Speicherplatz
- optional S3-kompatibles Ziel

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig
- RAM: ab 4 GB
- Storage: abhängig vom Datenbestand

## Sicherheitshinweise
- Backups verschlüsseln
- Restore regelmäßig testen

## Start / Stop / Status Befehle
```bash
bash scripts/operations/backup_run.sh
bash scripts/operations/restore_test.sh
```

## Test-Command
```bash
bash scripts/operations/restore_test.sh
```

## Deinstallation
```bash
scripts/profiles/Backup_Recovery_uninstall.sh
```
