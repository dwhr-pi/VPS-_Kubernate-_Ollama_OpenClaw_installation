# automation_n8n

Status: `documentation-first`

## Zweck
n8n, Activepieces, Huginn und OpenClaw fuer sichere Workflows verbinden.

## Modelle
- Lokal/Ollama: Workflow-Zusammenfassung und Klassifikation
- Optional extern: nur fuer nicht-private Inhalte

## Tools
n8n, Activepieces, Huginn, Node-RED, OpenClaw, Ollama, Uptime Kuma.

## Beispielprompt
`Plane einen n8n-Workflow, der eine Datei lokal zusammenfasst und das Ergebnis als Markdown speichert.`

## Sicherheitsregeln
Webhooks mit Signatur/Token. Keine externen APIs ohne Kosten-/Secret-Pruefung.

## Speicher-/Kostenkontrolle
Source-Builds bleiben opt-in. Docker/DB-Speicher vorher pruefen.

## Workflows
Webhook -> Validierung -> lokaler Agent -> Ergebnis -> Benachrichtigung.

## OpenClaw-Agent
`workflow-agent`: validiert Inputs und erstellt Plaene, fuehrt externe Aktionen nur mit Freigabe aus.
