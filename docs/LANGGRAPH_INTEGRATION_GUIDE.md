# LangGraph Integration Guide

## Kurzfassung

LangGraph ist kein Dienst mit eigenem Webinterface und kein Programm, das man dauerhaft wie Huginn, n8n oder Open WebUI startet. Es ist eine Python-Bibliothek fuer zustandsbehaftete Agenten- und Workflow-Graphen.

Das bedeutet:

- Installation legt typischerweise eine Python-Umgebung unter `/opt/langgraph/venv` an.
- Nutzung erfolgt ueber Python-Skripte, Notebooks, OpenClaw-Tools oder eigene Worker.
- LangGraph funktioniert nicht automatisch in OpenClaw, nur weil es installiert ist.
- OpenClaw kann LangGraph aber nutzen, sobald ein Tool-/Workflow-Skript LangGraph importiert und aufruft.

## Pruefen, ob LangGraph funktioniert

```bash
source /opt/langgraph/venv/bin/activate
python -c "import langgraph; print('LangGraph OK')"
pip show langgraph
```

Wenn diese Befehle funktionieren, ist LangGraph als Bibliothek verfuegbar.

## Wofuer ist LangGraph sinnvoll?

LangGraph ist besonders nuetzlich, wenn ein Agent nicht nur eine einzelne Antwort geben soll, sondern mehrere Schritte mit Zustand, Entscheidungspunkten und Wiederholungen braucht.

Typische Muster:

- Planen -> Tool ausfuehren -> Ergebnis pruefen -> naechster Schritt
- Recherche -> Quellen bewerten -> Zusammenfassung -> Report
- Codeanalyse -> Patchvorschlag -> Test -> Nachbesserung
- RAG-Frage -> Dokumente abrufen -> Antwort validieren
- Supportfall -> Kontext sammeln -> Klassifikation -> Antwort oder Eskalation
- Memory-Workflow -> neue Fakten extrahieren -> speichern -> spaeter injizieren

## Welche vorhandenen Tools koennen LangGraph nutzen?

| Tool/Profil | LangGraph-Nutzen | Integrationsart |
|---|---|---|
| OpenClaw | mehrstufige Agentenablaeufe, Tool-Orchestrierung, Memory-Workflows | eigenes OpenClaw-Tool oder Python-Worker |
| LiteLLM | einheitlicher Modellzugriff fuer Graph-Knoten | API-Client im LangGraph-Skript |
| Ollama | lokale Modelle fuer Graph-Knoten | OpenAI-kompatibel oder Ollama-Client |
| Qdrant/ChromaDB | RAG-Zustand und Dokumentabruf | Retriever-Knoten |
| Langfuse | Tracing, Prompt-/Run-Auswertung | Callback/Telemetry |
| OpenLIT/OpenTelemetry | Observability fuer Agentenablaeufe | Instrumentierung |
| Promptfoo | Regressionstests fuer Graph-Ausgaben | Test-Harness |
| n8n | LangGraph als externer lokaler Worker | HTTP/Webhook-Aufruf |
| Huginn | LangGraph als lokaler Script-/Webhook-Endpunkt | Agent ruft Worker auf |
| Flowise/LangFlow | visuelle Alternative, nicht identisch | eher Vergleich/Ergaenzung |
| Aider/OpenHands | Coding-Agenten koennen Graph-Logik als Projektbaustein nutzen | Python-Projektintegration |

## Minimaler lokaler Beispiel-Workflow

Dateiidee fuer spaeter:

`examples/langgraph/ollama_research_graph.py`

Ziel:

1. Nutzerfrage annehmen.
2. Optional Kontext aus Qdrant abrufen.
3. Ollama/LiteLLM aufrufen.
4. Antwort validieren.
5. Report als Markdown speichern.

Beispielhafte Umgebung:

```bash
export OLLAMA_BASE_URL=http://127.0.0.1:11434
export LITELLM_BASE_URL=http://127.0.0.1:4000
export LANGGRAPH_OUTPUT_DIR="$HOME/.openclaw_ultimate_user_data/langgraph/runs"
```

## OpenClaw-Anbindung, Zielbild

OpenClaw sollte LangGraph nicht blind als globale Abhaengigkeit verwenden, sondern ueber ein klares Tool:

```text
OpenClaw Task
  -> scripts/langgraph/run_graph_tool.py
  -> LangGraph Workflow
  -> Ollama/LiteLLM/Qdrant
  -> Markdown/JSON Ergebnis
  -> OpenClaw liest Ergebnis zurueck
```

Vorteile:

- OpenClaw bleibt der Orchestrator.
- LangGraph ist nur der Workflow-Motor fuer passende Aufgaben.
- Ergebnisse liegen nachvollziehbar unter `~/.openclaw_ultimate_user_data/langgraph/runs`.
- Fehler koennen in Diagnoseberichte aufgenommen werden.

## Sinnvolle erste Graphen fuer dieses Repo

| Graph | Zweck | Risiko |
|---|---|---|
| `repo_review_graph` | Repo scannen, Findings strukturieren, TODOs erzeugen | niedrig, read-only |
| `rag_answer_graph` | Frage mit Qdrant/Chroma-Kontext beantworten | mittel wegen Datenschutz |
| `install_log_diagnosis_graph` | Installationslogs auswerten und Reparaturvorschlaege machen | niedrig bis mittel |
| `profile_planner_graph` | Profilanforderung in Tools, Ports und Doku zerlegen | niedrig |
| `security_audit_graph` | defensive Checkliste aus Trivy/Semgrep/Gitleaks verdichten | mittel, nur eigene Systeme |

## Was noch fehlt

- Beispielskript `scripts/langgraph/run_graph_tool.py`
- Beispielgraphen unter `examples/langgraph/`
- OpenClaw-Tooldefinition fuer LangGraph-Aufrufe
- Ergebnisformat `reports/langgraph/*.json` und `*.md`
- Doctor-Check: LangGraph importierbar?
- Optionaler Langfuse/OpenLIT-Trace

## Sicherheit

- LangGraph darf keine unkontrollierten Shell-Aktionen ausfuehren.
- Schreibende Aktionen nur mit expliziter Freigabe.
- Browser-, Netzwerk- und Security-Knoten nur mit Allowlist.
- Keine Secrets in Graph-State, Logs oder Reports speichern.
- Bei OpenClaw-Integration standardmaessig `read-only` und `dry-run`.

## TODO fuer spaeter

- [ ] `scripts/langgraph/run_graph_tool.py` erstellen.
- [ ] `examples/langgraph/repo_review_graph.py` erstellen.
- [ ] OpenClaw-Tool fuer LangGraph registrieren.
- [ ] LangGraph-Ergebnisse in `~/.openclaw_ultimate_user_data/langgraph/runs` speichern.
- [ ] `scripts/doctor.sh` um LangGraph-Importcheck erweitern.
- [ ] Langfuse/OpenLIT optional anbinden.
- [ ] Doku-Beispiel fuer Ollama, LiteLLM und Qdrant kombinieren.
