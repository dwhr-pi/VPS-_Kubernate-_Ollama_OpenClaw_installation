# Notification_Router

## Zweck
Benachrichtigungen aus Setup, Monitoring, Backups und Agenten priorisieren und routen.

## Typische Aufgaben
- Fehler nach Dringlichkeit einstufen.
- E-Mail-/Webhook-/Messenger-Ziele trennen.
- Duplikate und Spam vermeiden.

## Empfohlene Tools
Uptime Kuma, Healthchecks, n8n, msmtp, Grafana Alerts.

## Hardwarebedarf und Status
Hardware: leicht. Status: planned. Installationsart: local, WSL2, VPS.

## Datenschutz und Sicherheit
Benachrichtigungen koennen Logpfade, Hostnamen und Fehlerdetails enthalten. Inhalte minimieren.

## Beispiel-Prompt
`Erstelle Routing-Regeln fuer Setup-Fehler: kritisch per E-Mail, Info nur lokal loggen.`

## Modelle
Ollama: `llama3.1:8b`.

## Grenzen
Keine Weiterleitung von Secrets oder vollstaendigen Logs an externe Kanaele.
