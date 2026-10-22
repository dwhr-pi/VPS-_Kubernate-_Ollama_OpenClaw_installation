# Perplexity-Interview: Quellenpruefung, Toolauswahl und Entwicklungsablauf

Weiterer Interview-Abgleich: [Qwen AI](qwen-development-tooling.md).

Stand: **22.10.2026**. Grundlage ist das vom Nutzer bereitgestellte Interview
mit Perplexity AI, im Anhang als "Perplextity AI" bezeichnet. Eigener Bereich,
getrennt von [Manus](manus-interview-2026-10-22.md), [Gemini](gemini-development-tooling.md),
[Meta](meta-development-tooling.md) und [Grok](grok-development-tooling.md).

## Sinn und Zweck

Nuetzlich ist der Ablauf aus Recherche, begruendeter Werkzeugauswahl,
Projektvorbereitung und nachvollziehbaren Tests. Fuer unser Setup verbindet
diese Anleitung Originalquellen mit vorhandenen Installationswegen und
Qualitaetspruefungen. Sie installiert weder Perplexity noch dessen interne
Werkzeuge und braucht kein Perplexity-Konto.

**Eine zitierte URL beweist nicht automatisch die danebenstehende Aussage.**
Interviewaussagen ueber Jupyter, Konnektoren, Android-Zugriff und eigene
Testausfuehrung sind keine verifizierte interne Toolliste und kein Nachweis
der Faehigkeiten unseres Hosts. Verfuegbarkeit, Konten, Produktversion und
erteilte Rechte muessen getrennt geprueft werden.

## Behauptete Ergebnisse und tatsaechliche Artefakte

| Aussage im Interview | Nachweisbarer Stand |
|---|---|
| Python/Jupyter, Websuche und Konnektoren werden intern genutzt | Fremde Laufzeitbehauptung; hier keine Perplexity-Sitzung oder Konnektoren getestet |
| Prozess mit /skill-creator als Skill erstellen | Links zu Anthropic-Skill-Creators vorhanden, aber kein eigener fertiger SKILL.md-Text oder validiertes Paket mitgeliefert |
| Konkrete Go-/Rust-YAML-Workflows koennen direkt uebernommen werden | Im Anhang stehen Befehle und Action-Quellen, aber keine vollstaendigen Go-/Rust-Workflow-Dateien |
| output/technology-tooling-overview.pptx mit zwoelf Folien erstellt | Keine PPTX angehaengt, kein verwendbarer Downloadlink; die Aufzaehlung nennt nur elf Folien |
| Lokale Modelle garantieren Datenschutz/Offline-Nutzung | Abhaengig von Konfiguration, Telemetrie, Tools und Cloud-Fallbacks, kein pauschaler Nachweis |

Die vorhandene [13-Folien-Praesentation](../presentations/technology-tooling-overview.pptx)
bleibt unveraendert und ist kein Perplexity-Original. Der fremde output-Pfad
bezeichnet keine auf unserem Rechner nachgewiesene Datei.

## Quellen richtig bewerten

Das Interview vermischt offizielle Projekte mit Marketingseiten, Blog-Rankings
und fachfremd wirkenden Verweisen. Beispielsweise werden pytest-cov und
pre-commit mit einer URL namens working-together-to-make-investments belegt.
Daraus uebernehmen wir keinen technischen Nachweis. Ebenso belegt ein
Python-/Windows-ARM-Beitrag nicht automatisch konkrete mypy-/Pyright-Eigenschaften.

Der Inhalt dieser Sekundaerseiten wurde hier nicht vollstaendig nachgeprueft;
sie werden weder pauschal als falsch noch als verlaessliche Tool-Dokumentation
eingestuft. Fuer technische Aussagen dienen die jeweiligen Primaerquellen.
Preis-/Beliebtheitsranglisten und Hardware-Faustformeln sind keine Messung
und wurden nicht als allgemeingueltige Empfehlung uebernommen.

Bei einer Quellenpruefung festhalten: Behauptung, Original-URL, Datum,
unterstuetzender Abschnitt, Beleggrenze und Status. Eine Antwort mit vielen
Zitaten ist nicht automatisch eine vollstaendige oder aktuelle Auswertung.

## Python und Web: korrigierter Einstieg

| Werkzeug / Rolle | Primaerquelle | Einordnung |
|---|---|---|
| uv und Ruff | [uv](https://github.com/astral-sh/uv), [Ruff](https://github.com/astral-sh/ruff) | Projekt-/Paketwerkzeuge; kein Auftrag zum Ersetzen des System-Python |
| Typpruefung | [mypy](https://github.com/python/mypy), [Pyright](https://github.com/microsoft/pyright) | Alternativen passend zum Projekt; keine pauschale Pflicht fuer beide |
| Editor / Sprachdienst | [VS Code-Quellprojekt](https://github.com/microsoft/vscode), [Pylance-Dokumentation und Issues](https://github.com/microsoft/pylance-release) | Pylance-Repo nicht mit vollstaendigem Sprachserver-Quellcode verwechseln |
| Tests und Coverage | [pytest](https://github.com/pytest-dev/pytest), [pytest-cov](https://github.com/pytest-dev/pytest-cov), [Coverage.py](https://github.com/nedbat/coveragepy) | Coverage misst Ausfuehrungsabdeckung, nicht funktionale Vollstaendigkeit |
| Hooks | [pre-commit](https://github.com/pre-commit/pre-commit) | Hooks erst konfigurieren und bewusst aktivieren; installiert nicht automatisch jede gewuenschte Pruefung |
| API / Server | [FastAPI](https://github.com/fastapi/fastapi), [Pydantic](https://github.com/pydantic/pydantic), [Uvicorn](https://github.com/encode/uvicorn) | Laufzeitabhaengigkeiten; Serverstart separat freigeben |
| Web-Alternativen | [Django](https://github.com/django/django), [Flask](https://github.com/pallets/flask), [HTMX](https://github.com/bigskysoftware/htmx) | Nach Anwendung waehlen, nicht alle Frameworks installieren |
| Datenzugriff | [SQLAlchemy](https://github.com/sqlalchemy/sqlalchemy), [SQLModel](https://github.com/fastapi/sqlmodel) | Migrationen und Datenzugriff gesondert testen |
| TestClient / HTTP | [FastAPI-Testanleitung](https://fastapi.tiangolo.com/tutorial/testing/), [HTTPX](https://github.com/encode/httpx) | HTTPX als Testabhaengigkeit beachten; App und /health-Endpunkt muessen existieren |
| Testcontainers | [Python](https://github.com/testcontainers/testcontainers-python), [Go](https://github.com/testcontainers/testcontainers-go) | Im Interview ist nur das Go-Repo verlinkt; kein Ersatz fuer die Python-Bibliothek, beide brauchen eine passende Container-Laufzeit |

Das Beispiel mit uv add fastapi uvicorn pytest ruff mypy vermischt Runtime-
und Entwicklungsabhaengigkeiten. Fuer ein bewusst freigegebenes Zielprojekt
FastAPI/Uvicorn von pytest, pytest-cov, HTTPX, Ruff und mypy trennen, etwa mit
der dev-Gruppe. Quellen: [uv-Abhaengigkeiten](https://docs.astral.sh/uv/concepts/projects/dependencies/).
Ein nacktes uv add installiert ueblicherweise aus einem Paketindex, nicht
automatisch aus GitHub; Git-Quellen und Commit muessen explizit festgelegt werden.
Auch uv run kann Abhaengigkeiten synchronisieren und Downloads ausloesen.

Die Befehle aus dem Interview wurden hier nicht ausgefuehrt. uv init erzeugt
noch keine app/main.py oder health-Route. Das Beispiel mit TestClient kann
deshalb ohne passende Anwendung nicht erfolgreich laufen; pytest-cov fehlt
im gezeigten Paket-Startbefehl fuer den spaeteren --cov-Aufruf.

Fuer Vorschauen nur freigegebene Loopback-Adressen nutzen, etwa 127.0.0.1.
Reload, OpenAPI-Doku und ein sichtbares Frontend sind keine Produktions-
oder E2E-Pruefung. Reale Benutzerablaeufe, Authentisierung, Fehlerfaelle und
Datenbankverhalten brauchen eigene Tests. Ausfuehrliche Ablaufe:
[Entwicklungsworkflow](manus-development-workflow.md).

## Konsolidierte weitere GitHub-Quellen

Doppelte Listen im Interview sind hier zusammengefuehrt. Dies sind
**Quellenreferenzen, keine neuen Installer oder Installed-Marker**. Nicht
jeder Build und jede Lizenz dieser Liste wurden neu geprueft. Vorhandene
Rezepte und Voraussetzungen siehe [62er-Uebersicht](../DEVELOPMENT_TOOLS_OVERVIEW.md)
und [Installations-/Lifecycle-Einstieg](../tools/development-toolchain-check.md).

| Bereich | Quellen | Grenze |
|---|---|---|
| JS/TS und Frontend | [pnpm](https://github.com/pnpm/pnpm), [Vite](https://github.com/vitejs/vite), [Biome](https://github.com/biomejs/biome), [setup-biome](https://github.com/biomejs/setup-biome), [ESLint](https://github.com/eslint/eslint), [Prettier](https://github.com/prettier/prettier), [Vitest](https://github.com/vitest-dev/vitest), [Playwright](https://github.com/microsoft/playwright) | Biome ersetzt nicht jedes Plugin oder jeden Typcheck; Browserdownloads und Frontend-Builds kosten Speicher |
| Go | [Go](https://github.com/golang/go), [golangci-lint](https://github.com/golangci/golangci-lint), [Staticcheck](https://github.com/dominikh/go-tools), [Cobra](https://github.com/spf13/cobra) | go.sum ist keine Garantie fuer bytegleiche Binaries; Toolchain und Buildumgebung festlegen |
| Rust | [Rust](https://github.com/rust-lang/rust), [rustup](https://github.com/rust-lang/rustup), [Clippy](https://github.com/rust-lang/rust-clippy), [rustfmt](https://github.com/rust-lang/rustfmt), [Axum](https://github.com/tokio-rs/axum), [Tokio](https://github.com/tokio-rs/tokio) | cargo check kann Buildskripte/Makros ausfuehren; nicht nur eine passive Textpruefung |
| C/C++ | [CMake](https://github.com/Kitware/CMake), [LLVM](https://github.com/llvm/llvm-project), [GoogleTest](https://github.com/google/googletest), [Catch2](https://github.com/catchorg/Catch2) | CTest orchestriert Tests; GoogleTest/Catch2 sind nicht pauschal reine C-Testframeworks |
| Shells | [ShellCheck](https://github.com/koalaman/shellcheck), [shfmt](https://github.com/mvdan/sh), [Bats](https://github.com/bats-core/bats-core), [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer), [Pester](https://github.com/pester/Pester) | shfmt -w schreibt Dateien; Bats/Pester fuehren Testcode aus, daher keine pauschale Nebenwirkungsfreiheit |
| SQL | [SQLFluff](https://github.com/sqlfluff/sqlfluff), [Flyway](https://github.com/flyway/flyway), [Liquibase](https://github.com/liquibase/liquibase) | Linting, Migrationen und Integrationstests sind unterschiedliche Aktionen |
| IaC | [Terraform](https://github.com/hashicorp/terraform), [OpenTofu](https://github.com/opentofu/opentofu), [TFLint](https://github.com/terraform-linters/tflint), [Checkov](https://github.com/bridgecrewio/checkov) | Lizenz/Edition am Pin pruefen; Terraform und OpenTofu nicht pauschal lizenzgleich |
| Container und Scanner | [Moby](https://github.com/moby/moby), [Compose](https://github.com/docker/compose), [Hadolint](https://github.com/hadolint/hadolint), [Trivy](https://github.com/aquasecurity/trivy), [Grype](https://github.com/anchore/grype) | GitHub-Quellen sind kein Beleg fuer Docker-freien Betrieb; Scanner brauchen Datenbanken und koennen Netzwerk nutzen |
| Cluster | [Kubernetes](https://github.com/kubernetes/kubernetes), [kind](https://github.com/kubernetes-sigs/kind), [k3d](https://github.com/k3d-io/k3d), [kubectl-Mirror](https://github.com/kubernetes/kubectl), [K9s](https://github.com/derailed/k9s) | kubectl-Repo ist Mirror/Issue-Tracker; kind/k3d starten Infrastruktur, keine blossen Validatoren |
| Manifeste und Policies | [kubeconform](https://github.com/yannh/kubeconform), [KubeLinter](https://github.com/stackrox/kube-linter), [Helm](https://github.com/helm/helm), [Kustomize](https://github.com/kubernetes-sigs/kustomize), [Kyverno](https://github.com/kyverno/kyverno), [Gatekeeper](https://github.com/open-policy-agent/gatekeeper) | Schema-/Policychecks garantieren keine Laufzeitfunktion; Admission-Controller muessen separat eingerichtet werden |

## CI/CD und Skill-Quellen: bestehende Bausteine nutzen

Die genannten [checkout](https://github.com/actions/checkout),
[setup-go](https://github.com/actions/setup-go),
[cache](https://github.com/actions/cache),
[upload-artifact](https://github.com/actions/upload-artifact),
[golangci-lint-action](https://github.com/golangci/golangci-lint-action),
[rust-toolchain](https://github.com/dtolnay/rust-toolchain) und
[rust-cache](https://github.com/Swatinem/rust-cache) sind Referenzen.
Die Verlinkung allein ist kein vollstaendiger Pipeline-Entwurf.

Das aktuelle setup-go-README beschreibt standardmaessiges Caching und einen
go.mod-basierten Cache-Key mit konfigurierbarem cache-dependency-path.
Das gilt nicht ungeprueft fuer jeden alten Commit. Unsere
[vorhandene Go-Vorlage](../../examples/manus-ci-cd/go-ci.yml.example) setzt
ausdruecklich cache: false. Keine Cache-/Release-Funktion neu behaupten.
Actions und Toolchains nach geprueftem Stand pinnen, Rechte und Zeitlimits
begrenzen, PR-Code nicht mit Produktions-Secrets ausfuehren.

Konkrete [Go-/Rust-CI und manueller Go-Release](../../examples/manus-ci-cd/README.md)
sind bereits vorhanden und bleiben inaktiv. Keine Interviewempfehlung
"direkt nach .github/workflows kopieren" automatisch umsetzen.
Container-/Deployment-Korrekturen: [Gemini-Abgleich](gemini-development-tooling.md).

Die [Anthropic-Skills](https://github.com/anthropics/skills) und deren
[Skill Creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator)
sind externe Referenzen, kein Perplexity-Original und keine hier installierten
Plugins. Die ebenfalls genannte
[Plugin-Variante](https://github.com/anthropics/claude-plugins-official/blob/main/plugins/skill-creator/skills/skill-creator/SKILL.md)
bleibt ein fremder Integrationsweg; ihre Verfuegbarkeit wurde hier nicht separat
bestaetigt. Repo-/Dateilizenz und Clientformat vor Uebernahme pruefen.

Statt einen weiteren identischen Skill anzulegen, wird
[sprach-infra-tooling](../../skills/sprach-infra-tooling/SKILL.md) um die
[Quellenpruefung fuer Interviews](../../skills/sprach-infra-tooling/references/interview-source-review.md)
erweitert. Fuer Architektur/CI dient
[tech-stack-architect](../../skills/tech-stack-architect/SKILL.md), fuer echte
Bestandsaufnahme [sandbox-tooling-overview](../../skills/sandbox-tooling-overview/SKILL.md).
Kein globaler Skill und kein Slash-Befehl wird aktiviert.

## Aktionsgrenzen und KI-Auswahl

- terraform init kann Provider/Module laden und Backends kontaktieren.
  plan liest Infrastruktur und kann sensible Daten in einer Plan-Datei
  ablegen; nicht als generell offline oder gefahrlos darstellen:
  [offizielle Plan-Referenz](https://developer.hashicorp.com/terraform/cli/commands/plan).
- EXPLAIN ANALYZE fuehrt die Abfrage aus; Migrationen veraendern Daten.
  Testcontainers sind kein Docker-freier Testweg. Wegwerf-Instanzen und
  synthetische Daten erst nach Freigabe bereitstellen.
- kind create cluster, kubectl apply und compose up sind Infrastrukturaktionen.
  Formatierer im Schreibmodus veraendern Dateien. Keine dieser Aktionen
  wurde fuer diese Dokumentation ausgefuehrt.
- MCP ist eine Tool-Schnittstelle, keine automatische Sandbox oder
  Berechtigungspruefung. Server, Scopes, Authentisierung und Werkzeugaktionen
  pruefen: [MCP-Sicherheitsleitfaden](https://modelcontextprotocol.io/specification/latest/basic/security_best_practices).
- Tracing kann Prompts, personenbezogene Daten, Quellcode und Secrets erfassen.
  Langfuse/LangSmith/Phoenix nicht ungeprueft gemeinsam aktivieren. Datenfluss,
  Redaction, Zugriff und Aufbewahrung klaeren, statt pauschal jeden Aufruf zu loggen.

Fuer deinen lokalen Schwerpunkt zuerst vorhandene Ollama-/Coding-Client-
Integration pruefen, nicht Cursor, Copilot und Claude Code gleichzeitig
als Pflichtstack installieren. Die [Claude-Code-Lizenzgrenze](../tools/claude-code.md)
bleibt bestehen. GitHub-Quellcode, proprietaerer Client, API-Dienst und offene
Modellgewichte sind verschiedene Dinge.

Die Grobwerte fuer 3B/8B/30B aus dem Interview sind keine Zusage fuer deinen
RTX-5080-Host oder Letsung MiniPC: Quantisierung, Kontext/KV-Cache,
Offloading, Parallelitaet und sonstige Last bestimmen den Bedarf.
Fuer Vergleiche [lokale Benchmarks](../tools/local-ai-benchmarks.md) nutzen.
LangGraph/Pydantic AI/CrewAI bleiben bedarfsabhaengige Framework-Optionen;
nicht jede Aufgabe braucht mehrere Agenten oder MCP.

## Pruefgrenzen

Keine Perplexity-interne Umgebung, Konnektoren, Android-Rechte, Modellaufrufe,
Compiler-Livebuilds oder Deployments getestet. Keine Paket-/Dockerinstallation,
WSL-Aktion, aktive CI, globalen Hooks, Commits oder Pushes ausgefuehrt.
Die Quellenliste ist dokumentiert, nicht als komplette neue Toolinstallation
ausgegeben. Fehlende Originaldateien bleiben offen.

Fuenf neue Perplexity-Tests und 45 vorhandene Interview-Regressionstests
bestanden. Geprueft sind lokale Verweise, Quellenzuordnung, Tabellenstruktur,
Artefaktgrenzen und Skill-Referenzen; Diff-Pruefung ohne Fehler. Das ersetzt
keinen funktionalen Agenten-, Compiler-, Container- oder Modelltest.
