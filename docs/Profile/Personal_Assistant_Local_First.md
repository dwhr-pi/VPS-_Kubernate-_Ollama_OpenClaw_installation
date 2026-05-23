# Personal Assistant Local First

Profil fuer einen lokalen persoenlichen Assistenten mit Ollama, OpenClaw, Open WebUI, Qdrant, n8n und optionaler Dokumenten-/Task-Anbindung.

## Fokus

- lokale Modelle zuerst, Cloud-APIs nur bewusst
- private Memory-/RAG-Schicht mit Qdrant oder ChromaDB
- n8n fuer Aufgaben, Benachrichtigungen und Workflows
- Paperless/Docling fuer lokale Dokumente

## Sicherheitsgrenze

Der Assistent darf Vorschlaege machen und Workflows vorbereiten. Shell-, Datei-, Mail-, Kalender- oder Smart-Home-Aktionen brauchen sichere Tools, Rollen und Bestätigung.

## Installation

```bash
bash scripts/profiles/Personal_Assistant_Local_First_install.sh
```
