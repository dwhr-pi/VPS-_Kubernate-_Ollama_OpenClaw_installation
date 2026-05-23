# Personal Memory Knowledge OS

Status: `planned`  
Hardwarebedarf: `medium`  
Installationsart: lokal-first, WSL2, Linux-PC, MiniPC

## Zweck

Persoenliche Wissensbasis mit Chat-Memory-Import, lokaler Langzeit-Erinnerung und RAG ueber eigene Markdown-, JSON-, PDF- und Exportdaten.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| Qdrant/ChromaDB | Vektorspeicher | empfohlen |
| Open WebUI Memory | lokale Chat-Erinnerung | empfohlen |
| LlamaIndex/LangGraph | Import- und Agentenketten | optional |
| SQLite/Postgres/DuckDB | strukturierte Metadaten | empfohlen |
| Obsidian/Markdown | portabler Wissensbestand | empfohlen |

## Sicherheitsregeln

- Imports erst deduplizieren und klassifizieren.
- Private Konversationen nicht automatisch an externe APIs senden.
- Loesch- und Exportfunktion fuer Memory-Daten vorsehen.
