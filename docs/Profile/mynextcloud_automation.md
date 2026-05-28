# myNextCloud Automation

## Zweck
n8n-, OpenClaw-, Ollama-, Whisper- und Home-Assistant-Automationen rund um myNextCloud planen.

## Workflows
- neuer Datei-Upload -> Ollama-Zusammenfassung -> `.summary.md`
- Audio-Upload -> Whisper-Transkript -> Tags
- Bild-Upload -> Beschreibung -> Album-/Ordner-Vorschlag
- Backup -> Datenbankdump -> Snapshot -> Benachrichtigung

## Sicherheitsregeln
Webhooks signieren, Rate-Limits setzen, Admin-Aktionen manuell bestaetigen. Keine offenen n8n-Endpunkte ohne Access/Tunnel.
