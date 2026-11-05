# Audit: lokale Multi-Agent-Architektur

Stand: 05.11.2026. **Audit und Vorschlag, keine implementierte Multi-Agent-Runtime.**

## Umfang und Ausgangspunkt

Gelesener Checkout: `codex/claude-review-p0-20261103`, Commit
`eecbfd99015c19a8d8a463df3c47767ee20ff53b`. Arbeitsverzeichnis vor Beginn sauber.
Online-main: `1d8f6d9ce21807e8e841b8f3b3f15a87defbd583`.
Der lesende GitHub-Compare meldet main einen Commit voraus, keinen dahinter und **null geaenderte Dateien**.
Damit entspricht der untersuchte Dateistand bei dieser Abfrage main; lokale Branches wurden nicht umgestellt.

Geprueft wurden Agentenkataloge, Workbench, Broker, SDK-Adapter, native Buildvertraege,
Profilgeneratoren, beide Queue-Familien, systemd-Worker, CI, Compose-Referenz und Navigation.
Beruecksichtigt: [vorhandene Bestandsmatrix](../agents/CODING_AGENT_INVENTORY.md),
[Workbench-Vertrag](../agents/LOCAL_CODING_WORKBENCH.md),
[Security-Audit](../security/SECURITY_ARCHITECTURE_AUDIT_2026-10-25.md),
[aktueller Review](../CLAUDE_REVIEW_2026-11-03.md) und [Installationsrichtlinie](../INSTALLATION_POLICY.md).
Dies ist keine erneute zeilenweise Abnahme aller rund 400 Tool-Installer oder eines laufenden Clusters.

Keine privaten Installationsmarker, Keys oder Benutzer-Workspaces gelesen. Keine Installation,
Modellanfrage, Container-/Dienstaktion, WSL-Abfrage, Git-Branch-Aenderung, Commit, Push oder Merge.
Lediglich zwei neue Review-Dokumente und temporaere Offline-Testfixtures wurden geschrieben.

## Wichtigste Befunde

| Prioritaet | Beleg | Befund und Konsequenz |
|---|---|---|
| P0 | `scripts/queue/queue_worker.sh:58`, `scripts/queue/queue_run_next.sh`, `scripts/tools/job_queue_worker.sh:83` | Queues fuehren gespeicherte Befehle mit `bash -lc` auf dem Host aus. Timeout/Lock sind keine Sandbox. Niemals Modellantworten dort als Shell-Jobs einspeisen. |
| P0 | `scripts/tools/job_queue_worker.sh:103` | Legacy-Stop verwendet eine PID-Datei ohne Prozessidentitaetsnachweis; bei PID-Wiederverwendung ist ein falsches Ziel moeglich. Neuen Controller nicht an diesen Stop-Vertrag anbinden. |
| P0 | `scripts/agents/workbench.py:166`, `:201`, `:230` | Einmal-Worker verlangen Linux/non-root und einen vorhandenen Docker-Daemon. Keine automatische Docker-Installation, aber unter der verbindlichen Docker-freien Zielarchitektur kein zulaessiges neues Ausfuehrungsbackend. Nicht stillschweigend auf unisolierte Hostprozesse ausweichen. |
| P1 | `scripts/tools/langgraph_install.sh:5`, `scripts/tools/crewai_install.sh:5`, `scripts/tools/helpers/python_tool_common.sh:45` | Primarpakete kommen per ungepinntem pip, nicht als gepruefter Git-Source-Build; generische Abhaengigkeits-Upgrades sind nicht reproduzierbar. Installer vorhanden ist hier keine Richtlinienkonformitaet. |
| P1 | `scripts/tools/helpers/agent_framework_common.sh:5`, `:136` | Framework-Core hat einen festen Git-Pin und eine private venv. Transitive PyPI-Abhaengigkeiten werden dennoch ohne gehashten Voll-Lock aufgeloest. Vor PoC einen reproduzierbaren Buildvertrag ergaenzen. |
| P1 | `config/agents/workbench.json`, `scripts/agents/workbench.py:18`, `:167` | Vier Rollen statt sechs; Limits stammen aus Python-Konstanten, nicht aus dem konfigurierten Limits-Objekt. Der globale Lock serialisiert Runs. Konfigurierbare Parallelitaet/rollenbezogene Ressourcen sind nicht implementiert. |
| P1 | `scripts/agents/workbench.py:131`, `:141` | Jeder neue Lauf verlangt einen sauberen Worktree. Nach einer Implementierung ist dieser absichtlich dirty: Tester/Reviewer lassen sich deshalb nicht einfach hintereinander mit demselben Verzeichnis aufrufen. Nicht durch Entfernen der Sauberkeitspruefung umgehen. |
| P1 | `scripts/agents/workbench.py:142`, `:275`, `scripts/agents/worker_entry.py:130` | Dateinamenfilter und private Transkripte sind keine inhaltliche DLP/Redaktion. In Code oder Prompts enthaltene Geheimnisse koennten im lokalen Modellkontext/Transkript landen. Kein konkreter Secret-Fund behauptet. |
| P1 | `scripts/agents/model_broker.py:84`, `config/agents/workbench.json` | Modell-/Request-/Ausgabetoken-Gates vorhanden; keine serverweite VRAM-Zuteilung oder komplette Nutzungsbilanz. CPU/RAM-Grenzen des Workers begrenzen nicht den separaten Ollama-Prozess. |
| P2 | `scripts/systemd/openclaw-queue-worker.service`, `scripts/tools/job_queue_worker.sh` | Unterschiedliche TSV/SQLite/JSONL-Zustaende und Worker-/Stop-Vertraege, keine gemeinsame Recovery-Schnittstelle. systemd-Vorlage ohne CPU-/RAM-/Dateisystem-Haertung. Keine dieser Dateien hier gestartet. |
| P2 | `readme.md:77`, `docs/legacy/README_FULL_2026_11_01.md:266` | Alltagslinks sind nur als historische Abschnittslinks direkt auffindbar. Das verbirgt wichtige Bedienung und fuehrt zu veralteten One-Linern/Update-Erklaerungen. Aktuelle Schnellnavigation getrennt anbieten. |

Die vorhandenen Schutzmechanismen bleiben wertvoll: Pfad-/Linkpruefungen, separate Worktrees,
Explizitfreigabe, Loopback-Broker, Modell-Digest, Netzwerk-Allowlist, Groessen-/Zeitbudgets,
Non-root und Capability-Drop im bisherigen Containervertrag. Sie sind kein Nachweis eines
Docker-freien, sechs Rollen umfassenden Gesamtsystems.

## Bestandsmatrix

Stufen beziehen sich auf **diese Integration**, nicht auf die allgemeine Reife eines Upstreams:
`planned` = Zielbild; `documented` = nachvollziehbar beschrieben; `installable` = konkreter
Bereitstellungspfad mit Voraussetzungen; `tested` = benannter Testumfang;
`stable` = reproduzierbare echte Betriebs-/Recovery-Abnahme. Stufen sind nicht automatisch kumulativ.

| Komponente | Bestand und genaue Pfade | Einordnung | Fehlender Nachweis |
|---|---|---|---|
| Jarvis-Core | `config/agents/coding_agents.json`, `scripts/profiles/coding_agents.py:217` | `planned`, `documented`, Profil-Fixtures `tested` | Routing liefert einen Plan mit `executed:false`; kein laufender Team-Orchestrator. |
| OpenClaw | `scripts/tools/openclaw_install.sh`, `ansible/playbooks/core_ai_setup.yml` | `documented`, bedingt `installable` | Keine hier gepruefte Runtime, keine nachgewiesene Delegation dieser sechs Rollen. |
| Ollama | `scripts/tools/ollama_install.sh`, `scripts/agents/model_broker.py` | `documented`, bedingt `installable`; Broker-Mocks `tested` | Lokales Modell, Tool-Calling, Responses-Kompatibilitaet, VRAM und reale Inferenz ungetestet. |
| LiteLLM | `scripts/tools/litellm_install.sh`, `stacks/llmops-platform/litellm-config.yaml` | `documented`, bedingt `installable` | Workbench-Broker erlaubt direktes Loopback-Ollama, keinen beliebigen Gateway-Endpunkt. Compose mit `main-latest` ist kein gepinnter nativer Integrationsbeleg. |
| LangGraph | `scripts/tools/langgraph_install.sh`, `config/tools.yml` | `documented`; Paketinstaller vorhanden | Kein Git-Pin/Lock im generischen Paketweg, kein implementierter Zustandsgraph. |
| CrewAI | `scripts/tools/crewai_install.sh`, `config/tools.yml` | `documented`; Paketinstaller vorhanden | Gleiche Source-/Lock-Luecke; Team-Prompt ist keine Runtime. |
| Microsoft Agent Framework | `scripts/tools/helpers/agent_framework_common.sh`, `tests/test_agent_framework_source.py` | `documented`, bedingt `installable`; bestehende Mocktests | Core-Version 1.22.0 gepinnt; Dependency-Lock und echte lokale Workflow-Abnahme offen. |
| OpenCode | `config/agents/native_clis.json`, `scripts/agents/install_cli.py`, `scripts/tools/opencode_install.sh` | `documented`, bedingt `installable`, Offline-Fixtures `tested` | Kein echter Bun-Build, CLI-/Modelllauf oder Sandbox-Nachweis in dieser Runde. |
| Aider | `scripts/tools/aider_install.sh`, `scripts/agents/install_cli.py:197`, `worker_entry.py:75` | `documented`, bedingt `installable`, Offline-Fixtures `tested` | Gehashter Dependency-Lock erforderlich; keine reale Codeaenderung oder Modellabnahme. |
| Codex CLI | `scripts/tools/codex_cli_install.sh`, `config/agents/native_clis.json`, `worker_entry.py:68` | `documented`, bedingt `installable`, Offline-Fixtures `tested` | Cargo-Buildvertrag vorhanden; kein echter Build/Responses-Dialog. OpenAI-Dienst ist nicht fuer jeden lokalen Lauf zwingend. |
| OpenHands | `scripts/agents/openhands_task.py`, `config/agents/native_clis.json` | SDK-Quellbereitstellung `installable`, Adapter-Mocks `tested` | `source-only`, `runtime_ready:false`; nicht OpenHands-Webapp und kein fertiger Worker. |
| MCP | `config/agents/coding_agents.json`, `scripts/tools/mcpo_install.sh` | Rollen-/Toolvorlagen `documented` | Keine durchgaengige Identitaets-/Rechte-/Methodenfreigabe fuer alle Teamrollen nachgewiesen. |
| Scheduler/Queue | `scripts/queue/`, `scripts/tools/job_queue_worker.sh` | Code vorhanden; Lock-/Retry-Fixtures in `tests/test_queue_safety.py` | Keine sichere Ausfuehrungsgrenze fuer beliebige Agentenbefehle. Nicht unveraendert als Agenten-Worker verwenden. |
| Worktrees/CI | `scripts/agents/workbench.py:115`, `.github/workflows/coding-agents.yml` | Worktree- und Adapter-Fixtures `tested` | Isolation gegen Git-Metadatenzugriff und native Sandbox erst live abnehmen. |

**Keine dieser neuen Multi-Agent-Verbindungen erhaelt `stable`.**
Private Installationen wurden nicht abgefragt; aus Registry-Eintraegen wird kein installierter Zustand abgeleitet.

## Aktuelle Upstreams und Lizenzen

Primaerquellen am 05.11.2026 direkt gelesen: offizielle Repository-Metadaten,
GitHub-Releases und Root-Lizenzdateien. Alle sechs Repositories waren nicht archiviert;
Push-Zeitpunkte lagen am 04./05.11.2026. Aktivitaet ist weder Sicherheits- noch Kompatibilitaetsgarantie.
Releases sind Beobachtungen, keine automatisch uebernommenen Build-Pins.

| Projekt | Beobachteter Release | Lizenz und Einordnung |
|---|---|---|
| LangGraph | Core [1.2.19](https://github.com/langchain-ai/langgraph/releases/tag/1.2.19), 30.10.; SDK `0.4.12`, 03.11. | [MIT](https://raw.githubusercontent.com/langchain-ai/langgraph/main/LICENSE). GitHub `/releases/latest` zeigt den SDK-Tag, nicht die Core-Paketversion. |
| CrewAI | [1.15.35](https://github.com/crewAIInc/crewAI/releases/tag/1.15.35), 03.11. | [MIT](https://raw.githubusercontent.com/crewAIInc/crewAI/main/LICENSE); Dienste und Modellanbieter gesondert pruefen. |
| Microsoft Agent Framework | [python-1.24.0](https://github.com/microsoft/agent-framework/releases/tag/python-1.24.0), 30.10. | [MIT](https://raw.githubusercontent.com/microsoft/agent-framework/main/LICENSE); Python-Release nicht als .NET-Version ausgeben. Lokaler Vertrag bleibt 1.22.0. |
| Codex CLI | [rust-v0.166.0](https://github.com/openai/codex/releases/tag/rust-v0.166.0), 29.10. | [Apache-2.0](https://raw.githubusercontent.com/openai/codex/main/LICENSE); CLI-Lizenz, Modellgewichte und Providervertrag unterscheiden. |
| OpenCode | [v1.19.5](https://github.com/anomalyco/opencode/releases/tag/v1.19.5), 28.10. | [MIT](https://raw.githubusercontent.com/anomalyco/opencode/dev/LICENSE); vorhandenen Pin nicht stillschweigend aktualisieren. |
| OpenHands | [v1.35.0](https://github.com/OpenHands/OpenHands/releases/tag/v1.35.0), 03.11. | [Root-MIT](https://raw.githubusercontent.com/OpenHands/OpenHands/main/LICENSE). Lokaler Vertrag nutzt **software-agent-sdk**, nicht dieses App-Release. Komponenten/Dienste separat lizenzieren. |

API-Nachweise: `https://api.github.com/repos/OWNER/REPO` und dort `/releases/latest`,
fuer LangGraph zusaetzlich `/releases?per_page=15`, mit den oben ausgeschriebenen Repository-Namen.
Keine Suchsnippets wurden als Lizenz- oder Release-Beleg verwendet.
Die [offizielle lokale Provider-Konfiguration](https://learn.chatgpt.com/docs/config-file/config-advanced#oss-mode-local-providers)
beschreibt Ollama/LM Studio. Das beweist nicht die Kompatibilitaet des im Setup gepinnten Codex-Builds.

## Architekturentscheidung fuer den ersten PoC

**Genau ein primaerer Workflow-Orchestrator: Microsoft Agent Framework (Python-Core).**
Begruendung: vorhandener fester Git-Pin, private Installation, Lifecycle und Mocktests.
Keine automatische Migration auf 1.24.0. Zuerst Voll-Lock, API-Vertrag des bestehenden Pins und
Sandbox pruefen. LangGraph/CrewAI bleiben optionale, standardmaessig deaktivierte Alternativen,
nicht gleichzeitig laufende Scheduler. Die Auswahl ist eine Empfehlung, keine bereits erfolgte Integration.

```text
Mensch -> Task/Quell-Snapshot -> Planner -> Explorer
                                       -> Freigabe fuer begrenzte Schreibphase
                                       -> Worker (eigener Worktree)
                                       -> unveraenderlicher Patch/Snapshot
                                       -> Tester -> Reviewer -> Security
                                       -> menschliche Endfreigabe
```

OpenClaw/Jarvis duerfen spaeter validierte Tasks einreichen, nicht freie Shellstrings.
Worker-CLIs sind austauschbare Adapter, keine weiteren Orchestratoren. Ollama ist die lokale
Inferenz; LiteLLM nur separat freigegebener lokaler Adapter mit eigenem Broker-Vertrag.
Keine Gleichwertigkeit zur Codex-Desktop-App oder zu deren internen Subagenten behaupten.

| Rolle | Minimalrechte | Ergebnis |
|---|---|---|
| Explorer | Repository-Snapshot read-only; kein Shell-/Netzwerkzugriff als Standard | Dateipfade, Abhaengigkeiten, belegte Fundstellen |
| Planner | Kontextartefakte read-only | Plan, Teilaufgaben, Akzeptanzkriterien |
| Worker | Nur bestaetigter neuer Worktree beschreibbar; Git-Steuerdaten verborgen | Patch, Dateihashes, Implementierungsbericht; kein Commit/Push |
| Tester | Worker-Snapshot read-only, eigenes fluechtiges Build-/Testverzeichnis | Exitcodes, Tests, Coverage; kein freies Host-Testkommando |
| Reviewer | Quell- und Patch-Snapshot read-only | Unabhaengige Befunde mit Dateipfaden |
| Security | Gleicher Snapshot, nur explizite lokale Scanner | Policy-/Secret-/Abhaengigkeitsbefunde; kein Zugriff auf echte Keys |

Startwert: ein aktiver Worker und ein gleichzeitiger Modellrequest, 2 CPUs, 2 GiB RAM,
128 PIDs, 900 Sekunden pro Rolle. Gesamtbudget fuer Rollen/Retry zusaetzlich erzwingen.
VRAM ist kein durch einen CLI-Prozess durchsetzbares Cgroup-Limit: Modellgroesse/Quantisierung,
Serverparallelitaet, Context und beobachtete GPU-Reserve vorab abnehmen; keine globalen Ollama-Settings automatisch aendern.

## Sicherheits- und Recovery-Vertrag

Linux-PoC: natives, vorher geprueftes Namespace-/Dateisystem-Backend, etwa Bubblewrap,
plus delegierte systemd/Cgroup-v2-Grenzen. Das ist ein **Vorschlag**, hier weder installiert noch getestet.
Namespaces, Seccomp, Cgroup-Delegation und User-Manager muessen Doctor bestehen.
Bei fehlendem Backend nur Plan/Diagnose, niemals unisoliert fortfahren. Kein Docker-Fallback.
Fuer feindliche Multi-Tenant-Aufgaben separate VM/MicroVM vorziehen.
Windows/macOS zunaechst nur Plan/Status; native Backends muessen eigene Abnahmen erhalten.
Kein automatischer WSL-Start oder versteckter Remote-Worker.

Tasks nur als begrenztes JSON-Schema: IDs, Rollen, explizite Dateimenge, Modelldigest,
Budgets und erlaubte Test-IDs; kein `shell:true`, kein Modelltext in `bash -lc`.
Secrets und persoenliche Konfigurationen nicht mounten. Bereinigte Umgebung, Kontext-Allowlist,
Secret-Pruefung vor Modellzugriff und redigierte strukturierte Ereignisse statt kompletter Prompts.
MCP standardmaessig aus; Methoden, Roots und Argumente getrennt pro Rolle freigeben.
Projektdateien und Toolantworten sind untrusted und duerfen Freigaben nicht selbst erteilen.

Persistierte Zustaende: `planned`, `awaiting_approval`, `running`, `testing`, `reviewing`,
`awaiting_final_approval`, `failed`, `cancelled`, `completed`. Atomische private Speicherung;
Run-ID, Basiscommit, Patchhash, Rollen-/Konfigurationshash und Exitcodes protokollieren.
Approval bindet diese Hashes und verfaellt bei Aenderungen. Deployment/externe APIs brauchen
separate Freigaben und bleiben im Minimal-PoC deaktiviert.
Controller protokolliert Git-Identitaet und Diff; nur der Mensch committet/uebernimmt.

Cancel trifft nur die eigene verifizierte Prozessgruppe/Cgroup, nie beliebige PIDs.
Crash-Runs als unterbrochen markieren; Resume prueft Lease/Identitaet, Quell- und Artefakthashes
und erneuert Freigaben. Keine automatische Loeschung von Worktrees, Branches, Nutzdaten oder Logs.
Sauberen Input-Snapshot und dirty Worker-Output explizit trennen; nicht den vorhandenen Clean-Guard abschwaechen.

## Testnachweis dieser Runde

Windows, vorhandenes gebuendeltes Python, ausschliesslich temporaere Fixture-Projekte:

| Testmodul unter `tests/` | Tests | Ergebnis |
|---|---|---|
| `test_coding_workbench.py` | 45 | 43 bestanden, 2 POSIX-/AF_UNIX-bedingte Skips |
| `test_coding_workbench_registry.py` | 4 | bestanden |
| `test_openhands_worker.py` | 2 | bestanden |
| `test_native_coding_clis.py` | 44 | bestanden |
| `test_coding_agent_profiles.py` | 12 | bestanden |

Gesamt: **107 Tests, 105 bestanden, 2 Skips, keine Fehler**. Docker/Git/Provider-Aufrufe
der Ausfuehrungs-Fixtures sind gemockt oder auf Wegwerf-Projekte begrenzt.
Das ist kein Source-Build, kein Containerstart und kein echter Mehragenten-E2E-Test.

Single-Agent versus Multi-Agent wurde **nicht gemessen**. Erfolgsquote, Coverage, Fehlerquote,
Walltime, Input-/Outputtokens, CPU-Sekunden, Peak-RSS und GPU/VRAM bleiben fuer diesen Vergleich unbekannt.
Keine synthetischen Prozentwerte oder Tokenzahlen erfinden.

Spaeterer Benchmark: identisches isoliertes Toy-Projekt, feste Aufgaben/Tests, gleicher Modell-Digest,
gleicher Ausgangscommit, getrennte Worktrees, gleiches Gesamtbudget und wiederholte gepaarte Laeufe.
Kalt-/Warmstart getrennt erfassen. Feste Referenztests und adversarielle Faelle pruefen, nicht
nur vom Worker erzeugte Tests. Fehlende Provider-Usage als `unknown`, nicht als null werten.
CPU/GPU und Tokenmessung nur lokal, ohne Prompt-/Code-Export; Messaufwand gesondert angeben.

## Kleine Patch-Saetze und Abnahme

1. Navigation: aktuelle Bedienlinks direkt sichtbar machen; historische Anker erhalten.
2. Buildvertrag: Framework-Core und transitive Abhaengigkeiten pinnen/hashtesten; kein Auto-Upgrade.
3. Sandbox: native Linux-Grenze mit Negativtests vor jeglicher Agentenausfuehrung.
4. Workflow: sechs Rollen, begrenzter Dispatcher, Artefakt-Handoff, Approvals und Cancel/Resume.
5. Toy-Projekt: echter lokaler E2E und Single-/Multi-Agent-Vergleich erst nach expliziter Laufzeitfreigabe.

Jeder Satz separat reviewbar. Abnahme: keine Standardmutation, keine Host-Schreibmoeglichkeit,
kein unfreigegebenes Netzwerk, keine veraenderten Git-Kontrolldaten, keine Datenloeschung,
fail-closed bei fehlender Isolation, reproduzierbare Reports und belastbarer Cancel/Crash-Test.
Rollback: neue Integration deaktivieren, Reports/Worktrees erhalten; bisherige Installer und
Profile nicht umbiegen. Neue Profilnamen nur nach Registry-Pruefung, kein Umbenennen bestehender IDs.

Der [minimale Patch-Vorschlag](../proposals/MULTI_AGENT_MINIMAL_PATCH_2026-11-05.md)
ist noch nicht angewendet. Erst Navigation freigeben, dann Sandbox/Workflow separat abnehmen.
