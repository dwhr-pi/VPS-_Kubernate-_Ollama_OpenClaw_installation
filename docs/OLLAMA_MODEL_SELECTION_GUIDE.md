# Ollama Model Selection Guide

## Low Resource

- `llama3.2:1b` fuer Tests.
- kleine Embedding-Modelle fuer RAG.
- Keine grossen Modelle automatisch ziehen.

## Standard

- vorhandene lokale Modelle bevorzugen.
- Modellpull vorab anzeigen: Name, Groesse, erwarteter Speicher.

## Qualitaet

- groessere Modelle nur bei ausreichend RAM/VRAM/Speicher.
- GPU nur nutzen, wenn Treiber und Speicher erkannt wurden.

## Agentenregel

Agenten erhalten nur die minimal noetigen Tools. Schreibende Aktionen brauchen Human Approval.
