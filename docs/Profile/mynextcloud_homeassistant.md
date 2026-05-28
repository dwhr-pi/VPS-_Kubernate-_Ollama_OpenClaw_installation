# myNextCloud Home Assistant

## Zweck
Home Assistant mit myNextCloud fuer Benachrichtigungen, Snapshots und Sprachnotizen verbinden.

## Funktionen
- Benachrichtigung bei Backup abgeschlossen.
- Warnung bei niedrigem Speicherplatz.
- Upload von Kamera-Snapshots nach myNextCloud.
- Sprachnotizen -> Whisper -> Markdown-Notiz.
- Dashboard-Kachel fuer Serverstatus.

## Empfohlene Tools
Home Assistant, n8n, Tailscale, Cloudflare Access, Whisper, OpenClaw, Uptime Kuma.

## Sicherheitsregeln
Kamera-Uploads und Sprachnotizen enthalten private Daten. Nur lokale/Tailnet-Verbindungen und klare Retention-Regeln verwenden.
