# Ollama Modellkatalog

Diese Übersicht bündelt die im Setup aktuell empfohlenen oder bereits berücksichtigten Ollama-Modelle.
Sie sind für lokale Nutzung, OpenClaw, Codex-Nachbau, RAG oder LLM-Builder-Workflows geeignet.

Wichtig:

- Die Werte für Downloadgröße und RAM sind praktische Richtwerte.
- Je nach Quantisierung, GPU, Unified Memory und Kontextfenster kann der echte Bedarf spürbar abweichen.
- Die Installation und Entfernung ist im Setup jetzt zusätzlich über den `Ollama Modellkatalog` im Optionen-Menü möglich.

## Allgemeine Modelle

| Modell | Downloadgröße | Empf. RAM | Zweck |
|---|---:|---:|---|
| `llama3.2:3b` | ca. 2.0 GB | ab 8 GB | Leichtes Allround-Modell für Tests, kleine lokale Assistenten und UI-Prüfungen |
| `qwen2.5:7b` | ca. 4.7 GB | ab 12 GB | Starkes allgemeines Instruct-Modell für lokale Assistenten, RAG und OpenClaw |
| `mistral:7b` | ca. 4.1 GB | ab 12 GB | EU-naher Allrounder aus dem Mistral-Umfeld für allgemeine Textaufgaben |
| `gemma3:4b` | ca. 3.3 GB | ab 8 GB | Kompaktes Modell für sparsame lokale Nutzung |
| `phi4:14b` | ca. 9.1 GB | ab 20 GB | Stärkeres Modell für Analyse, Reasoning und schwierigere lokale Aufgaben |
| `deepseek-r1:8b` | ca. 5.2 GB | ab 12 GB | Reasoning-Ableger für Planung, Analyse und schrittweises Denken |

## Finanzdatenanalyse / Trading-Analyse

Für Finanzdatenanalyse sind im lokalen Setup vor allem Modelle sinnvoll, die:

- strukturiert Tabellen, Zahlen und Meldungen auswerten können
- sauberes Reasoning für Szenarien, Risiko und Gegenargumente liefern
- sich mit GitHub-basierten Finanzprojekten kombinieren lassen

| Modell / Stack | Downloadgröße | Empf. RAM | Zweck |
|---|---:|---:|---|
| `qwen3:4b` | ca. 2.6 GB | ab 8 GB | Kompakter Finanzanalyse-Einstieg für MiniPC, Meldungen, Watchlists und einfache Kennzahlen |
| `qwen3:30b` | ca. 19 GB | ab 32 GB | Starkes lokales Analysemodell für Berichte, Tabellen, Earnings-Zusammenfassungen und mehrstufige Auswertung |
| `deepseek-r1:8b` | ca. 5.2 GB | ab 12 GB | Lokaler Reasoning-Stack für Risikoargumentation, Szenarien und Backtest-Erklärungen |
| `deepseek-r1:14b` | ca. 9.0 GB | ab 20 GB | Größerer Reasoning-Ableger für komplexere Finanz- und Marktanalysen |
| `FinGPT` (GitHub) | Repo-basiert | ab 16 GB | Open-Source Finanz-LLM-Stack zum Fine-Tuning, Testen und Weiterentwickeln |
| `FinRobot` (GitHub) | Repo-basiert | ab 16 GB | Agentische Finanzanalyse mit Reports, Equity-Research und Workflows |
| `FinRAG` (GitHub) | Repo-basiert | ab 12 GB | Finanz-RAG für Berichte, Dokumente, Research und Wissensabfragen |

### Empfohlene Startbefehle

Für lokale Analyse mit Ollama:

```bash
ollama pull qwen3:4b
ollama pull qwen3:30b
ollama pull deepseek-r1:8b
ollama pull deepseek-r1:14b
```

Für GitHub-basierte Weiterentwicklung im Setup:

- `FinGPT`
- `FinRobot`
- `FinRAG`

Diese drei Stacks sind keine simplen Gewichtsdateien, sondern weiterentwickelbare Open-Source-Projekte für Finanzanalyse, RAG und agentische Auswertung.

## Coding- und Agentenmodelle

| Modell | Downloadgröße | Empf. RAM | Zweck |
|---|---:|---:|---|
| `qwen2.5-coder:7b` | ca. 4.7 GB | ab 12 GB | Leichtes Coding-Modell für lokalen Codex-Nachbau, Diff-Arbeit und Skript-Fixes |
| `qwen3-coder:30b` | ca. 19 GB | ab 32 GB | Großes agentisches Coding-Modell mit langem Kontext für Repository-Verständnis |
| `devstral:24b` | ca. 14 GB | ab 32 GB | Agentisches Software-Engineering-Modell für Multi-File-Edits und Tool-Nutzung |

## EU-LLMs / Europa-nahe Modelle

Hier sind vor allem Modelle aus dem Mistral-Umfeld relevant, weil Mistral AI ein europäischer Anbieter ist und diese Modelle gut zu lokalen oder hybriden Produktiv-Setups passen.

| Modell | Downloadgröße | Empf. RAM | Zweck |
|---|---:|---:|---|
| `mistral:7b` | ca. 4.1 GB | ab 12 GB | Kompakter europäischer Allrounder |
| `mistral-nemo:12b` | ca. 7.1 GB | ab 16 GB | EU-LLM mit guter Balance aus Qualität und Hardwarebedarf |
| `mistral-small:24b` | ca. 14 GB | ab 32 GB | Stärkeres allgemeines EU-Modell für anspruchsvollere Produktivaufgaben |
| `codestral:22b` | ca. 13 GB | ab 28-32 GB | EU-Coding-Modell für Programmierung, Refactoring und Build-Hilfe |
| `devstral:24b` | ca. 14 GB | ab 32 GB | EU-naher agentischer Software-Engineering-Stack |

## LLM-Builder Startempfehlungen

Für das neue Profil `LLM-Builder` sind als realistische Startpunkte besonders sinnvoll:

```bash
ollama pull llama3.2:3b
ollama pull qwen2.5:7b
ollama pull mistral:7b
```

Für stärkere oder spezialisierte Coding-/Agentenpfade:

```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen3-coder:30b
ollama pull devstral:24b
```

## Empfehlung nach Hardware

### Kleine Systeme

- `llama3.2:3b`
- `gemma3:4b`
- `qwen2.5:7b`
- `qwen3:4b`

### Mittlere Systeme

- `mistral:7b`
- `qwen2.5-coder:7b`
- `deepseek-r1:8b`
- `mistral-nemo:12b`
- `deepseek-r1:14b`

### Größere Systeme

- `phi4:14b`
- `mistral-small:24b`
- `devstral:24b`
- `qwen3-coder:30b`
- `qwen3:30b`

## Nutzung in OpenClaw

Diese Modelle können in unserem Setup grundsätzlich für OpenClaw genutzt werden, sofern:

1. `Ollama` installiert ist
2. das Modell per `ollama pull` vorhanden ist
3. die `.env` oder `config.json` auf das gewünschte Modell zeigt

Typische Felder:

```env
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=qwen2.5:7b
```

## Sicherheitshinweis

Große Modelle und experimentelle Modellpfade sollten nicht blind in öffentliche oder unsichere Umgebungen ausgerollt werden.
Für produktive oder öffentliche Setups sind zusätzlich sinnvoll:

- abgesichertes Gateway
- Rate Limits
- Logging
- Fallback-Routing
- API-Key-Isolation
