# Multi_Agent_Router

## Zweck
Mehrere Agenten und Spezialrollen koordinieren, ohne unkontrollierte Tool-Ketten zu starten.

## Typische Aufgaben
- Aufgaben an Research-, Coding-, RAG- und Review-Agenten routen.
- Kosten- und Sicherheitsgrenzen setzen.
- Ergebnisse zusammenfuehren und Konflikte markieren.

## Empfohlene Tools
LangGraph, AutoGen, CrewAI, OpenClaw, LiteLLM, Qdrant.

## Hardwarebedarf und Status
Hardware: mittel. Status: experimental. Installationsart: local, WSL2, VPS mit Auth.

## Datenschutz und Sicherheit
Multi-Agenten koennen Fehler verstaerken. Tool-Zugriff begrenzen, Logging aktivieren, Freigaben erzwingen.

## Beispiel-Prompt
`Plane eine sichere Multi-Agenten-Kette fuer Repo-Analyse, aber ohne automatische Writes.`

## Modelle
Ollama: `qwen2.5-coder:7b`, `llama3.1:8b`. Cloud optional fuer Koordinator.

## Grenzen
Keine autonomen Deployments, Zahlungen, Smart-Home- oder Security-Aktionen.
