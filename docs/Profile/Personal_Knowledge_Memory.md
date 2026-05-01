# Profil: Personal_Knowledge_Memory

## Zweck
Persönlicher lokaler Memory-Layer für Chatverläufe, Notizen und Wissensimport.

## Use Cases
- persönliches Wissensgedächtnis
- Chat-Import/Export
- lokale Retrieval-Workflows

## Enthaltene Tools
- Qdrant
- ChromaDB
- LangChain
- LlamaIndex

## Installation
```bash
scripts/profiles/Personal_Knowledge_Memory_install.sh
```

## Ports
- 6333

## Modelle
- lokale Embeddings via Ollama

## Abhängigkeiten
- Ollama

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: 8 GB+
- Storage: datenabhängig

## Sicherheitshinweise
- Memory-Daten sehr datenschutzrelevant behandeln

## Start / Stop / Status Befehle
```bash
curl http://localhost:6333/collections
```

## Test-Command
```bash
bash scripts/profiles/Personal_Knowledge_Memory_install.sh
```

## Deinstallation
```bash
scripts/profiles/Personal_Knowledge_Memory_uninstall.sh
```
