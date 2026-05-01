# Profil: Document_Intelligence

## Zweck
Dokumenten- und OCR-Profil für Parsing, Konvertierung und lokale RAG-Ablage.

## Use Cases
- Rechnungen
- Verträge
- OCR
- PDF, HTML, Markdown, Docx

## Enthaltene Tools
- Paperless-ngx
- Stirling PDF
- OCRmyPDF
- Apache Tika
- Docling
- PDF Parser
- Pandoc

## Installation
```bash
scripts/profiles/Document_Intelligence_install.sh
```

## Ports
- 8010
- 8081
- 9998

## Modelle
- optionale lokale RAG-Modelle

## Abhängigkeiten
- Docker
- OCR

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: 12 GB+
- Storage: 25 GB+

## Sicherheitshinweise
- Vertrags- und Rechnungsdaten sind oft hochsensibel

## Start / Stop / Status Befehle
```bash
docker ps
```

## Test-Command
```bash
bash scripts/profiles/Document_Intelligence_install.sh
```

## Deinstallation
```bash
scripts/profiles/Document_Intelligence_uninstall.sh
```
