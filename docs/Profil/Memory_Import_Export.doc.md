# Fachprofil: Memory_Import_Export

## Zweck

Dieses Profil importiert und exportiert Erinnerungen, Notizen, Chat-Exporte und Projektkontext aus Markdown, JSON, JSONL, SQLite und ZIP-Archiven. Ziel ist ein lokaler, editierbarer Memory-/RAG-Bestand fuer OpenClaw, Open WebUI, Qdrant oder ChromaDB.

## Typische Aufgaben

- ChatGPT-/Claude-/Gemini-Exporte lokal bereinigen
- Projektwissen als Markdown oder JSONL strukturieren
- RAG-Sammlungen in Qdrant oder ChromaDB vorbereiten
- Memory-Dateien fuer Persona-/Projektprofile exportieren
- sensible Daten vor Import redigieren

## Empfohlene Tools

- `qdrant` oder `chromadb`
- `duckdb`
- `docling`
- `apache_tika`
- `open_webui`
- optional `langfuse`

## Datenschutz

Memory-Importe enthalten oft personenbezogene Daten, private Chats und Projektgeheimnisse. Standard ist lokale Verarbeitung. Cloud-Uploads nur bewusst und nach Redaction.

## Quickstart

1. Exportdatei in `~/.openclaw_ultimate_user_data/imports/` ablegen.
2. Format pruefen und sensible Inhalte entfernen.
3. Ziel waehlen: Markdown, JSONL, SQLite oder Vektor-DB.
4. Ergebnis mit `scripts/doctor.sh` und `scripts/validate_config.sh` pruefen.

## Status

`beta`.
