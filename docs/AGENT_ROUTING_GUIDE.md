# Agent Routing Guide

## Zielbild

Agent Routing verbindet OpenClaw, Ollama, LiteLLM, lokale Tools, MCP-Server und optionale Cloud-Modelle kontrolliert.

## Routing-Prinzipien

- Lokal zuerst.
- Kleine Modelle fuer Klassifikation und Vorfilter.
- Groessere Modelle nur bei Bedarf.
- Cloud-Modelle nur mit expliziter Freigabe und Kostenlimit.
- Schreibende Tools nur mit Human Approval.

## Agentenklassen

| Klasse | Beispiele | Gate |
|---|---|---|
| Read-only | Summaries, Logs, RAG | automatisch moeglich |
| Local write | Markdown/JSON Reports | Freigabe je Profil |
| System write | Install, Delete, Update | Human Approval |
| External | APIs, Mail, Cloud | Human Approval und Secrets-Check |

## Logging

Jeder Agentenlauf sollte speichern:

- Profil
- Modell
- Tools
- Eingabepfade
- Ausgabepfade
- Dauer
- Fehler
- Human-Approval-Status
