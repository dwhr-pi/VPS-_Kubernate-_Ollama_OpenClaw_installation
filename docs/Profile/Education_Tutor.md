# Profil: Education_Tutor

## Zweck
Lern- und Tutorprofil für PDFs, Quiz, Karteikarten und lokale Wissensassistenten.

## Use Cases
- Lernassistent
- Quiz
- Karteikarten
- Kursgenerator

## Enthaltene Tools
- Open WebUI
- Qdrant
- ChromaDB
- JupyterLab
- Docling
- Paperless-ngx

## Installation
```bash
scripts/profiles/Education_Tutor_install.sh
```

## Ports
- 3000
- 6333
- 8010

## Modelle
- lokale Embeddings
- kleine Chatmodelle über Ollama

## Abhängigkeiten
- Ollama
- Docker

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: 12 GB+
- Storage: 20 GB+

## Sicherheitshinweise
- Lernunterlagen können urheberrechtlich geschützt sein

## Start / Stop / Status Befehle
```bash
docker ps
```

## Test-Command
```bash
bash scripts/profiles/Education_Tutor_install.sh
```

## Deinstallation
```bash
scripts/profiles/Education_Tutor_uninstall.sh
```
