# Prompt_Generator_Allround

Status: planned  
Kategorie: Medien, Coding, Agenten, Dokumentation  
Installationsart: lokal-first, optional mit externen APIs

## Zweck

Dieses Profil dient als zentrale Prompt-Werkstatt fuer Text, Bild, Video, Musik, Coding, Agenten und n8n/OpenClaw-Workflows.

## Geeignete Aufgaben

- Prompts strukturieren, testen und versionieren
- Modellvorschlaege fuer Ollama, LiteLLM oder lokale Spezialmodelle erstellen
- Promptvarianten als Markdown oder JSON exportieren
- Kosten-, Speicher- und Laufzeitrisiken sichtbar machen
- Promptfoo-Tests fuer Regressionen vorbereiten

## Toolbasis

| Tool | Aufgabe | Status |
|---|---|---|
| Ollama | lokale LLMs | empfohlen |
| OpenClaw | Agenten- und Workflowsteuerung | empfohlen |
| LiteLLM | Routing und Kostenlogging | empfohlen |
| promptfoo | Prompt-Tests und Regressionen | empfohlen |
| Langfuse/OpenLIT | Telemetrie und Bewertung | optional |
| ComfyUI/FFmpeg/Whisper/Piper | Medien-Workflows | optional |

## Sicherheitsregeln

- Externe APIs sind Opt-in.
- Keine API-Keys in Prompts oder Repo-Dateien speichern.
- Prompts fuer Trading, Security, Robotik oder Smart Home brauchen Human-Approval-Gates.

## Beispielprompt

```text
Erzeuge drei Varianten eines lokalen Ollama-Prompts fuer einen CAD-Agenten.
Bewerte jede Variante nach Praezision, Rueckfragen, Sicherheitsgrenzen und erwarteter Laufzeit.
Gib das Ergebnis als Markdown-Tabelle und JSON-Export aus.
```

