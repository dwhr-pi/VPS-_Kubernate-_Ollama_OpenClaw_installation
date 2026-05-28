# myNextCloud Admin

## Zweck
Admin-, Wartungs-, Backup- und Update-Profil fuer `myNextCloud Server`.

## Aufgaben
- Speicherplatz und Datenverzeichnis pruefen.
- Upstream-Status gegen `nextcloud/server` dokumentieren.
- Backup-Berichte erstellen.
- Update-Fenster vorbereiten.
- Cloudflare/Tailscale-Zugriff pruefen.

## Empfohlene Tools
Restic/BorgBackup, rclone optional, Uptime Kuma, Netdata, OpenClaw, n8n, Cloudflare Tunnel, Tailscale.

## Status
Documentation-first. Keine automatische Serverinstallation, kein Datenbank-Reset, keine produktiven Updates ohne manuelle Freigabe.

## Sicherheitsregeln
Datenordner ausserhalb des Webroots. 2FA fuer Admins. Backups verschluesseln. Wartungsaktionen immer mit Log und Rollback-Plan.
