# local_memory_agent

Status: `documentation-first`

## Zweck
Lokale Langzeit-Memory, Chat-Importe, RAG und private Wissensbasis strukturieren.

## Modelle
- Lokal/Ollama: kleines Modell fuer Tags/Summaries
- Optional extern: nicht fuer private Memory-Daten empfohlen

## Tools
Qdrant, ChromaDB, SQLite/DuckDB, Open WebUI Knowledge, LlamaIndex, Docling.

## Beispielprompt
`Importiere diese Markdown-Notizen lokal, dedupliziere sie und erstelle Tags ohne externe Dienste.`

## Sicherheitsregeln
Private Daten lokal halten. Keine automatischen Uploads.

## Speicher-/Kostenkontrolle
Indexgroesse messen, alte Embeddings bereinigbar halten.

## Workflows
Import -> Deduplikation -> Tags -> Embeddings -> Suche -> Export.

## OpenClaw-Agent
`local-memory-agent`: arbeitet nur in erlaubten Datenpfaden.
