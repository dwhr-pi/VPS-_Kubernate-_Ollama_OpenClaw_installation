# Profil: Office_Productivity

## Zweck
Dokumenten-, OCR- und Office-Automation mit Paperless, Stirling PDF, OCRmyPDF, Nextcloud und n8n.

## Use Cases
- Dokumentenarchiv
- PDF-Verarbeitung
- OCR
- Workflow-Automation

## Enthaltene Tools
- Paperless-ngx
- Stirling PDF
- OCRmyPDF
- Nextcloud
- n8n

## Installation
```bash
scripts/profiles/Office_Productivity_install.sh
```

## Ports
- 8010 Paperless
- 8081 Stirling PDF
- 8082 Nextcloud
- 5678 n8n

## Modelle
- optional lokale Modelle für Dokumentenklassifikation

## Abhängigkeiten
- Docker
- OCR-Pakete

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 12 GB
- Storage: ab 30 GB

## Sicherheitshinweise
- Dokumente können hochsensibel sein
- Weboberflächen nur mit Auth und möglichst intern betreiben

## Start / Stop / Status Befehle
```bash
docker ps
```

## Test-Command
```bash
bash scripts/profiles/Office_Productivity_install.sh
```

## Deinstallation
```bash
scripts/profiles/Office_Productivity_uninstall.sh
```
