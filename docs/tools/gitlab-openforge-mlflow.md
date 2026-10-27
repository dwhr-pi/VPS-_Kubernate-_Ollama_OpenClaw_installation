# GitLab, OpenForge, GENIE.AI und MLflow

Stand der Quellenpruefung: 27.10.2026.
Installationsstatus: **ungeprueft**. Nur Dokumentation und oeffentliche
Quellenpruefung; keine neue Installation, CI-Aktivierung oder Runtime-Abnahme.
Der Nutzerhinweis zu [GitLab-/Codeberg-Installationen](../TESTED_STATUS_MATRIX.md#quellenplattformen-installationsstatus)
bleibt unveraendert gueltig.

## Was ist OpenForge?

OpenForge ist hier **kein eindeutig identifiziertes gemeinsames KI-Produkt**.
Die verlinkten Quellen betreffen verschiedene Projekte und einen GitLab-Namespace.
Ein gleicher Name belegt weder gemeinsame Entwicklung noch Kompatibilitaet.

| Nutzerquelle | Tatsaechliche Einordnung | Bedeutung fuer dieses Setup |
| --- | --- | --- |
| [MasterworkTools/openforge-tutorials](https://github.com/MasterworkTools/openforge-tutorials) | Tutorials fuer modulare Tabletop-Gelaendesets, nicht fuer KI-Agenten | Fachliche Referenz fuer CAD/3D-Druck, kein LLMOps-Installer |
| [siriknikita/openforge](https://github.com/siriknikita/openforge) | Kollaborations-/Coding-Plattform im Entwicklungsstand | Recherchekandidat, keine fertige lokale Coding-/Agenten-Runtime |
| [openforge/gridly-scheduler](https://gitlab.com/openforge/gridly-scheduler) | Scheduler fuer OpenCode-Jobs aus GitLab Issues | Optionaler Agenten-/Queue-Kandidat, mit Container- und Sicherheitsgrenzen |
| [openforge/agent-runner](https://gitlab.com/openforge/agent-runner) | Repository mit bisher generischer README | Keine abgenommene Runner-Funktion daraus ableiten |
| [fordendk/genie-ai-replica](https://gitlab.com/fordendk/genie-ai-replica) | Nutzerquelle mit GENIE.AI-README und Verweisen auf UN/ITU-Upstream | Getrennt von den OpenForge-Projekten behandeln; Herkunftsgleichheit ungeprueft |

Die beiden GitLab-Repositories liegen im selben Namespace `openforge`.
Ein konkreter technischer Integrationsvertrag zwischen ihnen wurde hier nicht
belegt. Eine Verbindung zu den beiden gleichnamigen GitHub-Projekten ebenfalls nicht.

## Die Projekte im Detail

### OpenForge von MasterworkTools: Tabletop und 3D-Druck

Die [README](https://raw.githubusercontent.com/MasterworkTools/openforge-tutorials/master/README.md)
verweist auf Bauanleitungen, Sets und Bemalung. Die
[Set-Einfuehrung](https://raw.githubusercontent.com/MasterworkTools/openforge-tutorials/master/sets/README.md)
beschreibt Gelaendeteile, Verbindungen und Slicer-/Blender-Anpassungen.
Das passt fachlich zu CAD-/3D-Druck-Themen, nicht als Orchestrator fuer Ollama.
Das Repository verweist auf eigene Lizenzinformationen; Bedingungen fuer Modelle,
Tutorials und Weitergabe separat pruefen. Kein neuer Tools-Menueeintrag.

### OpenForge von siriknikita: Coding-Plattform, noch kein fertiger KI-Stack

Die [README](https://raw.githubusercontent.com/siriknikita/openforge/main/README.md)
beschreibt Next.js/React im Frontend sowie FastAPI/Python und MongoDB im Backend.
Sie fuehrt Echtzeit-Zusammenarbeit, Browser-IDE und KI-Integration noch als
kommende Funktionen. Die Lizenzrubrik enthaelt einen Platzhalter, keine hier
belegte vollstaendige Lizenzfreigabe.

Die [Backend-Dokumentation](https://raw.githubusercontent.com/siriknikita/openforge/main/backend/README.md)
beschreibt Clerk-/GitHub-Zugangsdaten fuer bestimmte Funktionen. Daraus folgt
keine belegte vollstaendig lokale oder Ollama-kompatible Installation.
Vor einem Versuch sind Lizenz, Funktionsumfang und externe Abhaengigkeiten zu
klaeren. Kein automatischer Login, PAT-Zugriff oder Datenbankstart.

### Gridly: GitLab Issues zu OpenCode-Jobs

Die [README](https://gitlab.com/openforge/gridly-scheduler/-/raw/main/README.md)
beschreibt Server, Worker, Dashboard und MCP. Issues und Labels steuern Jobs.
Das [Go-Modul](https://gitlab.com/openforge/gridly-scheduler/-/raw/main/go.mod)
deklariert Go 1.24.3; ein Build wurde hier nicht ausgefuehrt.
Der vorhandene [Lizenztext](https://gitlab.com/openforge/gridly-scheduler/-/raw/main/LICENSE)
ist AGPL Version 3, nicht die Apache-Projektlizenz dieses Setups.

Wichtige Grenzen laut README:

- OpenCode-Jobs setzen Podman oder Docker voraus; ein Go-Binary bedeutet hier
  keinen containerfreien Gesamtbetrieb.
- API-/MCP-Authentifizierung ist optional. Fuer einen Versuch muessen passende
  RO-/RW-Tokens bewusst eingerichtet und private Erreichbarkeit erzwungen werden.
- Worker-Join verwendet einen eigenen Token. Beispiel-Runner binden an
  `0.0.0.0`; das Beispiel nicht ungeprueft in ein oeffentliches Netz uebernehmen.
- Bind-Mounts koennen schreibbar sein. Keine produktiven Workspaces oder
  gemeinsamen Secrets an Agentenjobs durchreichen.
- Implementierung erfordert laut Workflow `gridly:ready` und `gridly:execute`.
  Operativer Zustand liegt derzeit teilweise nur im Speicher; Recovery pruefen.

Einordnung: optionaler Evaluationskandidat, kein Ersatz fuer die vorhandene
Queue und kein Standarddienst. GitLab Issues/MCP-Kommentare koennen externe
Datenhaltung bedeuten. Installation, Sandboxwirkung und Wiederanlauf ungeprueft.

### Agent Runner: vorhandenes Repository, Funktion nicht nachgewiesen

Die [gelesene README](https://gitlab.com/openforge/agent-runner/-/raw/main/README.md)
enthaelt GitLabs allgemeine Einstiegsvorlage. Sie belegt keinen produktiven
Agenten-Runner, kein MLflow-Modul und keine einsatzbereite Gridly-Anbindung.
Der restliche Quellumfang und die Lizenz wurden hier nicht vollstaendig auditiert.
Insbesondere sind die dortigen Push-/Setup-Beispiele keine Anweisungen fuer dieses
Repository; es wurde nichts davon ausgefuehrt.

### GENIE.AI-Replica: RAG-Framework getrennt bewerten

Die [Replica-README](https://gitlab.com/fordendk/genie-ai-replica/-/raw/main/README.md)
beschreibt ein GENIE.AI-RAG-Framework fuer oeffentliche Einrichtungen und verlinkt
den [UN/ITU-Upstream](https://opensource.unicc.org/un/itu/genie-ai).
Sie nennt OPEA, lokale Modellkomponenten, OIDC und Observability. Der Quickstart
verwendet Docker Compose und optionale GPU-Profile.
Die Replica enthaelt einen [Apache-2.0-Lizenztext](https://gitlab.com/fordendk/genie-ai-replica/-/raw/main/LICENSE).

Nicht belegt sind Commit-Gleichheit, Aktualitaet gegenueber Upstream, ein nativer
Docker-freier Gesamtbuild oder eine Integration in unseren Qdrant-/Ollama-Stack.
Selbstaussagen zu Souveraenitaet/Standards sind keine unabhaengige Compliance-
oder Sicherheitsabnahme. Vor Nutzung Herkunft, Datenpfade, Ressourcen und Lizenz-
umfang des konkreten Standes pruefen. Nur Recherchekandidat, kein Defaultprofil.

## MLflow: Experimente, Modelle und LLM-Auswertung

[MLflow](https://github.com/mlflow/mlflow) ist ein eigenstaendiges Projekt,
nicht Bestandteil der verlinkten OpenForge-Repositories. Die
[offizielle Dokumentation](https://mlflow.org/docs/latest/index.html) behandelt
Experiment-Tracking, Modellverwaltung sowie Tracing und Evaluation fuer LLMs
und Agenten. Fuer dieses Setup waeren protokollierte Modell-/Promptvergleiche
und nachvollziehbare Evaluationslaeufe sinnvoll. Das ersetzt keine Inferenz-
Runtime und keine vorhandene Queue.

### Bereits vorhandener Setup-Pfad

`MLflow` steht bereits in der Tools-Liste sowie in Forschungs-/LLM-Builder-
Zuordnungen von `setup_ultimate.sh`. Vorhanden sind
[Installer](../../scripts/tools/mlflow_install.sh) und
[Uninstaller](../../scripts/tools/mlflow_uninstall.sh). Der Installer nutzt den
[Python-Pakethelper](../../scripts/tools/helpers/python_tool_common.sh) mit dem
Paketnamen `mlflow`, keinen hier abgenommenen gepinnten GitHub-Source-Build.
Diese Dokumentation erzeugt keinen zweiten Installer und hebt den Teststatus
nicht an. Paketinstallation, Serverbetrieb und Datenhaltung sind getrennte Schritte.

### MLflow und GitLab sind nicht dasselbe

GitLab stellt fuer Model Experiments/Model Registry eine
[MLflow-Client-Kompatibilitaet](https://docs.gitlab.com/user/project/ml/experiment_tracking/mlflow_client/)
mit dokumentierten Einschraenkungen bereit, nicht automatisch einen vollstaendigen
MLflow-Server. Ein GitLab-Tracking-Endpunkt kann Metadaten/Artefakte auf GitLab
speichern; ein eigener MLflow-Server ist eine andere Betriebsentscheidung.
Ollama-Modellcache, GGUF-Dateien und Evaluationsmetadaten nicht gleichsetzen.

Prompts, Antworten, Dokumentauszuege und Traces koennen vertrauliche Daten
enthalten. Ziel, Zugriffsrechte, Aufbewahrung und erlaubte Inhalte vor Logging
festlegen. Kein automatisches Hochladen oder Einsammeln bestehender Daten.

## Empfohlener Einstieg: optionales GitLab-CI und manueller Ollama-Review

Der gewuenschte Einstieg ist eine **optionale GitLab-CI-Anbindung fuer Offline-
Pruefungen und ein ausdruecklich gestarteter Ollama-Review**.
Keine automatischen Produktivdeployments, Modell-Downloads oder zusaetzlichen
Containerdienste als Standard. Diese Seite aktiviert keine `.gitlab-ci.yml`.

```text
Ausgewaehlter Repository-Stand / Merge Request
                 |
                 v
Isolierte CI: Syntax, Registry und Offline-Fixtures
                 |
                 v
Bewusste Freigabe eines begrenzten Diffs fuer lokalen Ollama-Review
                 |
                 v
Review-Entwurf -> menschliche Pruefung
```

### Stufe 1: Offline-Pruefungen ohne Runtime-Zugang

Ein spaeterer CI-Job kann die bereits vorhandenen Checks ausfuehren:

```bash
bash -n install.sh
bash -n setup_ultimate.sh
bash scripts/validate_config.sh
bash scripts/check_tools.sh
bash scripts/check_profiles.sh
bash scripts/check_ports.sh
```

`bash -n` parst nur; es startet den Installer nicht. Weitere gezielt ausgewaehlte
Tests muessen ohne externe Dienste, Modelle oder Credentials auskommen.
Abhaengigkeiten werden auf dem isolierten Runner vorab bewusst bereitgestellt;
kein `apt`, `pip`, Modell-Pull oder Containerstart als stiller Job-Vorlauf.

Auch CI-Skripte sind ausfuehrbarer Repository-Code. Unvertrauenswuerdige Fork-/MR-
Pipelines duerfen keinen Produktionsrunner, Host-Shell-Zugriff auf Heimserver,
Kubeconfig oder produktive Secrets erhalten. Geschuetzte Runner, minimale
GitLab-Tokenrechte und Isolation vor Aktivierung pruefen.
[GitLab: Runner-Sicherheit](https://docs.gitlab.com/runner/security/).

### Stufe 2: bewusst gestarteter Ollama-Review

1. Nur aus einem vertrauenswuerdigen, geschuetzten Job heraus manuell freigeben.
   Ein MR darf sich diesen Netzwerkzugang nicht selbst per Pipelinecode erteilen.
2. Diff-Dateien und Groesse begrenzen; keine `.env`, Keys, Tokens, privaten Daten
   oder unnoetigen Artefakte einbeziehen. Diff-Inhalte als unvertrauenswuerdige
   Daten behandeln, nicht als Agentenanweisungen ausfuehren.
3. Einen ausdruecklich freigegebenen privaten Ollama-Endpunkt und ein bereits
   installiertes Modell verwenden. Kein `ollama pull`, kein neuer Modellserver.
4. Zeitlimit, Ausgabetokens und Parallelitaet begrenzen; keine automatischen
   Cloud-Fallbacks. Der Review bekommt keine Shell-/Datei-/MCP-Werkzeuge.
5. Nur einen Entwurf erzeugen. Kein automatisches Anwenden, Pushen, Mergen,
   Kommentieren oder Deployen; Weitergabe nach menschlicher Pruefung freigeben.

Lokale Inferenz bedeutet nicht automatisch lokale Datenhaltung: ein nach GitLab
hochgeladener Kommentar, CI-Log oder Artefakt liegt anschliessend dort.
Ein isolierter Check-Runner und ein freigegebener Review-Pfad sind unterschiedliche
Vertrauenszonen. Diese Schutzwirkung ist hier konzipiert, nicht live getestet.

## Status und naechste Abnahme

| Bereich | Aktueller Nachweis | Vor einer Freigabe erforderlich |
| --- | --- | --- |
| Alle fuenf Nutzerquellen | Oeffentliche Projektseiten/READMEs gelesen, Grenzen oben dokumentiert | Konkreten Commit, Herkunft, vollstaendige Lizenz- und Buildpruefung |
| GitLab-/Codeberg-Installation | ungeprueft | Protokollierter Installationstest auf konkreter Zielplattform |
| MLflow im Setup | Bestehenden Pakethelper-/Menuepfad statisch geprueft | Pin-/Quellenvertrag, isolierte Installation, Auth, Storage und Restore |
| GitLab-CI-Anbindung | Nur dokumentiert, nicht aktiviert | Isolierter Runner, Least Privilege, Offline-Smoke und Ergebnisnachweis |
| Ollama-Review | Nur dokumentierter manueller Ablauf | Begrenzter freigegebener Test ohne Geheimnisse und ohne Seiteneffekte |

Keine Herkunft allein ist eine Installationserlaubnis. GitLab-Quellen ersetzen
nicht stillschweigend die vorhandene GitHub-Quellenpolitik. Es werden keine
neuen Registrystatuswerte, Dienste oder Tools als installiert eingetragen.

Weiterlesen: [Tool-Katalog](../TOOLS_CATALOG.md),
[GitLab-/Codeberg-Teststatus](../TESTED_STATUS_MATRIX.md),
[aktueller Audit](../AUDIT_2026_10.md).
