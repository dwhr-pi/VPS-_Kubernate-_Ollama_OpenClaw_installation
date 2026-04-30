# Backup Recovery

## Ziele

- Repo getrennt vom Benutzer-Workspace sichern
- Wiederherstellung testbar machen
- lokale und entfernte Ziele erlauben

## Werkzeuge

- Restic
- BorgBackup optional
- Rclone
- MinIO optional als S3-kompatibles Ziel

## Wichtige Pfade

- Repository: `~/openclaw_ultimate_setup`
- Benutzer-Workspace: `~/.openclaw_ultimate_user_data`

## Backup starten

```bash
bash scripts/operations/backup_run.sh
```

## Restore-Test

```bash
bash scripts/operations/restore_test.sh
```

## Empfehlung

- mindestens ein lokales Backup
- mindestens ein externes oder offsite Backup
- Restore regelmäßig testen
