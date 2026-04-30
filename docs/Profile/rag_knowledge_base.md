# rag_knowledge_base

## Zweck

Stellt den zentralen Knowledge- und Retrieval-Layer für Dokumente, Webseiten, Markdown und Repositories bereit.

## Use Cases

- Dokumentensuche
- Wissensdatenbank
- Repo-Import für Agenten

## Enthaltene Tools

- `Qdrant`
- `ChromaDB`
- `LlamaIndex`
- `LangChain`
- `Data_Juicer`

## Installation

```bash
scripts/tools/qdrant_install.sh
scripts/tools/chromadb_install.sh
scripts/tools/llamaindex_install.sh
scripts/tools/langchain_install.sh
scripts/tools/data_juicer_install.sh
```

## Ports

- `6333` Qdrant

## Modelle

- Embedding-Modelle über Ollama oder Cloud
- allgemeine Antwortmodelle wie `qwen2.5:7b`

## Abhängigkeiten

- Storage
- Ollama oder Cloud-Provider

## Ressourcenverbrauch (CPU / RAM / Storage)

- CPU: mittel
- RAM: ab 12 GB
- Storage: stark datenabhängig

## Sicherheitshinweise

- importierte Dokumente können sensible Inhalte enthalten
- PDFs und Repos vor Import klassifizieren

## Start / Stop / Status Befehle

```bash
docker compose -f /opt/qdrant/docker-compose.yml up -d
docker compose -f /opt/qdrant/docker-compose.yml down
docker ps
```

## Test-Command

```bash
curl http://localhost:6333/collections
```

## Deinstallation

```bash
scripts/tools/qdrant_uninstall.sh
scripts/tools/chromadb_uninstall.sh
scripts/tools/llamaindex_uninstall.sh
scripts/tools/langchain_uninstall.sh
scripts/tools/data_juicer_uninstall.sh
```
