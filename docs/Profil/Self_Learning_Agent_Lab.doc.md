# Fachprofil: Self_Learning_Agent_Lab

## Zweck

Experimentierprofil fuer lokale Agenten mit Feedback-Loops, Evaluation, Replay-Logs, Tool-Nutzung und Sicherheitsgrenzen. Es geht um kontrollierte Lernprotokolle, nicht um unkontrollierte Selbstoptimierung.

## Typische Aufgaben

- OpenClaw-Aufgaben wiederholbar testen
- Tool-Nutzung und Fehlerpfade protokollieren
- Prompt-Regressionen mit `promptfoo` pruefen
- Langfuse-/OpenTelemetry-Traces auswerten
- Replay-Logs fuer manuelle Verbesserung erstellen

## Empfohlene Tools

- `openclaw`
- `litellm`
- `langfuse`
- `promptfoo`
- `qdrant`
- `openlit`

## Sicherheitsregeln

- Kein autonomes Live-Handeln ohne Freigabe.
- Schreibende Aktionen nur im Sandbox-/Dry-Run-Modus.
- Shell-, Browser- und Netzwerktools nur mit Allowlist.
- Keine Secrets in Replay-Logs.

## Status

`experimental`, weil Agenten mit Toolzugriff immer kontrolliert getestet werden muessen.
