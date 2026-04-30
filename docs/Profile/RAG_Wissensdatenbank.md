# Profil: RAG_Wissensdatenbank

## Zweck
Lokale Wissensdatenbank mit Open WebUI, LightRAG und Vektor-Storage für PDF, Markdown, TXT und HTML.

## Use Cases
- Firmenwissen lokal durchsuchen
- Repo- und Dokumenten-RAG
- lokale Embeddings via Ollama

## Enthaltene Tools
- Open WebUI
- LightRAG
- Qdrant
- ChromaDB
- Data Juicer
- PDF Parser

## Installation
```bash
scripts/profiles/RAG_Wissensdatenbank_install.sh
```

## Ports
- 3000 Open WebUI
- 6333 Qdrant

## Modelle
- Ollama Embeddings
- qwen2.5:7b oder llama3.2:3b für lokale Antworten

## Abhängigkeiten
- Docker
- Ollama
- Speicher für Dokumente

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 16 GB
- Storage: ab 20 GB plus Dokumente

## Sicherheitshinweise
- importierte Dokumente können sensible Daten enthalten
- Open WebUI nicht ungeschützt veröffentlichen

## Start / Stop / Status Befehle
```bash
docker ps
curl http://localhost:6333/collections
```

## Test-Command
```bash
bash scripts/profiles/RAG_Wissensdatenbank_install.sh
```

## Deinstallation
```bash
scripts/profiles/RAG_Wissensdatenbank_uninstall.sh
```
