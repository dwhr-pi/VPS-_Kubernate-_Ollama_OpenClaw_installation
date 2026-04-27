# Chatverlauf – Rechtsberatung_Steuerrecht / Ollama OpenClaw

## User
Promt Liste für Rechtsanwälte erstellen, welche Tools wären außerdem für mein Ollama OpenClaw Projekt für das Profil Rechtsberatung_Steuerrecht sinnvoll:  
https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation

---

## Assistant

Nice – das ist genau die richtige Richtung für ein ernstzunehmendes Legal-AI Setup 👍  

Ich bau dir das sauber in 3 Teile auf:

---

# 🧠 1. Prompt-Liste für „Rechtsberatung_Steuerrecht“ (Ollama / OpenClaw ready)

Die wichtigste Erkenntnis aus Legal-AI:  
👉 Strukturierte Prompts schlagen rohe Intelligenz  
👉 RAG + klare Rollen reduzieren Halluzinationen massiv  

---

## ⚖️ Core-System-Prompt (Pflicht)
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

📑 Prompt: Steueranalyse (Standardfall)
```
Analysiere folgenden steuerrechtlichen Sachverhalt:

[INPUT]

Erstelle:
- Steuerliche Einordnung
- Relevante Paragraphen
- Risikoanalyse (Finanzamt / Betriebsprüfung)
- Optimierungsmöglichkeiten (legal!)
```

💼 Prompt: Betriebsprüfung / Finanzamt
```
Simuliere eine Betriebsprüfung.

Input:
[Unterlagen]

Output:
- Auffälligkeiten
- mögliche Nachzahlungen
- Strafrisiken (Steuerhinterziehung / leichtfertige Verkürzung)
- Verteidigungsstrategie
```

📊 Prompt: Steueroptimierung
```
Zeige legale Steueroptimierungen für:

[Situation]

Struktur:
- Sofortmaßnahmen
- Gestaltungsspielräume
- Risiken / Graubereiche
- langfristige Strategie
```

📜 Prompt: Einspruch gegen Steuerbescheid
```
Erstelle eine juristische Argumentation gegen folgenden Steuerbescheid:

[Bescheid]

Output:
- Begründung (mit Normen)
- Argumentationslinie
- Erfolgsaussichten
```

🧾 Prompt: Vertragsprüfung (steuerlich)

```
Prüfe folgenden Vertrag auf steuerliche Risiken:

[Vertrag]

Output:
- steuerliche Bewertung
- kritische Klauseln
- Optimierungsvorschläge
```

⚠️ Prompt: Risiko / Strafrecht
```
Bewerte folgenden Fall im Hinblick auf Steuerstrafrecht:

[Fall]

Output:
- Einordnung (§370 AO etc.)
- Strafmaß-Risiko
- Handlungsempfehlung
```

🤖 Prompt: Mandanten-Erklärung (vereinfachte Sprache)
```
Erkläre folgendes steuerliches Thema verständlich für einen Mandanten:

[Thema]

Keine Fachbegriffe ohne Erklärung.
```

## 🧩 2. Tools für dein Ollama + OpenClaw Legal Stack
🔥 MUST-HAVE Infrastruktur
### 1. RAG + Dokumentensuche
* LangChain
* LlamaIndex
### 2. Vector DB
* Qdrant
* Chroma
### 3. EU-konforme Modelle / Hosting
* EULLM
### 4. Legal-spezifische Modelle
* ALIENTELLIGENCE/aipoweredlawfirms
* ALIENTELLIGENCE/lawfirm

🧠 Advanced Legal AI Layer
### 5. Multi-Agent System
* Research Agent
* Tax Law Agent
* Risk Agent
* Drafting Agent
### 6. OCR + Dokumentverarbeitung
* Tesseract OCR
* PDF Parser
### 7. Knowledge Graph
* Neo4j
## ⚙️ 3. Spezifisch für Steuerrecht
### 📚 Datenquellen
* AO (Abgabenordnung)
* EStG
* UStG
* BFH Urteile
* BMF Schreiben
### 🧮 Spezielle Tools
* Steuerberechnung (Python Tool)
* Fristen-Checker
* Risiko-Scoring
## 🧱 4. Empfohlene Architektur
```
Ollama
  ↓
OpenClaw (Agent Orchestrator)
  ↓
RAG Layer (LangChain / LlamaIndex)
  ↓
Vector DB (Qdrant)
  ↓
Legal Daten (Gesetze + Urteile)
  ↓
Tools:
  - Steuerrechner
  - OCR
  - Fristenmodul
```

🚀 Bonus: Realistische Erwartung
* AI = Assistenzsystem, kein Anwalt
* Halluzinationen möglich
* Mit Setup → Associate-Level realistisch erreichbar



xxxxxxxx
## Assistant (Abschluss)
👉 Wenn du willst:
* komplettes OpenClaw Agent-Setup (YAML + Tools)
* fertige RAG Pipeline für deutsches Steuerrecht
* Multi-Agent System wie eine echte Kanzlei
Sag einfach: „baue mir das Setup“
```

```

```

```

```

```
