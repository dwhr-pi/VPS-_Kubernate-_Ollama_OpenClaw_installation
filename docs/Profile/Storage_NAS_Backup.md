# Storage NAS Backup

Profil fuer lokale Backups, Modelle, Medien, Dokumente, MinIO, Restic, BorgBackup, Rclone und optionale NAS-Anbindung.

## Fokus

- Modell- und Mediendaten getrennt vom Git-Repository speichern
- Restic/Borg fuer Backups, Rclone fuer optionale Ziele
- MinIO fuer lokalen Objekt-Speicher
- Restore-Tests und Speicherberichte

## Sicherheit

Backup-Schluessel, Repository-Passwoerter und Cloud-Token niemals ins Repo schreiben. Restore regelmaessig testen.

## Installation

```bash
bash scripts/profiles/Storage_NAS_Backup_install.sh
```
