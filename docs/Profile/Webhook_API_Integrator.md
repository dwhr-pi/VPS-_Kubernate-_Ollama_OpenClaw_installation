# Webhook_API_Integrator

## Zweck
Webhook- und API-Integrationen fuer Tools, Monitoring und Automationen sicher verbinden.

## Typische Aufgaben
- API-Endpoints dokumentieren.
- Signaturen, Rate-Limits und Retry-Strategien planen.
- Test-Webhooks von produktiven Webhooks trennen.

## Empfohlene Tools
n8n, Huginn, Node-RED, FastAPI, LiteLLM, Uptime Kuma.

## Hardwarebedarf und Status
Hardware: leicht bis mittel. Status: planned. Installationsart: local, VPS mit Auth/Tunnel.

## Datenschutz und Sicherheit
Webhook-URLs sind Secrets. Keine offenen Endpunkte ohne Signatur, Token und Rate-Limit.

## Beispiel-Prompt
`Erstelle eine sichere Webhook-Spezifikation fuer Setup-Fehlerdiagnosen per E-Mail.`

## Modelle
Ollama: `llama3.1:8b`, `qwen2.5-coder:7b`.

## Grenzen
Keine ungeschuetzten oeffentlichen Webhooks.
