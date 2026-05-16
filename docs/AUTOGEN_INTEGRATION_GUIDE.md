# AutoGen Integration Guide

## Kurzfassung

AutoGen beziehungsweise `pyautogen` ist ein Python-Framework fuer Multi-Agent-Chats, Agent-to-Agent-Kommunikation und toolgestuetzte Aufgaben. Es ist kein klassischer Webdienst und kein Desktopprogramm.

Nach der Installation liegt AutoGen typischerweise in:

```bash
/opt/autogen/venv
```

Das bedeutet:

- AutoGen wird ueber Python-Skripte, Agenten-Chats oder Worker genutzt.
- Es startet nicht automatisch als Webinterface.
- Es funktioniert nicht automatisch direkt in OpenClaw, nur weil es installiert ist.
- OpenClaw kann AutoGen spaeter ueber ein Tool-/Worker-Skript aufrufen.

## Installation pruefen

```bash
source /opt/autogen/venv/bin/activate
python -c "import autogen; print('AutoGen OK')"
pip show pyautogen
```

Wenn diese Befehle funktionieren, ist AutoGen als Bibliothek verfuegbar.

## Wofuer ist AutoGen sinnvoll?

AutoGen eignet sich fuer Multi-Agent-Dialoge, bei denen mehrere Agenten miteinander diskutieren, Aufgaben verteilen oder Loesungen pruefen.

Typische Muster:

- Planner-Agent erstellt einen Plan.
- Worker-Agent fuehrt Teilaufgaben aus.
- Reviewer-Agent prueft Ergebnis und Risiken.
- User-Proxy-Agent erzwingt manuelle Freigaben.
- Tool-Agent ruft nur erlaubte lokale Werkzeuge auf.

## Unterschied zu LangGraph und CrewAI

| Punkt | AutoGen | CrewAI | LangGraph |
|---|---|---|---|
| Denkmodell | Agenten-Chat und Dialogkoordination | Rollen und Aufgaben | Zustandsgraph |
| Staerke | Diskussion, Reviewer, User-Proxy | klare Teamrollen | kontrollierte Ablauflogik |
| Risiko | Agenten koennen sich gegenseitig zu Aktionen treiben | Rollen koennen zu breit werden | Graph kann komplex werden |
| OpenClaw-Nutzung | Multi-Agent-Worker | Rollen-Team-Worker | Graph-Worker |

Empfehlung:

- AutoGen fuer Review-/Diskussionsablaeufe.
- CrewAI fuer Rollen-Teams mit klaren Aufgaben.
- LangGraph fuer deterministischere Workflows mit Zustand.

## Welche vorhandenen Tools koennen AutoGen nutzen?

| Tool/Profil | AutoGen-Nutzen | Integrationsart |
|---|---|---|
| OpenClaw | AutoGen als Multi-Agent-Review-Worker | Toolskript/Worker |
| Ollama | lokale Modelle fuer Agenten | OpenAI-kompatibler Client oder LiteLLM |
| LiteLLM | einheitlicher Modellzugriff | API-Gateway |
| Qdrant/ChromaDB | gemeinsamer Kontext/RAG | Retriever-Tool |
| Langfuse | Prompt- und Run-Auswertung | Tracing |
| OpenLIT/OpenTelemetry | Observability | Instrumentierung |
| Promptfoo | Regressionstests fuer Agenten-Dialoge | Test-Harness |
| Aider/OpenHands | Coding-Agenten koennen AutoGen-Reviews nutzen | Projektintegration |
| n8n/Huginn | AutoGen-Worker per Webhook oder Script starten | Automation-Bruecke |

## OpenClaw-Zielbild

```text
OpenClaw Task
  -> scripts/autogen/run_autogen_task.py
  -> Planner/Worker/Reviewer/User-Proxy Agents
  -> Ollama/LiteLLM/Qdrant
  -> Markdown/JSON Report
  -> OpenClaw liest Ergebnis ein
```

Ergebnisse sollten unterhalb des Benutzer-Workspaces liegen:

```bash
~/.openclaw_ultimate_user_data/autogen/runs/
```

## Sinnvolle erste AutoGen-Szenarien

| Szenario | Agenten | Zweck |
|---|---|---|
| `repo_review_chat` | Planner, Code Reviewer, Docs Reviewer | Aenderungen diskutieren und Findings sortieren |
| `install_error_triage` | Log Analyst, Fix Planner, Safety Reviewer | Installationsfehler analysieren |
| `security_findings_review` | Scanner Analyst, Risk Reviewer, Fix Advisor | defensive Findings bewerten |
| `profile_design_review` | Architect, Tool Mapper, User Advocate | neue Profile gegen Dubletten pruefen |

## Minimale Konfiguration

```bash
export OLLAMA_BASE_URL=http://127.0.0.1:11434
export LITELLM_BASE_URL=http://127.0.0.1:4000
export AUTOGEN_OUTPUT_DIR="$HOME/.openclaw_ultimate_user_data/autogen/runs"
```

Externe API-Keys gehoeren nie ins Repo. Fuer lokale Modelle sollte Ollama oder LiteLLM bevorzugt werden.

## Sicherheit

- AutoGen-Agenten duerfen nicht ohne Freigabe Shell-/Browser-/Netzwerkaktionen ausfuehren.
- User-Proxy-/Approval-Schritt fuer riskante Aktionen vorsehen.
- Default: `read-only`, `dry-run`, Allowlist fuer Ziele.
- Keine Secrets im Chatverlauf, Agent-State oder Report.
- Security-, OSINT-, Web3- und Trading-Szenarien nur defensiv.

## TODO fuer spaeter

- [ ] `scripts/autogen/run_autogen_task.py` erstellen.
- [ ] `examples/autogen/repo_review_chat.py` erstellen.
- [ ] AutoGen-Smoke-Test in `scripts/doctor.sh` ergaenzen.
- [ ] OpenClaw-Tooldefinition fuer AutoGen-Aufrufe ergaenzen.
- [ ] Ausgabeordner `~/.openclaw_ultimate_user_data/autogen/runs` standardisieren.
- [ ] Optional Langfuse/OpenLIT-Tracing anbinden.
- [ ] User-Proxy-/Approval-Konzept fuer riskante Aktionen dokumentieren.
