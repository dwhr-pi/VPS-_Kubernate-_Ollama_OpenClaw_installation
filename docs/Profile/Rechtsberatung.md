# Profil: Rechtsberatung

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Rechtsberatung_Steuerrecht.doc.md](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Rechtsberatung_Steuerrecht.doc.md:1), `readme.md`, `docs/setup_guide.md` und `scripts/profiles/Rechtsberatung_Steuerrecht_install.sh` zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Legal-Profil fuer strukturierte Fallanalyse, Dokumentenauswertung, RAG und fachgebietsbezogene Assistenz in echten Rechtsgebieten.

## Installierter Stack

- Basis: `pup`, `jq`, `wget`, `curl`, `poppler-utils`, `tesseract-ocr`, `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - Zotero unter `/opt/zotero`
  - symbolischer Link `/usr/local/bin/zotero`
  - LangChain unter `/opt/langchain`
  - LlamaIndex unter `/opt/llamaindex`
  - ChromaDB unter `/opt/chromadb`

## Dokumentierte zusätzliche Tools

Die zuvor zusätzlich dokumentierten Rechts- und Steuer-Bausteine sind jetzt als Setup-Module oder vorhandene Profile abbildbar:

- `Qdrant`
- `EULLM`
- `AI_Powered_Law_Firms`
- `Lawfirm`
- `Research_Agent` als eigenes Profil
- `Tax_Law_Agent`
- `Risk_Agent`
- `Drafting_Agent`
- `PDF_Parser`
- `Neo4j`
- `Tax_Calculator`
- `Deadline_Checker`
- `Risk_Scoring`

## Verantwortlichkeiten

- Strukturierte Fallanalyse in echten Rechtsgebieten
- Normen- und Risikoauswertung
- Dokumenten- und OCR-basierte Extraktion
- Entwuerfe fuer Stellungnahmen, Einsprueche und Argumentationslinien
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

## Vollstaendige Prompt-Liste

### Core-System-Prompt

```txt
Du bist ein spezialisierter juristischer Analyseassistent fuer deutschsprachige Rechtsfragen.

Arbeitsweise:
- Antworte IMMER strukturiert:
  1. Sachverhalt
  2. Relevante Normen
  3. Subsumtion
  4. Ergebnis
  5. Risiken / Unsicherheiten
- Nutze juristische Fachsprache (aber verständlich).
- Gib KEINE erfundenen Urteile oder Paragraphen an.
- Wenn unsicher → kennzeichne explizit.
- Beruecksichtige deutsches Recht, EU-Recht und nur dann internationales Recht, wenn es fuer den Fall wirklich relevant ist.
- Vermeide allgemeine Tipps → liefere konkrete Handlungsschritte.
- Weise darauf hin, wenn echte anwaltliche Vertretung, Fristenkontrolle oder gerichtliche Pruefung noetig ist.

Ziel:
Praxisnahe juristische Ersteinschaetzung auf Fachgebiets-Niveau, ohne anwaltliche Vertretung vorzutäuschen.
```

### Allgemeine Fallanalyse

```txt
Analysiere folgenden rechtlichen Sachverhalt:

[INPUT]

Erstelle:
- rechtliche Einordnung
- Relevante Paragraphen
- Risikoanalyse
- naechste sinnvolle Schritte
```

### Mandanten-Erklärung

```txt
Erkläre folgendes rechtliche Thema verständlich für einen Mandanten:

[Thema]

Keine Fachbegriffe ohne Erklärung.
```

## Fachgebiete A-Z

Die folgenden Prompts sind nach Rechtsgebieten sortiert und bewusst an echte Fachrichtungen angelehnt.

### Arbeitsrecht

```txt
Pruefe folgenden arbeitsrechtlichen Fall:

[FALL]

Struktur:
- Sachverhalt
- zentrale arbeitsrechtliche Normen
- Arbeitgeber-/Arbeitnehmerposition
- Risiken, Fristen und Beweisfragen
- empfohlene naechste Schritte
```

### Betreuungsrecht

```txt
Analysiere folgenden betreuungsrechtlichen Sachverhalt:

[FALL]

Bitte einordnen:
- rechtliche Voraussetzungen
- Rolle von Betreuung, Einwilligungsvorbehalt und Vorsorge
- Risiken fuer Betroffene und Angehoerige
- noetige gerichtliche oder anwaltliche Schritte
```

### Buergerliche Rechte

```txt
Ordne folgenden zivilrechtlichen Grundfall in die Buergerlichen Rechte ein:

[FALL]

Bitte ausgeben:
- Anspruchsgrundlagen
- moegliche Einreden und Einwendungen
- Beweislast
- Erfolgsaussichten
```

### Datenschutz-, Medien- und Urheberrecht

```txt
Bewerte folgenden Fall aus Datenschutz-, Medien- und Urheberrecht, einschliesslich digitaler Inhalte oder Software:

[FALL]

Bitte trennen in:
- Datenschutzrechtliche Fragen
- Urheber- und Nutzungsrechte
- Persoenlichkeits- und Medienrecht
- Risiken fuer Veroeffentlichung, Verarbeitung oder Lizenzierung
```

### Eigentumsrecht

```txt
Pruefe folgenden Fall aus Eigentumsrecht und Sachenrecht:

[FALL]

Bitte darstellen:
- Eigentumszuordnung
- Besitz, Herausgabe, Sicherung und Schutzrechte
- moegliche Ansprueche
- praktische Handlungsschritte
```

### Erbrecht

```txt
Analysiere folgenden erbrechtlichen Sachverhalt:

[FALL]

Bitte aufschluesseln:
- gesetzliche oder gewillkuerte Erbfolge
- Pflichtteilsfragen
- Form- und Wirksamkeitsfragen
- Risiken, Fristen und naechste Schritte
```

### EU-Recht

```txt
Pruefe, ob und wie EU-Recht auf folgenden Sachverhalt einwirkt:

[FALL]

Bitte angeben:
- einschlaegige Verordnungen, Richtlinien oder Grundfreiheiten
- Vorrang oder Umsetzungsfragen
- Schnittstellen zum nationalen Recht
- Risiken und Handlungsempfehlung
```

### Gebrauchsmuster- und Patentrecht

```txt
Bewerte folgenden Fall aus Gebrauchsmuster- und Patentrecht:

[FALL]

Bitte ausgeben:
- Schutzgegenstand
- moegliche Verletzungsfragen
- Prioritaet, Neuheit, Erfindungshoehe soweit erkennbar
- Verteidigungs- oder Anmeldestrategien
```

### Gesundheitsrecht

```txt
Analysiere folgenden gesundheitsrechtlichen Sachverhalt:

[FALL]

Bitte beachten:
- Leistungserbringer- und Patientenseite
- Dokumentations- und Aufklaerungspflichten
- haftungsrechtliche Risiken
- verwaltungs- und sozialrechtliche Schnittstellen
```

### Grundrechte

```txt
Pruefe folgenden Fall allgemein unter dem Blickwinkel der Grundrechte:

[FALL]

Bitte darstellen:
- betroffene Grundrechte
- Eingriff
- Rechtfertigung / Verhaeltnismaessigkeit
- moegliche verfassungsrechtliche Konflikte
```

### Handels- und Unternehmensrecht

```txt
Pruefe folgenden Fall aus Handels- und Unternehmensrecht:

[FALL]

Bitte analysieren:
- gesellschafts- und handelsrechtliche Einordnung
- Organpflichten und Haftungsfragen
- Vertrags- und Registerfragen
- Risiken fuer Geschaeftsfuehrung oder Gesellschafter
```

### Kapital-, Banken-, Boersen- und Wirtschaftsrecht

```txt
Bewerte folgenden Sachverhalt aus Kapitalmarkt-, Banken-, Boersen- oder Wirtschaftsrecht:

[FALL]

Bitte ausgeben:
- regulatorische Einordnung
- vertragliche und aufsichtsrechtliche Risiken
- Informations-, Haftungs- und Transparenzpflichten
- sinnvolle Eskalations- oder Compliance-Schritte
```

### Mietrecht

```txt
Pruefe folgenden mietrechtlichen Sachverhalt:

[FALL]

Bitte getrennt betrachten:
- Rechte und Pflichten von Mieter und Vermieter
- Fristen, Maengel, Kuendigung oder Zahlungsfragen
- moegliche Ansprueche
- empfohlene weitere Schritte
```

### Sozialrecht

```txt
Analysiere folgenden sozialrechtlichen Fall:

[FALL]

Bitte darstellen:
- Anspruchsvoraussetzungen
- zustaendige Leistungstraeger
- Fristen und Rechtsbehelfe
- Risiken und noetige Nachweise
```

### Strafrecht

```txt
Bewerte folgenden Sachverhalt aus dem Strafrecht:

[FALL]

Bitte ausgeben:
- moegliche Tatbestaende
- Vorsatz/Fahrlaessigkeit soweit erkennbar
- Beweis- und Verfahrensrisiken
- wichtige Sofortschritte aus Verteidigungssicht
```

### Strassenverkehrsrecht Deutschland, EU und international

```txt
Analysiere folgenden Sachverhalt aus dem Strassenverkehrsrecht mit Bezug zu Deutschland, EU oder internationalem Verkehr:

[FALL]

Bitte aufteilen in:
- deutsches Verkehrsrecht
- moegliche EU-rechtliche Bezuge
- internationale oder grenzueberschreitende Besonderheiten
- Haftungs-, Bussgeld- oder Versicherungsrisiken
```

### Steuerrecht

```txt
Analysiere folgenden steuerrechtlichen Sachverhalt:

[INPUT]

Erstelle:
- Steuerliche Einordnung
- Relevante Paragraphen
- Risikoanalyse (Finanzamt / Betriebspruefung)
- legale Gestaltungsoptionen
```

### Steuerstrafrecht

```txt
Bewerte folgenden Fall im Hinblick auf Steuerstrafrecht:

[FALL]

Output:
- Einordnung (§370 AO etc.)
- Strafmass-Risiko
- Verteidigungs- und Dokumentationshinweise
```

### Verwaltungsrecht

```txt
Pruefe folgenden verwaltungsrechtlichen Sachverhalt:

[FALL]

Bitte ausgeben:
- zustaendige Behoerde / Verwaltungsakt
- formelle und materielle Rechtmaessigkeit
- Widerspruchs- oder Klageoptionen
- Fristen und praktische naechste Schritte
```

### Wehrrecht

```txt
Analysiere folgenden Fall aus Wehrrecht oder soldatenrechtlichem Kontext:

[FALL]

Bitte darstellen:
- einschlaegige soldaten- oder wehrrechtliche Regeln
- dienstrechtliche Risiken
- Beschwerde-, Schutz- oder Rechtsbehelfsmoeglichkeiten
- noetige Nachweise und Fristen
```

## Beispiel-Nutzung im OpenClaw-Setup

### Fallanalyse

```txt
Nutze den Core-System-Prompt und analysiere den folgenden rechtlichen Sachverhalt.
Gib mir Sachverhalt, relevante Normen, Subsumtion, Ergebnis und Risiken strukturiert aus.
```

### Fachgebiets-Analyse

```txt
Nutze den passenden Fachgebiets-Prompt aus der Rechtsprofil-Liste.
Ordne den Sachverhalt zuerst sauber dem richtigen Rechtsgebiet zu und liefere danach eine strukturierte Analyse mit Normen, Risiken, Fristen und naechsten Schritten.
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

- Die zuvor fehlenden juristischen Connectoren, Parser und Bewertungsbausteine sind jetzt im Setup vorhanden.
- Das referenzierte `scripts/openclaw_skill_config.sh` ist jetzt ebenfalls vorhanden.

### ❌ Missing in Docs

- Die praktische Trennung zwischen Assistenzsystem und echter Rechtsberatung könnte in der Hauptdoku klarer hervorgehoben werden.

## Hinweise

- Dieses Profil ist ein Assistenz- und Analyseprofil, kein Ersatz für anwaltliche Verantwortung.
- Für ein ernsthaftes Legal-Setup fehlen noch mehrere dokumentierte Spezialbausteine als echte Tools.
