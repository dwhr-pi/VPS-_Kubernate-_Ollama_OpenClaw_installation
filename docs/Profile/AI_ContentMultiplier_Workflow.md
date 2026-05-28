# AI_ContentMultiplier_Workflow

## Zweck

Dieses Profil nutzt OpenClaw, Ollama und optional n8n, um aus Quellen wie URLs,
PDFs, Webseiten, YouTube-Transkripten oder LinkedIn-Inhalten mehrere
Content-Entwuerfe zu erzeugen.

## Typische Aufgaben

- Webseiten oder PDFs zusammenfassen
- LinkedIn-Posts aus einem Artikel erstellen
- Blogartikel und Newsletter aus einer Quelle ableiten
- X Threads und Facebook Posts vorbereiten
- FAQ und SEO Keywords erzeugen
- Ergebnisse in Nextcloud/myNextCloud ablegen
- Home Assistant ueber fertige Entwuerfe informieren

## Empfohlene Tools

- Ollama
- OpenClaw
- n8n optional
- Firecrawl optional
- Pandoc oder LibreOffice headless optional
- Nextcloud/myNextCloud optional
- Home Assistant optional

## Modelle

Lokal:

- `llama3.2:1b` fuer leichte Tests
- `llama3:latest` oder vorhandenes groesseres Modell fuer bessere Qualitaet

Optional Cloud:

- Gemini
- Claude
- OpenAI

Cloud-Modelle nur verwenden, wenn `ALLOW_CLOUD_MODE=true` bewusst gesetzt ist.

## OpenClaw-Workflow

1. Quelle entgegennehmen.
2. Inhalt extrahieren.
3. Analyse und Zielgruppenprofil erzeugen.
4. Content-Varianten erzeugen.
5. Review-Checkliste anhaengen.
6. Ergebnisse speichern.
7. Optional n8n, Home Assistant oder Nextcloud informieren.

## Speicherort

Empfohlen:

```text
~/.openclaw_ultimate_user_data/content-multiplier
```

Projekt- und Dokuordner:

```text
C:\Users\danie\Documents\GitHub\content-multiplier
```

## Sicherheitsregeln

- Keine automatische Veroeffentlichung.
- Keine API-Keys im Repository.
- Fremde Inhalte nur rechtmaessig analysieren.
- Ergebnisse immer als Entwurf markieren.
- Bei unklarer Rechtslage Review statt Veroeffentlichung.

## Beispiel-Prompt

```text
Analysiere diese URL und erstelle daraus ein Content-Paket:

Quelle: <URL>

Erzeuge:
- 2 LinkedIn Posts
- einen Blogartikel
- einen Newsletter
- einen X Thread
- eine FAQ
- SEO Keywords

Nutze Ollama lokal, wenn moeglich. Speichere alles als Markdown und fuege eine
Review-Checkliste hinzu. Nicht automatisch veroeffentlichen.
```

## Grenzen

- Das Profil ersetzt keine Rechtspruefung.
- Es darf keine Plattformregeln umgehen.
- Es darf nicht ungefragt posten.
- Es soll keine Login-geschuetzten Inhalte scrapen.
