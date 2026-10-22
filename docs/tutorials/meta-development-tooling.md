# Meta-AI-Interview: Entwicklungswerkzeuge und lokale Projektvorbereitung

Weitere Interview-Auswertung: [Grok: Werkzeugquellen und Faehigkeitsnachweise](grok-development-tooling.md).

Stand: **22.10.2026**. Quelle der Anregung ist der vom Nutzer bereitgestellte
Interviewtext. Dieser Bereich ist bewusst von den [Manus-](manus-interview-2026-10-22.md)
und [Gemini-Ergaenzungen](gemini-development-tooling.md) getrennt.

## Sinn und Zweck

Nuetzlich ist der beschriebene Ablauf: Projektumfang bestimmen, Dateien
strukturiert erzeugen, passende Pruefungen ausfuehren und ein nachvollziehbares
Ergebnis liefern. Unser Setup kann dafuer vorhandene Werkzeuge, CI-Beispiele
und Repository-Skills verwenden. Es erhaelt dadurch keine Meta-interne Sandbox
oder Chat-Vorschau und braucht fuer diese Anleitung kein Meta-Konto.

**Interviewaussagen sind keine verifizierte Meta-Toolliste.** Eine Antwort eines
Chatbots beweist weder Python-Version noch installierte Pakete, Browserzugriff,
Dateizugriff oder tatsaechlich ausgefuehrte Tests. Die Saetze "alles fertig",
"lauffaehig" und "production-ready" ersetzen keine bereitgestellten Artefakte
mit Build-/Testnachweisen.

## Genannte Artefakte und tatsaechlicher Stand

| Im Interview behauptet | Was hier nachweisbar vorliegt |
|---|---|
| skill-fullstack-bootstrapper.md unter .muse/skills/ | Kein Original angehaengt. Eigener [Repository-Skill fullstack-project-bootstrapper](../../skills/fullstack-project-bootstrapper/SKILL.md), nicht global installiert |
| go-ci.yaml und rust-ci.yaml mit Buildx, Scans und Cache | Diese Originaldateien fehlen. Unsere [vorhandenen Go-/Rust-Vorlagen](../../examples/manus-ci-cd/README.md) bleiben separate inaktive Beispiele |
| Dockerfile.go, Dockerfile.rust und k8s-deployment.yaml | Keine Meta-Dateien mitgeliefert. Vorhandenes Go-Dockerfile und Kubernetes-Muster verlinkt; kein angeblich fertiges Rust-Dockerfile erfunden |
| Tech-Stack Deck mit 12 Slides | Keine Datei und kein verwendbarer Downloadlink mitgeliefert. Die vorhandene [13-Folien-Praesentation](../presentations/technology-tooling-overview.pptx) bleibt unveraendert und wird nicht Meta zugeschrieben |
| Python 3.9 Sandbox und installierte Bibliotheken | Fremde Laufzeitbehauptung, hier nicht getestet. Die nachfolgende Liste ist eine Quellenzuordnung, kein Inventar unseres Hosts |

Die neue Skill-Fassung ist eine eigene Rekonstruktion des beschriebenen
Projektvorbereitungsprozesses. `.muse/skills/` wird nicht ohne Nachweis als
passender Skill-Pfad dieses Setups uebernommen. Installation in einem Agentenclient
und Aktivierung aktiver Workflows sind gesonderte Entscheidungen.

## Python: Quellen statt angenommener Vorinstallation

Python 3.9 wird laut [offiziellem Versionsstatus](https://devguide.python.org/versions/)
seit Oktober 2025 nicht mehr unterstuetzt. Fuer neue Projekte eine noch
unterstuetzte, mit den Bibliotheken kompatible Version waehlen. Kein Downgrade
des System-Python, um eine unbestaetigte Meta-Sandbox nachzubauen.

| Bereich | Genannte Pakete und Originalquellen | Einordnung |
|---|---|---|
| Daten und Statistik | [pandas](https://github.com/pandas-dev/pandas), [NumPy](https://github.com/numpy/numpy), [SciPy](https://github.com/scipy/scipy), [statsmodels](https://github.com/statsmodels/statsmodels), [scikit-learn](https://github.com/scikit-learn/scikit-learn) | Projektabhaengigkeiten; Versionen/Lockfile und synthetische Testdaten festlegen |
| Tabellen und Office | [openpyxl](https://foss.heptapod.net/openpyxl/openpyxl), [python-docx](https://github.com/python-openxml/python-docx), [python-pptx](https://github.com/scanny/python-pptx) | Nicht alle fuehrenden Quellen liegen auf GitHub. Datei erzeugen und inhaltlich/visuell pruefen sind verschiedene Schritte |
| PDF | [PyMuPDF](https://github.com/pymupdf/PyMuPDF), [pypdf](https://github.com/py-pdf/pypdf), [ReportLab](https://hg.reportlab.com/hg-public/reportlab) | PyPDF2 aus dem Interview nicht als heutige Standardempfehlung festschreiben; aktuelle Wartung/Lizenz pruefen. PyMuPDF-Lizenz gesondert beachten |
| Visualisierung | [Matplotlib](https://github.com/matplotlib/matplotlib), [Plotly](https://github.com/plotly/plotly.py), [Altair](https://github.com/vega/altair) | Diagramm-/HTML-Ausgabe braucht Daten-, Darstellungs- und gegebenenfalls Browserpruefung |
| Bilder und Geo | [Pillow](https://github.com/python-pillow/Pillow), [OpenCV](https://github.com/opencv/opencv), [GeoPandas](https://github.com/geopandas/geopandas) | Native Bibliotheken und Plattformkompatibilitaet pruefen, keine automatische GPU-Zusage |
| Weitere Pakete | [qrcode](https://github.com/lincolnloop/python-qrcode), [cryptography](https://github.com/pyca/cryptography), [PyTorch](https://github.com/pytorch/pytorch) | Nur bei Projektbedarf; Build-/Modellabhaengigkeiten und Platzbedarf gesondert bewerten |

Das sind **keine neuen Installed-Marker und keine Masseninstaller**. Vorhandene
Eintraege und der [62er-Installationsweg](../tools/development-toolchain-check.md)
bleiben massgeblich fuer tatsaechlich integrierte Programme. GitHub bevorzugen,
aber einen inoffiziellen Mirror nicht als Originalquelle ausgeben.

## Sprachen, Vorschau und Tests richtig trennen

| Bereich | Geeigneter lokaler Nachweis | Was eine Chat-Antwort nicht beweist |
|---|---|---|
| Python | Freigegebene venv, pytest/unittest, echte Exit-Codes und optional Coverage | Eine Paketliste ist kein Nachweis vorhandener Module oder bestandener Tests |
| JS/TS/React | Projekt-Build, Typ-/Lintpruefung und Browser-/E2E-Test | Ein sichtbarer Preview oder Screenshot beweist keine Backend-/Produktionsfunktion |
| Go | gofmt, vet, Race-Tests und Build mit passender Toolchain | "ready-to-build" ist ohne Compilerlauf keine Buildbestaetigung |
| C/C++ | CMake/CTest, gewaehlter Compiler und passende Sanitizer | Eine Textpruefung erkennt nicht alle ABI-/Memory-/UB-Probleme |
| Rust | Exakte Toolchain, fmt, Clippy und gelockte Tests/Builds | Cargo.lock alleine garantiert keine byteidentischen Binaries |
| Bash/PowerShell | Native Syntaxpruefung, ShellCheck/PSScriptAnalyzer und gemockte Bats-/Pester-Tests | Eine Python-Simulation ist kein Test des Shell-Parsers oder realer Cmdlet-Semantik |
| SQL | Wegwerf-Datenbank im gewaehlten Dialekt mit synthetischen Daten | SQLite ersetzt keine PostgreSQL-/MySQL-/MSSQL-/BigQuery-Integration |
| Docker/Kubernetes/Terraform | Bewusst freigegebene Build-/Schema-/Policy-/Integrationstests | Gueltiges YAML/HCL und ein Scan bedeuten nicht automatisch Produktionsreife |

Fuer sichere Loopback-Vorschau, Browserchecks, Git-Diffs und begrenzte
Korrekturrunden den [vorhandenen Entwicklungsablauf](manus-development-workflow.md)
verwenden. Pfade wie `/mnt/data` sind fremder Sandbox-Kontext, keine Zusage ueber
unsere Ordner. Keine WSL-Distro starten und keine fremden Prozesse/Ports veraendern.

## CI/CD und Deployment: Korrekturen der Interview-Kurzfassung

- Die bestehenden [Go-/Rust-Vorlagen](../../examples/manus-ci-cd/README.md)
  aktivieren hier keine `.github/workflows`-Datei. Go verwendet `cache: false`;
  Rust enthaelt weder nextest noch einen Image-Push. Die im Interview genannte
  Zusatzpipeline wird nicht als bereits umgesetzt ausgegeben.
- [cargo-nextest](https://github.com/nextest-rs/nextest) ist ein separater Rust-Test-Runner,
  keine automatische Garantie fuer groessere Testabdeckung und kein Ersatz fuer
  jede Testart. Hier neue Quellenreferenz, noch kein neu integrierter Installer.
- [Trivy](https://github.com/aquasecurity/trivy) ist bereits registriert. Ein Scan
  braucht eine passende Scanner-/Datenbankversion und kann Netzwerkzugriff oder
  sensible Befunde erzeugen. Ohne bestandenen Scan keinen Scanerfolg melden.
- GHCR-Push ist eine Veroeffentlichung. Nur `main` als Trigger ersetzt weder
  Review noch geschuetztes Environment und minimale Jobrechte. CI-Testjobs
  bekommen keine Release-/Cluster-Secrets. Cache-Schreibrechte separat begrenzen.
- `readOnlyRootFilesystem` gehoert zur Kubernetes-SecurityContext-Konfiguration,
  nicht zu den Dockerfile-Anweisungen. Ein read-only Containerdateisystem ist
  eine Laufzeitoption. [Kubernetes-SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/).
- Dockerfile-`HEALTHCHECK` braucht ein im Image vorhandenes Pruefprogramm.
  Minimale/distroless Images haben oft keine Shell/curl. Kubernetes-Probes
  separat konfigurieren; [Dockerfile-Referenz](https://docs.docker.com/reference/dockerfile/#healthcheck).
- Eine dynamisch gelinkte Rust-gnu-Binary nicht ungeprueft in ein statisches
  Go-Laufzeitimage kopieren. libc, CA-Zertifikate, Zielarchitektur und Starttest
  gehoeren zum Nachweis. Ingress bedeutet eine eigene, bewusst freizugebende Exposition.
- Drei Replikate und `maxUnavailable: 0` sind keine universelle Verfuegbarkeitsgarantie:
  Surge-Kapazitaet, Quoten, Probes, Datenbank und Speicher messen. Fuer MiniPCs
  kann diese Voreinstellung zu teuer sein.
- Terraform-Remote-State benoetigt sichere Zugriffe, Verschluesselung und
  backendabhaengige Sperren. Beim aktuellen S3-Backend `use_lockfile` pruefen;
  DynamoDB-Locking ist dort als veraltet markiert. Provider-/Modulversionen,
  Lockfile und Zugriffsrechte getrennt betrachten:
  [offizielle S3-Backend-Dokumentation](https://developer.hashicorp.com/terraform/language/backend/s3).
  Plan/Test koennen Provider/Cloud kontaktieren, Outputs und State Geheimnisse enthalten.

## KI-Stack und die genannten GitHub-Quellen

Eine kleine Ausgangskombination bleibt sinnvoll: eine lokale Runtime plus ein
Coding-Frontend; einen Retrieval-Store und eine Workflow-Engine erst bei Bedarf.
Die [vorhandene Auswahlhilfe](manus-interview-2026-10-22.md) erfasst Hardware,
Datenfluss, Budget und Bedienniveau. Lokaler Betrieb kostet weiterhin Energie,
Hardware und Wartung und ist nur nach bewusster Konfiguration offline.

| Originalquelle aus dem Interview | Projektrolle / Grenze |
|---|---|
| [Ollama](https://github.com/ollama/ollama) | Lokale Inferenz; Modell-/GPU-/VRAM-Kompatibilitaet und Downloads separat pruefen |
| [Open WebUI](https://github.com/open-webui/open-webui) | Oberflaeche; Lizenz einschliesslich Brandingbedingungen am gewaehlten Stand pruefen, nicht pauschal als MIT darstellen |
| [Qdrant](https://github.com/qdrant/qdrant) | Retrieval-Store, kein automatisches Gedaechtnis und keine Rechteverwaltung fuer beliebige Agenten |
| [LangChain Python](https://github.com/langchain-ai/langchain), [LangChain.js](https://github.com/langchain-ai/langchainjs) | Separate Python-/JS-Projekte; das Python-Repo ist nicht zugleich der JS-Quellcode |
| [LangChainGo](https://github.com/tmc/langchaingo) | Eigenstaendiges Go-Projekt; keine zugesicherte API-/Feature-Paritaet zur Python-Bibliothek |
| [n8n](https://github.com/n8n-io/n8n) | Fair-Code; Edition, Nutzung und Lizenz pruefen, kein Docker-Stack automatisch starten |
| [Flowise](https://github.com/FlowiseAI/Flowise) | Visuelle Workflows; nicht zwingend zusaetzlich zu jeder anderen Orchestrierung erforderlich |

**Nicht uebernommen:** Unbelegte Ranglisten, Prozentwerte und allgemeine
Preisvergleiche zwischen Coding-Assistenten. Gleiches gilt fuer die Behauptung,
LangChain sei fuer jede fortgeschrittene KI Pflicht. Erst eigene Aufgaben,
Testdaten, Laufzeiten, Kosten und Rechte vergleichen. Konkrete API-Generationen
nicht ungeprueft aus dem Interview festlegen; aktuellen Provider-Lebenszyklus pruefen.

Cursor, Copilot, Perplexity, NotebookLM, Granola, ElevenLabs, Midjourney, Kling,
Zapier, Make, Cowork, Lindy, Clay, Softr, Notion AI, v0 und Pinecone sind nicht
alle lokale Open-Source-Programme. Cloud-Dienste, SDKs, Clients, Modelle und
selbsthostbare Server unterscheiden. Ein GitHub-Client macht einen Dienst nicht
lokal oder kostenlos. Keine Konten, Keys, Uploads oder Abos werden eingerichtet.

## Starter-Kits: nur Architekturreferenzen, nicht installieren

Die vier GitHub-Ziele wurden am 22.10.2026 als verfuegbar geprueft, nicht gebaut
oder gestartet. Ihre READMEs beschreiben unterschiedliche Zusammenstellungen:

| Quelle | Befund aus dem jeweiligen README | Bedeutung fuer uns |
|---|---|---|
| [n8n Self-Hosted AI Starter Kit](https://github.com/n8n-io/self-hosted-ai-starter-kit) | Compose-Vorlage mit n8n, Ollama, Qdrant und PostgreSQL | Keine identische Komplettliste mit jedem der anderen Kits; Primaerreferenz von n8n |
| [Cole: local-ai-packaged](https://github.com/coleam00/local-ai-packaged) | Compose-basierte Erweiterung unter anderem mit Supabase, Open WebUI, Flowise, Neo4j, Langfuse und weiteren Diensten | Grosser Stack mit eigenen Umgebungsvariablen, Secrets und Ressourcenanforderungen |
| [FreeAIHub ai-lab](https://github.com/freeaihub/ai-lab) | Mehrere Compose-Konfigurationen und Lerntexte; README benennt fehlenden Code fuer Lernprojekte | Nicht als gleichwertig fertige Produktplattform ausgeben |
| [FranzDiebold gen-ai-template](https://github.com/FranzDiebold/gen-ai-template) | Docker Model Runner, LangChain/LangGraph, marimo, UIs und weitere Dienste | Andere Komponenten/Ports; nicht einfach Ollama-Starter mit gleichem Aufbau |

**GitHub als Quelle bedeutet nicht Docker-freie Installation:** Ein Compose-Repo
bleibt ein Container-Stack. Deshalb werden diese Kits hier nicht als neue
Tools/Installer hinzugefuegt und keine `compose up`-Befehle ausgefuehrt.
Die im Interview genannten Ports sind keine allgemeingueltige Zuordnung.
Portbelegung, Bind-Adresse, Authentisierung, Telemetrie, Update-/Backupstrategie
und Lizenzen jeder eingebundenen Komponente muessen einzeln geprueft werden.
Auch ein lokal installierter Stack kann Cloud-Provider kontaktieren.

## Wiederverwendung

```text
Nutze skills/fullstack-project-bootstrapper/SKILL.md fuer das freigegebene Zielprojekt.
Waehle Go oder Rust und API, Worker oder CLI anhand meines Auftrags.
Pruefe vorhandene Dateien, Toolchains und Tests. Erstelle nur fehlende Projektteile.
Verwende fuer CI/Deployment zunaechst die vorhandenen inaktiven Vorlagen.
Dokumentiere echte Exit-Codes und nicht getestete Annahmen.
Keine WSL-Aktion, Paket-/Dockerinstallation, aktive CI, Cloud, Commit/Push oder Rollout.
```

Das Interview ist damit dokumentiert; es wurde keine Meta-Runtime lokal
nachgebaut. Fremde Dateien und ein 12-Folien-Deck muessen fuer eine genaue
Artefaktpruefung zuerst bereitgestellt werden.

## Lokaler Pruefumfang

Fuenf neue Meta-bezogene und 28 vorhandene Manus-bezogene Offline-Tests bestanden.
Geprueft sind Quellenzuordnung, lokale Referenzen, Skill-Metadaten, Markdown-
Struktur und die unveraenderte Zuordnung vorhandener CI-/Folienartefakte.
Der Standard-Skillvalidator konnte mangels PyYAML nicht starten; kein Paket
wurde dafuer nachinstalliert. Kein Live-Meta-, Modell-, Container- oder Cluster-Test.
