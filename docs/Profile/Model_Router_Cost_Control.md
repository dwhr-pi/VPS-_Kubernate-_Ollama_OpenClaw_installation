# Model Router Cost Control

Status: `planned`  
Hardwarebedarf: `medium`  
Installationsart: lokal, VPS, Kubernetes spaeter

## Zweck

Modell-Routing zwischen Ollama, OpenAI-kompatiblen APIs, Gemini, LiteLLM und lokalen Modellen mit Kosten-, Token- und Fallback-Logik.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| LiteLLM | OpenAI-kompatibles Gateway, Routing | empfohlen |
| Ollama | lokale Modelle | empfohlen |
| Open WebUI | UI und lokale Modellnutzung | empfohlen |
| LocalAI | alternative lokale Runtime | optional |
| Langfuse/OpenLIT | Kosten-/Tracing-Logging | empfohlen |

## Sicherheitsregeln

- Cloud-Provider standardmaessig deaktiviert, bis Keys lokal gesetzt sind.
- Kostenlimits pro Provider dokumentieren.
- Keine API-Keys in Logs, Reports oder Git.
