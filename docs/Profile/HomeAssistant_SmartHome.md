# HomeAssistant_SmartHome

Status: `documentation-first`

## Zweck
Home Assistant, MQTT, lokale Sprache und OpenClaw als sicherer Smart-Home-Agent.

## Typische Aufgaben
Statusberichte, Benachrichtigungen, Sprach-zu-Notiz, Kamera-Snapshot-Archivierung.

## Empfohlene Tools
Home Assistant, Mosquitto, Node-RED, Whisper, Piper, Tailscale.

## Erlaubte Aktionen
Read-only Status, Benachrichtigungen, Vorschlaege.

## Verbotene/gefaehrliche Aktionen
Keine kritischen Schaltaktionen ohne Human Approval.

## Umgebungsvariablen
`HOME_ASSISTANT_URL`, `HOME_ASSISTANT_TOKEN` nur lokal speichern.

## Beispiel-Prompts
`Erstelle eine sichere Automation fuer Backup-Benachrichtigungen in Home Assistant.`

## Modellvorschlaege
Ollama: kleines lokales Modell fuer Intent und Zusammenfassung.

## Speicherort
`~/.openclaw_ultimate_user_data/reports/homeassistant`
