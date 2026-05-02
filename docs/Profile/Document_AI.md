# Profil: Document_AI

## Zweck
Profil für PDF, OCR, Formulare, Akten, Behördenpost, Rechnungen und Vertragsdokumente.

## Use Cases
- OCR und Dokumentenimport
- PDF-Konvertierung
- Akten- und Vertragsanalyse
- lokale RAG-Ablage für Dokumente

## Enthaltene Tools
- OCRmyPDF
- Tesseract
- Stirling PDF
- Paperless-ngx
- Apache Tika
- Docling
- Marker
- LibreOffice headless
- Pandoc

## Installation
```bash
scripts/profiles/Document_AI_install.sh
```

## Ports
- 8010 Paperless-ngx
- 8081 Stirling PDF
- 9998 Apache Tika

## Modelle
- optional lokale Embeddings über Ollama

## Abhängigkeiten
- Python
- Docker

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 8 GB
- Storage: ab 20 GB

## Sicherheitshinweise
- Behörden- und Vertragsdaten nur lokal oder stark abgesichert verarbeiten
- Scans, OCR-Ausgaben und Exporte als vertraulich behandeln

## Start / Stop / Status Befehle
```bash
docker ps
ss -ltn | grep -E '8010|8081|9998' || true
```

## Test-Command
```bash
bash scripts/profiles/Document_AI_install.sh
```

## Deinstallation
```bash
scripts/profiles/Document_AI_uninstall.sh
```
