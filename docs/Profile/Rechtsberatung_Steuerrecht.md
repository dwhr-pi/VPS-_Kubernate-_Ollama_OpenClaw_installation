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
- Zotero unter `/opt/zotero` mit CLI-Link `zotero`
  - LangChain unter `/opt/langchain`
  - LlamaIndex unter `/opt/llamaindex`
  - ChromaDB unter `/opt/chromadb`

## Verantwortlichkeiten

- Web-Recherche
- PDF-Verarbeitung
- OCR für gescannte Dokumente

## Verfügbare Kommandos

```bash
sudo apt-get install -y pup jq wget curl
sudo apt-get install -y poppler-utils tesseract-ocr
scripts/tools/zotero_install.sh
scripts/tools/langchain_install.sh
scripts/tools/llamaindex_install.sh
scripts/tools/chromadb_install.sh
```

## Beispielprompts

### Core-System-Prompt

```txt
Du bist ein spezialisierter deutscher Rechtsanwalt für Steuerrecht.
Arbeitsweise:
1. Sachverhalt
2. Relevante Normen
3. Subsumtion
4. Ergebnis
5. Risiken und Unsicherheiten
Gib keine erfundenen Urteile oder Paragraphen an.
```

### Steueranalyse

```txt
Analysiere folgenden steuerrechtlichen Sachverhalt:
[INPUT]

Erstelle:
- Steuerliche Einordnung
- Relevante Paragraphen
- Risikoanalyse
- legale Optimierungsmöglichkeiten
```

## OpenClaw / Ollama Fit

- OpenClaw kann hier strukturierte Rollen wie Research, Risk und Drafting orchestrieren.
- LangChain, LlamaIndex und ChromaDB bilden den lokalen RAG-Unterbau für Gesetze, Urteile und Mandantenwissen.

## Vergleich

### ✅ In Sync

- Web-Fetch-Werkzeuge sind vorhanden.
- PDF- und OCR-Werkzeuge sind vorhanden.
- Zotero ist jetzt script-seitig integriert.
- LangChain, LlamaIndex und ChromaDB ergänzen den lokalen Legal-RAG-Layer.

### ⚠ Missing in Setup

- Das referenzierte `scripts/openclaw_skill_config.sh` fehlt vollständig.
- Neo4j, EULLM, ALIENTELLIGENCE-Modelle, Fristen-Checker und Risiko-Scoring sind noch nicht als eigene Installskripte umgesetzt.

### ❌ Missing in Docs

- Keine dedizierte Profil-Datei im ursprünglichen Repo

## Hinweise

- Das Uninstall-Skript entfernt sehr allgemeine Werkzeuge wie `curl` und `wget`; das kann andere Teile des Systems beeinträchtigen.
