# Automatisierung_N8N

Status: `documentation-first`

## Zweck
n8n, Node-RED und Huginn sicher mit OpenClaw/Ollama verbinden.

## Typische Aufgaben
Webhook-Validierung, Datei-Zusammenfassung, Monitoring-Benachrichtigung, GitHub-Issue-Entwurf.

## Empfohlene Tools
n8n, Node-RED, Huginn, OpenClaw, Ollama, Uptime Kuma.

## Erlaubte Aktionen
Workflow-Planung, lokale Tests, dry-run Webhook-Payloads.

## Verbotene/gefaehrliche Aktionen
Keine externen API-Aufrufe, E-Mails oder Webhooks ohne Freigabe.

## Umgebungsvariablen
`N8N_BASE_URL`, `OLLAMA_BASE_URL`, optional lokale Webhook-Tokens.

## Beispiel-Prompts
`Erstelle einen n8n-Workflow, der eine lokale Datei zusammenfasst und als Markdown speichert.`

## Modellvorschlaege
Ollama lokal fuer Klassifikation und Zusammenfassung.

## Speicherort
`~/.openclaw_ultimate_user_data/workflows/n8n`
