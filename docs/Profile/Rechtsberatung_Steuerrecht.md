# Profil: Rechtsberatung_Steuerrecht

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Rechtsberatung_Steuerrecht.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Rechtsberatung_Steuerrecht.doc.md:1), `readme.md`, `docs/setup_guide.md` und `scripts/profiles/Rechtsberatung_Steuerrecht_install.sh` zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Legal-/Tax-Profil für strukturierte Fallanalyse, Dokumentenauswertung, RAG und steuerrechtliche Assistenz.

## Installierter Stack

- Basis: `pup`, `jq`, `wget`, `curl`, `poppler-utils`, `tesseract-ocr`, `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - Zotero unter `/opt/zotero`
  - symbolischer Link `/usr/local/bin/zotero`
  - LangChain unter `/opt/langchain`
  - LlamaIndex unter `/opt/llamaindex`
  - ChromaDB unter `/opt/chromadb`

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- Qdrant
- EULLM
- ALIENTELLIGENCE/aipoweredlawfirms
- ALIENTELLIGENCE/lawfirm
- Research Agent
- Tax Law Agent
- Risk Agent
- Drafting Agent
- PDF Parser
- Neo4j
- Steuerberechnung
- Fristen-Checker
- Risiko-Scoring

## Verantwortlichkeiten

- Strukturierte steuerrechtliche Fallanalyse
- Normen- und Risikoauswertung
- Dokumenten- und OCR-basierte Extraktion
- Entwürfe für Einsprüche und Argumentationslinien
- Mandantenverständliche Erklärungen
- Legal-RAG und juristische Wissensorganisation

## Verfügbare Kommandos

```bash
sudo apt-get install -y pup jq wget curl
sudo apt-get install -y poppler-utils tesseract-ocr
scripts/tools/zotero_install.sh
scripts/tools/langchain_install.sh
scripts/tools/llamaindex_install.sh
scripts/tools/chromadb_install.sh
```

## Vollständige Prompt-Liste

### Core-System-Prompt

```txt
Du bist ein spezialisierter deutscher Rechtsanwalt für Steuerrecht.

Arbeitsweise:
- Antworte IMMER strukturiert:
  1. Sachverhalt
  2. Relevante Normen (AO, EStG, UStG etc.)
  3. Subsumtion
  4. Ergebnis
  5. Risiken / Unsicherheiten
- Nutze juristische Fachsprache (aber verständlich).
- Gib KEINE erfundenen Urteile oder Paragraphen an.
- Wenn unsicher → kennzeichne explizit.
- Berücksichtige deutsches Recht + EU-Recht.
- Vermeide allgemeine Tipps → liefere konkrete Handlungsschritte.

Ziel:
Praxisnahe steuerrechtliche Einschätzung auf Fachanwalt-Niveau.
```

### Steueranalyse

```txt
Analysiere folgenden steuerrechtlichen Sachverhalt:

[INPUT]

Erstelle:
- Steuerliche Einordnung
- Relevante Paragraphen
- Risikoanalyse (Finanzamt / Betriebsprüfung)
- Optimierungsmöglichkeiten (legal!)
```

### Betriebsprüfung / Finanzamt

```txt
Simuliere eine Betriebsprüfung.

Input:
[Unterlagen]

Output:
- Auffälligkeiten
- mögliche Nachzahlungen
- Strafrisiken (Steuerhinterziehung / leichtfertige Verkürzung)
- Verteidigungsstrategie
```

### Steueroptimierung

```txt
Zeige legale Steueroptimierungen für:

[Situation]

Struktur:
- Sofortmaßnahmen
- Gestaltungsspielräume
- Risiken / Graubereiche
- langfristige Strategie
```

### Einspruch gegen Steuerbescheid

```txt
Erstelle eine juristische Argumentation gegen folgenden Steuerbescheid:

[Bescheid]

Output:
- Begründung (mit Normen)
- Argumentationslinie
- Erfolgsaussichten
```

### Vertragsprüfung

```txt
Prüfe folgenden Vertrag auf steuerliche Risiken:

[Vertrag]

Output:
- steuerliche Bewertung
- kritische Klauseln
- Optimierungsvorschläge
```

### Risiko / Strafrecht

```txt
Bewerte folgenden Fall im Hinblick auf Steuerstrafrecht:

[Fall]

Output:
- Einordnung (§370 AO etc.)
- Strafmaß-Risiko
- Handlungsempfehlung
```

### Mandanten-Erklärung

```txt
Erkläre folgendes steuerliches Thema verständlich für einen Mandanten:

[Thema]

Keine Fachbegriffe ohne Erklärung.
```

## Beispiel-Nutzung im OpenClaw-Setup

### Fallanalyse

```txt
Nutze den Core-System-Prompt und analysiere den folgenden steuerrechtlichen Sachverhalt.
Gib mir Sachverhalt, relevante Normen, Subsumtion, Ergebnis und Risiken strukturiert aus.
```

### Betriebsprüfung

```txt
Nutze den Prompt Betriebsprüfung / Finanzamt. Simuliere eine Prüfung meiner Unterlagen
und identifiziere Auffälligkeiten, mögliche Nachzahlungen, Strafrisiken und Verteidigungsstrategien.
```

### Mandanten-Erklärung

```txt
Nutze den Prompt Mandanten-Erklärung. Erkläre das Thema verständlich,
ohne unkommentierte Fachbegriffe zu verwenden, und gib konkrete nächste Schritte.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw als Agenten-Orchestrator für strukturierte Legal-Workflows.
- `LangChain`, `LlamaIndex` und `ChromaDB` bilden die aktuell vorhandene RAG-Grundlage.
- `Tesseract OCR`, `poppler-utils`, `pup`, `jq` und `Zotero` decken Dokumenten- und Recherchearbeit ab.
- Für das volle Zielbild aus der Quelldatei fehlen noch spezialisierte Legal-Modelle, Knowledge-Graph- und Fristen-/Risikotools.

## Vergleich

### ✅ In Sync

- Recherche-, OCR- und PDF-Bausteine sind vorhanden.
- `Zotero`, `LangChain`, `LlamaIndex` und `ChromaDB` sind als einzelne Tools vorhanden.
- Das Profil ist damit für strukturierte Dokumenten- und RAG-Arbeit bereits brauchbar.

### ⚠ Missing in Setup

- `Qdrant`, `EULLM`, `ALIENTELLIGENCE/aipoweredlawfirms`, `ALIENTELLIGENCE/lawfirm`, `Neo4j`, `PDF Parser`, `Steuerberechnung`, `Fristen-Checker` und `Risiko-Scoring` fehlen noch als installierbare Module.
- Das referenzierte `scripts/openclaw_skill_config.sh` fehlt weiterhin.

### ❌ Missing in Docs

- Die praktische Trennung zwischen Assistenzsystem und echter Rechtsberatung könnte in der Hauptdoku klarer hervorgehoben werden.

## Hinweise

- Dieses Profil ist ein Assistenz- und Analyseprofil, kein Ersatz für anwaltliche Verantwortung.
- Für ein ernsthaftes Legal-Setup fehlen noch mehrere dokumentierte Spezialbausteine als echte Tools.
