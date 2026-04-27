# Profil: Rechtsberatung_Steuerrecht

## Überblick

Dieses Profil ist auf Recherche, Dokumentenverarbeitung und OCR ausgerichtet.

## Installierter Stack

- `pup`
- `jq`
- `wget`
- `curl`
- `poppler-utils`
- `tesseract-ocr`

## Verantwortlichkeiten

- Web-Recherche
- PDF-Verarbeitung
- OCR für gescannte Dokumente

## Verfügbare Kommandos

```bash
sudo apt-get install -y pup jq wget curl
sudo apt-get install -y poppler-utils tesseract-ocr
```

## Vergleich

### ✅ In Sync

- Web-Fetch-Werkzeuge sind vorhanden.
- PDF- und OCR-Werkzeuge sind vorhanden.

### ⚠ Missing in Setup

- Zotero wird nur manuell empfohlen, aber nicht automatisiert installiert.
- Das referenzierte `scripts/openclaw_skill_config.sh` fehlt vollständig.

### ❌ Missing in Docs

- Keine dedizierte Profil-Datei im ursprünglichen Repo

## Hinweise

- Das Uninstall-Skript entfernt sehr allgemeine Werkzeuge wie `curl` und `wget`; das kann andere Teile des Systems beeinträchtigen.
