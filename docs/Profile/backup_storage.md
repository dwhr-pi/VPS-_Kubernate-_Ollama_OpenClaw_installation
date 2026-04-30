# backup_storage

## Zweck

Definiert eine einfache Backup-Strategie für Daten, Modelle, Konfigurationen und Plattformvolumes.

## Use Cases

- Sicherung von `~/.openclaw_ultimate_user_data`
- Sicherung von Docker-Volumes und Datenbanken
- Wiederherstellung nach Fehlkonfiguration

## Enthaltene Tools

- `MinIO`
- `Postgres`
- `Redis`
- optional `restic` oder `borg` als späterer Ausbau

## Installation

```bash
scripts/tools/minio_install.sh
scripts/tools/postgres_install.sh
scripts/tools/redis_install.sh
```

## Ports

- `9000`
- `9001`
- `5432`
- `6379`

## Modelle

- keine

## Abhängigkeiten

- Storage
- Datenbankdienste

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: niedrig
- RAM: ab 8 GB
- Storage: abhängig von Datenvolumen

## Sicherheitshinweise

- Backups verschlüsseln
- Restore-Pfade testen
- sensible Workspace-Daten gesondert behandeln

## Start / Stop / Status Befehle

```bash
docker ps
sudo systemctl status postgresql || true
```

## Test-Command

```bash
ls ~/.openclaw_ultimate_user_data
```

## Deinstallation

```bash
scripts/tools/minio_uninstall.sh
scripts/tools/postgres_uninstall.sh
scripts/tools/redis_uninstall.sh
```
