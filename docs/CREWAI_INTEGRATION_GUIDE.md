# CrewAI Integration Guide

## Kurzfassung

CrewAI ist ein Python-Agentenframework fuer rollenbasierte Multi-Agent-Workflows. Es ist kein klassischer Dienst mit eigenem Webinterface und kein Desktopprogramm.

Nach der Installation liegt CrewAI typischerweise in:

```bash
/opt/crewai/venv
```

Das bedeutet:

- CrewAI wird ueber Python-Projekte, Skripte oder CLI-Aufrufe genutzt.
- Es startet nicht automatisch als Webdienst.
- Es funktioniert nicht automatisch direkt in OpenClaw, nur weil es installiert ist.
- OpenClaw kann CrewAI spaeter ueber ein Worker-/Toolskript aufrufen.

## Installation pruefen

```bash
source /opt/crewai/venv/bin/activate
python -c "import crewai; print('CrewAI OK')"
pip show crewai
```

Wenn diese Befehle funktionieren, ist CrewAI als Bibliothek verfuegbar.

## Wofuer ist CrewAI sinnvoll?

CrewAI eignet sich, wenn mehrere spezialisierte Rollen an einer Aufgabe arbeiten sollen.

Beispiele:

- Researcher sammelt Fakten.
- Analyst bewertet Quellen.
- Writer erstellt Bericht.
- Reviewer prueft Risiken und Luecken.
- Tool-Agent ruft lokale Tools oder APIs auf.

CrewAI passt daher gut zu Aufgaben, bei denen Rollen, Aufgabenlisten und Ergebnisartefakte klar definiert sind.

## Welche vorhandenen Tools koennen CrewAI nutzen?

| Tool/Profil | CrewAI-Nutzen | Integrationsart |
|---|---|---|
| OpenClaw | CrewAI als Multi-Agent-Worker fuer konkrete Tasks | Toolskript/Worker |
| Ollama | lokale LLMs fuer CrewAI-Agenten | LiteLLM/Ollama-Client |
| LiteLLM | einheitlicher Modellzugriff fuer CrewAI | API-Gateway |
| Open WebUI | manuelle Nutzung der Ergebnisse | Browser/Markdown-Reports |
| Qdrant/ChromaDB | Wissen/RAG fuer CrewAI-Rollen | Retriever-Tool |
| Langfuse | Run-/Prompt-Auswertung | Tracing |
| OpenLIT/OpenTelemetry | Observability | Instrumentierung |
| Promptfoo | CrewAI-Ausgaben testen | Regressionstests |
| n8n | CrewAI-Worker per Webhook starten | HTTP/CLI-Bruecke |
| Huginn | CrewAI-Worker aus Automation anstossen | Script/Webhook |
| Aider/OpenHands | CrewAI als Planungs-/Review-Unterstuetzung | Projektintegration |

## Unterschied zu LangGraph

| Punkt | CrewAI | LangGraph |
|---|---|---|
| Denkmodell | Rollen und Aufgaben | Graph mit Zustand und Kanten |
| Staerke | Team-/Rollen-Workflows | kontrollierte Zustandsmaschinen |
| Einstieg | oft einfacher fuer Aufgabenketten | besser fuer komplexe Kontrollfluesse |
| OpenClaw-Nutzung | Worker fuer Multi-Agent-Aufgaben | Worker fuer Graph-Workflows |
| Risiko | Rollen koennen zu viel autonom tun | Graph kann zu komplex werden |

Empfehlung:

- CrewAI fuer klar beschriebene Rollenworkflows.
- LangGraph fuer strikt kontrollierte, zustandsbehaftete Ablauflogik.

## Beispiel-Zielbild fuer OpenClaw

```text
OpenClaw Task
  -> scripts/crewai/run_crew_task.py
  -> CrewAI Team
  -> Ollama/LiteLLM/Qdrant
  -> Markdown/JSON Report
  -> OpenClaw liest Ergebnis ein
```

Ergebnisse sollten unterhalb des Benutzer-Workspaces liegen:

```bash
~/.openclaw_ultimate_user_data/crewai/runs/
```

## Sinnvolle erste CrewAI-Teams fuer dieses Repo

| Team | Rollen | Zweck |
|---|---|---|
| `repo_maintainer_team` | Researcher, Code Reviewer, Docs Writer | Repo-Aenderungen bewerten |
| `install_diagnosis_team` | Log Analyst, Fix Planner, Safety Reviewer | Installationsfehler auswerten |
| `profile_builder_team` | Architect, Tool Mapper, Doc Writer | neue Profile sauber planen |
| `security_review_team` | Auditor, SBOM Analyst, Hardening Advisor | defensive Security-Berichte |
| `creator_planning_team` | Prompt Designer, Media Planner, Rights Checker | Creator-Workflows planen |

## Minimale Konfiguration

CrewAI braucht je nach Modellzugriff eine lokale oder Gateway-Konfiguration:

```bash
export OLLAMA_BASE_URL=http://127.0.0.1:11434
export LITELLM_BASE_URL=http://127.0.0.1:4000
export CREWAI_OUTPUT_DIR="$HOME/.openclaw_ultimate_user_data/crewai/runs"
```

API-Keys gehoeren niemals ins Repo. Wenn externe Provider genutzt werden, muessen sie in `~/.openclaw_ultimate_user_data` oder in sicherer Shell-/Service-Konfiguration liegen.

## Sicherheit

- CrewAI-Agenten duerfen nicht blind Shell-, Browser- oder Netzwerkaktionen ausfuehren.
- Default: `read-only`, `dry-run`, manuelle Freigabe fuer Aenderungen.
- Keine Secrets in Aufgabenbeschreibung, Logs oder Reports.
- Security-, OSINT-, Web3- und Trading-Rollen nur defensiv und mit Allowlist.
- Ergebnisse immer als nachvollziehbaren Markdown/JSON-Report speichern.

## TODO fuer spaeter

- [ ] `scripts/crewai/run_crew_task.py` erstellen.
- [ ] `examples/crewai/repo_maintainer_team.py` erstellen.
- [ ] CrewAI-Smoke-Test in `scripts/doctor.sh` ergaenzen.
- [ ] OpenClaw-Tooldefinition fuer CrewAI-Aufrufe ergaenzen.
- [ ] Ausgabeordner `~/.openclaw_ultimate_user_data/crewai/runs` standardisieren.
- [ ] Optional Langfuse/OpenLIT-Tracing anbinden.
- [ ] Beispiel fuer Ollama/LiteLLM-Modellwahl dokumentieren.
