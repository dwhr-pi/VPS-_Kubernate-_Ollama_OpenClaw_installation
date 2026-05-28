# n8n Workflows fuer myNextCloud

## Workflow 1: Neuer Datei-Upload

```json
{
  "name": "myNextCloud file upload summary",
  "nodes": [
    {"name": "Webhook", "type": "n8n-nodes-base.webhook", "parameters": {"path": "mynextcloud/file-upload"}},
    {"name": "Fetch file", "type": "n8n-nodes-base.httpRequest", "parameters": {"authentication": "predefinedCredentialType"}},
    {"name": "Ollama summarize", "type": "n8n-nodes-base.httpRequest", "parameters": {"url": "http://127.0.0.1:11434/api/generate"}},
    {"name": "Save summary", "type": "n8n-nodes-base.httpRequest", "parameters": {"method": "PUT"}}
  ]
}
```

## Workflow 2: Audio hochgeladen

Webhook -> Datei abrufen -> Whisper Endpoint -> Ollama Zusammenfassung -> Tags -> `.transcript.md` speichern.

## Workflow 3: Bild hochgeladen

Webhook -> Bild abrufen -> lokale Vision-KI optional -> Beschreibung -> Album-/Ordner-Vorschlag speichern.

## Workflow 4: Backup

Zeittrigger -> Datenbankdump -> Datenordner Snapshot -> Logdatei -> Benachrichtigung via Home Assistant/Email.

## Sicherheit

Webhooks signieren, Zugriff begrenzen, Rate-Limits setzen, keine Tokens im Workflow-JSON committen.
