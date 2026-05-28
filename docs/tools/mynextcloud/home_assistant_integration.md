# Home Assistant Integration

## Funktionen

- Backup abgeschlossen -> Benachrichtigung
- Speicherplatz niedrig -> Warnung
- Kamera-Snapshot -> Upload nach myNextCloud
- Sprachnotiz -> Whisper -> Markdown-Notiz
- Dashboard-Kachel fuer Serverstatus

## Sicherheitsregeln

- Home Assistant Token nicht ins Repo.
- Kamera- und Audio-Daten lokal halten.
- Admin-Aktionen nur mit Freigabe.

## Beispiel

Home Assistant Automation sendet bei Backup-Erfolg einen Webhook an n8n, n8n schreibt `backup_report.md` in myNextCloud und sendet eine lokale Benachrichtigung.
