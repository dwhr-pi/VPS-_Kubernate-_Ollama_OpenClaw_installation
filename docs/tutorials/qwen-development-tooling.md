# Qwen-AI-Interview: Entwicklungswerkzeuge, Quellen und Beispielpruefung

Weiterfuehrend: [Claude-Interview](claude-development-tooling.md) und
[Qwen Desktop, Claude Code und lokale Modelle unter Windows](qwen-desktop-claude-local.md).

Stand: **22.10.2026**. Grundlage ist das vom Nutzer bereitgestellte Qwen-Interview.
Eigener Bereich neben [Gemini](gemini-development-tooling.md),
[Perplexity](perplexity-development-tooling.md), [Grok](grok-development-tooling.md),
[Meta](meta-development-tooling.md) und [Manus](manus-interview-2026-10-22.md).

## Sinn und Zweck

Das Interview liefert einen wiederverwendbaren Ablauf: Stack auswaehlen,
Quellen pruefen, Projektgeruest vorbereiten, Tests/CI entwerfen und
Deployment-Voraussetzungen dokumentieren. Wir uebernehmen diesen Prozess,
nicht die pauschalen Versprechen von Produktionsreife, maximaler Leistung
oder sofort lauffaehigem Code.

Qwen als Modell, Qwen Chat, Qwen Code CLI und Qwen Code Desktop sind
verschiedene Ebenen. Eine Chat-Aussage ueber eine Python-Sandbox belegt weder
die Werkzeugrechte unseres lokalen Modells noch eine lokal vorhandene
Testumgebung. Auch ein ausgefuehrter Python-Snippet ist kein Compiler-,
Browser-, Datenbank- oder Deployment-Test.

## Bezug zum vorhandenen Setup

| Baustein | Vorhandener Weg | Grenze |
|---|---|---|
| Qwen Code CLI | [GitHub-Source-Build ohne Docker](../tools/qwen-code.md), [Upstream](https://github.com/QwenLM/qwen-code) | Build, Login, Agentenlauf und Modellanfrage getrennt; dieses Interview aendert keinen Installer |
| Qwen Code Desktop | [Windows-Anleitung](../tools/qwen-desktop-windows.md) | Native App, keine automatische WSL-Einrichtung; Browser-Download ist kein Installationsnachweis |
| Lokale Modelle | Vorhandene Ollama-/Coding-Profile | Modellkompatibilitaet, Quantisierung, Kontext und Hardware separat pruefen |
| Sprach-/Qualitaetswerkzeuge | [62er-Uebersicht](../DEVELOPMENT_TOOLS_OVERVIEW.md), [Lifecycle-Einstieg](../tools/development-toolchain-check.md) | Quelle, Rezept, installiert und funktional getestet sind verschiedene Zustaende |

Keine zweite Qwen-Installation, neuen Installed-Marker oder Modell-Downloads
aus den Interviewempfehlungen ableiten. GitHub bleibt bevorzugte Quellbasis;
npm/pip/Cargo-Abhaengigkeiten stammen dadurch nicht automatisch ebenfalls aus GitHub.
Die Quellenliste erzeugt keine neuen Installer oder Installationsnachweise.

## Was der Anhang wirklich enthaelt

| Material | Stand |
|---|---|
| Tech-Stack Discovery & Setup | Markdown-Pattern mit fuenf Phasen, kein validiertes SKILL.md-Paket mit Frontmatter und Client-Registrierung |
| Go-/Rust-CI | Vollstaendige YAML-Textbeispiele vorhanden; nicht als Dateien aktiviert und kein CI-Lauf nachgewiesen |
| Deployment | Dockerfile-, Compose-, Kubernetes- und Terraform-Snippets vorhanden; Review-Befunde unten |
| Praesentation | Vollstaendiger HTML-Quelltext mit neun Folien und Navigation im Anhang; kein fehlendes HTML behauptet |
| Test-/Buildbelege | Keine echten Compiler-, CI-, Browser- oder Restore-Protokolle mitgeliefert |

Die HTML-Vorlage wurde hier nicht als aktive Webseite installiert, im Browser
ausgefuehrt oder als PPTX konvertiert. Unsere bestehende
[13-Folien-Praesentation](../presentations/technology-tooling-overview.pptx)
bleibt unveraendert und ist nicht das Qwen-Original.

Die neun HTML-Folien behandeln Titel, Python, JS/TS, Go/Rust, C++/Shell,
Docker/Kubernetes, IaC, SQL und Zusammenfassung. Aussagen wie "strict mode
ist Pflicht", "immutable SemVer-Tags" und "reversible Migrationen" brauchen
die nachfolgenden Einschraenkungen. Fixe Hoehe und overflow:hidden sind
ausserdem kein Nachweis einer mobilen oder barrierefreien Darstellung.

## Quellenabgleich: nicht jede Vorlage ist ein offizieller Standard

Die Original-URLs bleiben nachvollziehbar; Pruefdatum ist 22.10.2026.
Nicht alle Projekte wurden gebaut oder vollstaendig auditiert.

| Interviewquelle | Einordnung / Korrektur |
|---|---|
| [Ruff](https://github.com/astral-sh/ruff), [uv](https://github.com/astral-sh/uv), [FastAPI](https://github.com/fastapi/fastapi), [Vite](https://github.com/vitejs/vite) | Primaerquellen fuer konkrete Projektwerkzeuge, keine universellen Gold-Standards; Ruff ersetzt nicht jeden Plugin-/Typpruefungsfall |
| [TypeScript-Node-Starter](https://github.com/Microsoft/TypeScript-Node-Starter) | Abruf lieferte 404, Wiederholung 429. Wartungs-/Verfuegbarkeitsstatus hier offen, nicht als gepruefte aktuelle Sicherheitsvorlage empfehlen |
| [Go project-layout](https://github.com/golang-standards/project-layout) | README grenzt sich ausdruecklich vom offiziellen Go-Team-Standard ab; fuer kleine Projekte kann das Layout ueberdimensioniert sein |
| [Go project-template](https://github.com/golang-standards/project-template) | README beschreibt anzupassende Platzhalter, keine Codegenerierung. Gepruefte Dateiliste enthielt README und .gitignore, kein fertiges Anwendungsgeruest |
| [C++ Best Practices](https://github.com/cpp-best-practices/cppbestpractices), [CMake-Template](https://github.com/cpp-best-practices/cmake_template) | Community-Leitfaden und Projektvorlage; Buildhooks, Versionen und Lizenz je Zielprojekt pruefen |
| [thiserror](https://github.com/dtolnay/thiserror), [anyhow](https://github.com/dtolnay/anyhow), [Rust](https://github.com/rust-lang/rust) | Fehlerbibliotheken und Compilerprojekt; [Rust API Guidelines](https://github.com/rust-lang/api-guidelines) sind ein separates Repository |
| [ShellCheck](https://github.com/koalaman/shellcheck) | Statische Shell-Pruefung, kein Beweis fuer robuste Backups oder bestandene Tests |
| [golang-migrate](https://github.com/golang-migrate/migrate), [SQLFluff](https://github.com/sqlfluff/sqlfluff) | Migrationen und SQL-Linting getrennt; nicht jede Migration ist verlustfrei umkehrbar |
| [awesome-compose](https://github.com/docker/awesome-compose) | README bezeichnet die Beispiele als lokale Entwicklungsbeispiele und warnt vor Produktionseinsatz; gegenteilige Interviewaussage nicht uebernehmen |
| [Kubernetes examples](https://github.com/kubernetes/examples) | Lern-/Beispielquelle, keine allgemeine Produktionsfreigabe |
| [ingress-nginx](https://github.com/kubernetes/ingress-nginx) | Nicht als neue Standardempfehlung uebernehmen: offizielle Kubernetes-Ankuendigung nennt Wartungsende Maerz 2026 |
| [AWS VPC-Modul](https://github.com/terraform-aws-modules/terraform-aws-vpc), [Modulorganisation](https://github.com/terraform-aws-modules) | Community-Module; Pin, Provider, Rechte, Kosten und Konfiguration pruefen, keine pauschal sicheren Defaults |

Zur Ingress-Empfehlung siehe die
[offizielle Retirement-Ankuendigung](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/).
Keine bestehende Clusterinstallation wurde untersucht oder automatisch migriert.
Die Nummern wie [[27]] im Interview sind keine aufloesbaren Quellenangaben;
massgeblich bleiben verlinkte Primaerquellen und konkrete Belege.

## Codebeispiele: konkrete Pruefpunkte

- TypeScript: validateEmail wird im Testschnipsel nicht implementiert;
  Test-Runner, Imports und Konfiguration fehlen. Ein erfolgreicher Testfall
  allein deckt ungueltige oder leere Adressen nicht ab.
- Go: Alle Datenbankfehler als 404 abzubilden ist fachlich falsch.
  Interne Fehlermeldungen nicht ungefiltert an Clients geben; Eingabe,
  Content-Type und JSON-Encodingfehler behandeln. Der gezeigte Test hat
  keinen Testinhalt und ist kein Nachweis von Handler-Verhalten.
- C++: Resource und main.cpp fehlen. Boost::filesystem explizit als
  benoetigte Komponente finden; Compilerstandard und Abhaengigkeiten
  deklarieren. Keine allgemeine Kompilierbarkeit des Snippets behaupten.
- Rust: Config fehlt. read_to_string kann ausser NotFound auch Rechte-,
  I/O- oder UTF-8-Fehler liefern; diese nicht pauschal als FileNotFound
  umetikettieren. Urspruengliche Fehlerursache erhalten.
- Bash: stderr nach /dev/null verbirgt die Backup-Diagnose. Tagespfade
  koennen kollidieren; atomare Fertigstellung, freie Disk, Archivpruefung
  und Restore-Test fehlen. set -euo pipefail ist keine universelle
  Robustheitsgarantie und fuer POSIX-sh nicht pauschal uebertragbar.
- PowerShell: ZIP mit Compress-Archive ist kein semantisch identisches
  tar-Backup. Versteckte Dateien werden laut
  [Microsoft-Dokumentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive)
  ausgelassen; Metadaten, Pfadauswahl und Wiederherstellung separat pruefen.
- SQL: INTERVAL '1 year' nicht als portabel fuer alle genannten Datenbanken
  darstellen. Bei gleichem order_date braucht "letzter Auftrag" eine
  deterministische Tie-Break-Regel. Indexnutzen messen; EXPLAIN ANALYZE
  fuehrt die Abfrage aus und CREATE INDEX veraendert die Datenbank.

Diese Beispiele werden nicht als neue Installer oder Backups ausgefuehrt.
Die Befunde sind Quelltextreview, kein sprachuebergreifender Live-Test.

## CI/CD: keine ungepruefte Production Pipeline aktivieren

Die mitgelieferten Workflows nennen sich Production Pipeline, haben aber
keinen Laufnachweis. Fuer neue Zielprojekte die vorhandenen
[inaktiven Go-/Rust-Vorlagen](../../examples/manus-ci-cd/README.md) verwenden,
nicht automatisch die Interviewdateien nach .github/workflows kopieren.

| Interviewdetail | Konsequenz |
|---|---|
| Go 1.22, Actions-Tags, gosec@master, Linter latest | Wartung/Kompatibilitaet pruefen, gepruefte Versionen und unveraenderliche Action-Pins statt gleitender Referenzen |
| Automatischer GHCR-Push nach main | Eigenstaendige Veroeffentlichung, nicht blosse CI; menschliche Freigabe und minimale packages-write-Rechte separat einrichten |
| Codecov-Upload | Externer Datenfluss fuer Coverage/Metadaten; nicht ohne Freigabe aktivieren |
| Rust-Dockerjob braucht check und security-audit, nicht coverage | Image-Push kann stattfinden, bevor Coverage beendet ist oder trotz fehlgeschlagener Coverage |
| cargo install cargo-audit / cargo-tarpaulin ohne Pin | Veraenderliche Buildwerkzeuge und Downloads; Toolversion, Locking und Runnerkompatibilitaet festlegen |
| --all-features | Kann unvereinbare Features aktivieren; projektspezifische Matrix statt universeller Regel |
| Keine --locked-Flags in Rust-Build/Test | Dependency-Aufloesung nicht als unveraenderlich bezeichnen |
| --test-threads=1 | Serialisiert Testausfuehrung, beweist keine Nebenlaeufigkeitssicherheit |
| Caching im Interview | Vorhandene eigene Go-Vorlage verwendet cache: false; keine neue Cache-/Scan-Funktion behaupten |

Workflow-Rechte, Zeitlimits, Artefakte und PR-Vertrauensgrenzen sind separat
zu reviewen. Gosec/Cargo-Audit/Coverage ersetzen weder funktionale Tests noch
einen geprueften Release-Prozess. Kein Codecov-Konto, Token oder aktiver
GitHub-Workflow wird eingerichtet.

## Container und Kubernetes: nicht direkt uebernehmen

Das Node-Dockerfile installiert im Builder nur Produktionsabhaengigkeiten,
ruft danach aber npm run build auf. Wenn etwa TypeScript als devDependency
benoetigt wird, fehlt der Compiler. Builder braucht seine Buildabhaengigkeiten;
Runtime-Abhaengigkeiten danach getrennt bereitstellen.
[npm-ci-Referenz](https://docs.npmjs.com/cli/v11/commands/npm-ci/).

Compose verbindet sich als user mit Datenbank app, initialisiert aber nur
POSTGRES_PASSWORD. Der gezeigte frische Standard-Postgres-Container erhaelt
damit keine passende user/app-Konfiguration. Beispielpasswoerter niemals
als reale Zugangsdaten nutzen. Port 3000:3000 bindet nicht nur Loopback.
Variablen fuer den frischen Datenbankstart siehe
[offizielles Postgres-Image](https://github.com/docker-library/docs/blob/master/postgres/README.md).
depends_on allein wartet nicht auf Datenbank-Bereitschaft:
[Compose-Startreihenfolge](https://docs.docker.com/compose/how-tos/startup-order/).

Im ausfuehrlicheren Kubernetes-Beispiel steht das Deployment in production,
der PodDisruptionBudget hat hingegen keinen Namespace. Ohne extern gesetzten
gleichen Namespace schuetzt er diese Pods nicht. Die ConfigMap myapp-config
wird referenziert, aber nicht bereitgestellt. Probes brauchen implementierte
Endpunkte; UID 1000 muss zum Image passen und read-only Root-FS braucht
passende beschreibbare Pfade.

PDBs steuern freiwillige Evictions, garantieren aber keine Verfuegbarkeit
bei Ausfaellen: [Kubernetes-PDB-Leitfaden](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).
Drei Replikate und maxUnavailable=0 sichern ohne
Kapazitaet, passende Probes und App-Verhalten kein Zero-Downtime.
SemVer-/Commit-Tags sind technisch veraenderbar; gepruefte Digests fuer
Deployments verwenden. Secrets sind nicht allein durch ihren Namen
verschluesselt, Namespaces keine vollstaendige Sicherheitsisolation.

Das Terraform-Snippet referenziert eine nicht gezeigte data.aws_ami.ubuntu.
Provider, Backend und weitere Netz-/Zugriffsvoraussetzungen fehlen. Kein
init/plan/apply ausfuehren: Downloads, Cloud-Kontakte und Kosten sind eigene
Aktionen. Ausfuehrlichere Grenzen: [Gemini](gemini-development-tooling.md)
und [Perplexity](perplexity-development-tooling.md).

## KI-Stack: Empfehlungen mit Wartungs- und Datenschutzgrenzen

| Interviewpunkt | Fuer unser Setup |
|---|---|
| OpenDevin / Devika als ein Link | [OpenDevin](https://github.com/OpenDevin/OpenDevin) leitet auf [OpenHands](https://github.com/OpenHands/OpenHands) um; das ist keine Devika-Quelle |
| SQLite + sqlite-vss | [sqlite-vss](https://github.com/asg017/sqlite-vss) meldet keine aktive Weiterentwicklung und verweist auf sqlite-vec; hier kein automatischer Austausch und kein neuer Installer |
| OpenRouter als Gateway | Bestehende [OnlineOnKeyServices-Uebersicht](../_API-Keys/OnlineOnKeyServices/README.md) verwenden, keine zweite Toolinstallation fuer einen API-Dienst |
| LiteLLM, Portkey und Tracing | Lokaler Client/Gateway macht externe Provider nicht lokal; Logs koennen Prompts, Quellcode und Secrets enthalten |
| Ollama, Open WebUI, Chroma als garantiert 100 Prozent lokal | Modell-, Embedding-, Tool-, Websuche-, Telemetrie- und Update-Datenfluesse pruefen, nicht allein den Stacknamen |
| pgvector aktivieren | Datenbank-Erweiterung mit Versions-/Rechte-/Backupbedarf, keine nebenwirkungsfreie Chat-Einstellung |
| Alles kombinierbar und production-ready | Integration, Authentisierung, Autorisierung, Last, Recovery und Kosten muessen getestet werden |

Fuer deinen RTX-5080-Host und Letsung MiniPC keine neue Hardware-Rueckfrage,
soweit der bekannte Kontext reicht. Mit einer Runtime und einem passenden
Coding-Frontend starten; RAG/Agenten/Gateway nur bei konkretem Bedarf ergaenzen.
Quantisierung und Kontext bestimmen RAM/VRAM-Bedarf mit.
[Lokale Benchmarks](../tools/local-ai-benchmarks.md) statt unbelegter
"maximaler Performance", "alle Modelle" oder allgemeiner Bestenlisten verwenden.

## Wiederverwendung und Pruefgrenzen

Das Fuenf-Phasen-Pattern wird mit vorhandenen Skills abgedeckt:
[sprach-infra-tooling](../../skills/sprach-infra-tooling/SKILL.md) fuer Auswahl
und Quellenreview, [tech-stack-architect](../../skills/tech-stack-architect/SKILL.md)
fuer Architektur/CI und
[fullstack-project-bootstrapper](../../skills/fullstack-project-bootstrapper/SKILL.md)
fuer ein konkret freigegebenes Projektgeruest. Keine weitere redundante
globale Skill-Kopie und keine automatische Slash-Befehl-Registrierung.

Keine Qwen-Sandbox, Compiler-/Container-Livebuilds, Modellaufrufe, Codecov-
Uploads, Datenbankmigrationen oder Clusteraktionen getestet. Keine WSL-Aktion,
Toolinstallation, aktive CI, Commits oder Pushes ausgefuehrt.

Pruefung: fuenf neue Qwen-Tests und 50 vorhandene Interview-Regressionstests
bestanden. Lokale Verweise, Quellenzuordnung, Tabellen und Artefaktgrenzen
geprueft; Diff-Pruefung ohne Fehler. Kein Ersatz fuer die oben genannten
funktionalen Build-/Browser-/Deployment-Tests.
