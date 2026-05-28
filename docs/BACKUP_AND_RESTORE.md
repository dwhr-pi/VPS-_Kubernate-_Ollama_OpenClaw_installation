# Backup and Restore

## Ziel

Backups muessen vor Updates, Profilwechseln, schwergewichtigen Tool-Installationen und Fork-Syncs einfach ausloesbar und testbar sein.

## Zu sichern

- `~/.openclaw_ultimate_user_data`
- wichtige `.env`-Dateien ausserhalb des Repos
- Tool-Datenverzeichnisse unter `/opt` nur bei Bedarf
- Datenbanken: Postgres, SQLite, Qdrant/Chroma, Nextcloud
- Konfigurationen: Ports, Profile, lokale Overrides

## Nicht ungefragt sichern

- Docker-Volumes ohne explizite Zustimmung
- Modell-Caches mit vielen GB, wenn reproduzierbar
- API-Keys in Klartext-Reports

## Restore-Test

Ein Backup gilt erst als brauchbar, wenn ein Restore-Test dokumentiert ist:

```bash
bash scripts/operations/restore_test.sh
```

## Empfohlene Tools

- Restic fuer verschluesselte Backups
- BorgBackup fuer lokale deduplizierte Backups
- Rclone fuer Cloud-/WebDAV-Ziele
- Syncthing fuer Peer-to-Peer-Sync
