# Profil: Personal_Knowledge_OS

## Zweck
Profil für persönliche Wissensdatenbank, lokale Suche, Export, Sync und Memory-Workflows.

## Use Cases
- Notizen und Wissensspeicher
- lokale Suche
- persönliche RAG-Ablage
- Geräte-Sync ohne GitHub-Secrets

## Enthaltene Tools
- Joplin
- Meilisearch
- Qdrant
- sqlite-vec
- Syncthing
- Rclone

## Installation
```bash
scripts/profiles/Personal_Knowledge_OS_install.sh
```

## Ports
- 7700 Meilisearch
- 6333 Qdrant

## Modelle
- optional Ollama-Embeddings

## Abhängigkeiten
- lokaler Speicher
- Backup sinnvoll

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: niedrig bis mittel
- RAM: ab 8 GB
- Storage: ab 15 GB

## Sicherheitshinweise
- private Wissensdaten lokal und verschlüsselt behandeln
- Sync-Ziele bewusst auswählen

## Start / Stop / Status Befehle
```bash
docker ps
ss -ltn | grep -E '7700|6333' || true
```

## Test-Command
```bash
bash scripts/profiles/Personal_Knowledge_OS_install.sh
```

## Deinstallation
```bash
scripts/profiles/Personal_Knowledge_OS_uninstall.sh
```
