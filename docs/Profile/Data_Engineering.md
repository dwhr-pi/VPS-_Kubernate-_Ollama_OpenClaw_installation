# Profil: Data_Engineering

## Zweck
Profil für lokale Datenpipelines, ETL, Vorverarbeitung, RAG-Datenspeicher und Analyse.

## Use Cases
- Dokumentenaufbereitung für RAG
- lokale ETL-Strecken
- BI- und Datenvorverarbeitung

## Enthaltene Tools
- DuckDB
- Prefect
- MinIO
- PostgreSQL
- pgvector
- Qdrant
- Apache Tika
- unstructured
- Pandoc

## Installation
```bash
scripts/profiles/Data_Engineering_install.sh
```

## Ports
- 5432 PostgreSQL
- 6333 Qdrant
- 9000 MinIO
- 9001 MinIO Console

## Modelle
- optional lokale Embedding-Modelle via Ollama

## Abhängigkeiten
- Python
- Docker für einige Teilkomponenten sinnvoll

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 12 GB
- Storage: ab 30 GB

## Sicherheitshinweise
- sensible Rohdaten nicht ungeschützt in Containern oder Freigaben ablegen
- Datenquellen und Rechte dokumentieren

## Start / Stop / Status Befehle
```bash
docker ps
ss -ltn | grep -E '5432|6333|9000|9001' || true
```

## Test-Command
```bash
bash scripts/profiles/Data_Engineering_install.sh
```

## Deinstallation
```bash
scripts/profiles/Data_Engineering_uninstall.sh
```
