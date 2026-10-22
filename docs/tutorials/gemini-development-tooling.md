# Gemini-Interview: Entwicklungswerkzeuge und GitHub-Quellen

Ergaenzender Quellenabgleich: [Perplexity-Interview](perplexity-development-tooling.md).

Ergaenzt am **22.10.2026** um das zweite Nutzerinterview, die Skill-Vorlage
tech-stack-architect und den Abgleich seiner CI-/Deployment-Beispiele.

Weitere Interviews bleiben getrennt: [Meta AI](meta-development-tooling.md) und
[Manus](manus-interview-2026-10-22.md) sowie [Grok](grok-development-tooling.md).
Keine gegenseitige Zuschreibung interner Tools.

## Sinn und Zweck

Diese Anleitung uebertraegt das vom Nutzer bereitgestellte **Gemini-Interview**
in einen nachvollziehbaren Entwicklungsablauf fuer das Ultimate KI Setup:
Aufgabe planen, passende Werkzeuge waehlen, Code bearbeiten, lokal testen und
das Ergebnis vor einer Veroeffentlichung pruefen. Die Quellen dienen zum
Nachlesen und zur bewussten projektspezifischen Einrichtung, nicht zur
Installation aller Frameworks auf einmal.

Das ist ein eigener Gemini-Bereich, keine Ergaenzung angeblicher interner
Manus-Werkzeuge. Aussagen des Interviews ueber Googles Code Interpreter,
Cloud-Sandbox und Canvas sind **keine verifizierte interne Toolliste**.
Diese Produktfunktionen werden durch einen GitHub-Checkout nicht lokal
nachgebaut. Verfuegbarkeit und Grenzen haengen vom jeweiligen Google-Produkt ab.

## Bereits im Setup: Gemini CLI aus GitHub

Offizielle Quelle: [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli).
Der CLI-Quellcode steht unter
[Apache-2.0](https://github.com/google-gemini/gemini-cli/blob/main/LICENSE).
Das macht die angesprochenen Gemini-Modelle nicht zu lokalen Open-Source-Modellen
und garantiert kein unbegrenztes kostenloses API-Kontingent.

Der vorhandene Setup-Eintrag `Gemini_CLI` bereitet **nur GitHub-Quellen** vor:

| Eigenschaft | Aktueller Stand |
|---|---|
| Status | experimental; `github-source-not-built` |
| Gepinnter Commit | `ed96faedfd5571f055c44f2c9509d62321d1138d` |
| Ablage | `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/gemini_cli/` |
| Installationsnachweis | `source-ready.json` bestaetigt Quellen, keine lauffaehige CLI |
| Runtime | `runtime_ready=false`; Build, Node-Abhaengigkeiten und Login nicht eingerichtet |
| Nebenwirkungen | kein Docker, Modell-Download, Agentenstart oder automatischer Cloud-Aufruf |

Die folgenden Befehle sind Anleitung, keine hier ausgefuehrte Installation.
Vom Repository-Hauptverzeichnis aus:

```bash
# Schreibfreier Plan ueber den Python-Einstieg
python3 -I -B scripts/profiles/coding_agents.py source gemini_cli --dry-run
# Bewusst nur die gepinnten GitHub-Quellen vorbereiten
bash scripts/tools/gemini_cli_install.sh
# Quellenzustand pruefen, ohne Login oder Modellanfrage
bash scripts/tools/gemini_cli_check.sh
```

Ein erfolgreicher Quellencheck darf nicht als erfolgreicher Agentenlauf
verstanden werden. Der Pin ist ein Entwicklungssnapshot, keine Zusicherung einer
getesteten stabilen Version. Weitere Details zu Profilen, Quellenpruefung und
Deinstallation: [Coding-Agenten](../agents/coding-agent-profiles.md).

## Offizielle Quellen nach Aufgabenbereich

Stand der Quellenpruefung: **2026-10-21**. Links zeigen auf Projektquellen;
sie sind keine Build-Pins. Vor einer Installation Lizenz, Release,
Plattformunterstuetzung und Abhaengigkeiten am ausgewaehlten Commit pruefen.

### Python und Datenanalyse

| Werkzeug | Zweck | GitHub-Quelle | Einordnung / Aufwand |
|---|---|---|---|
| CPython | Python-Laufzeit | [python/cpython](https://github.com/python/cpython) | Laufzeit; Quellbuild aufwendig, System-Python nicht ersetzen |
| FastAPI | typisierte Web-APIs | [fastapi/fastapi](https://github.com/fastapi/fastapi) | Projektbibliothek, Serverstart separat |
| Flask | kleines Webframework | [pallets/flask](https://github.com/pallets/flask) | Projektbibliothek, Alternative zu FastAPI |
| Django | umfassende Webanwendungen | [django/django](https://github.com/django/django) | Framework mit Datenbank-/Migrationsbedarf |
| pandas | Tabellenanalyse | [pandas-dev/pandas](https://github.com/pandas-dev/pandas) | RAM-Bedarf abhaengig von Datensatzgroesse |
| Polars | DataFrames und Abfrageverarbeitung | [pola-rs/polars](https://github.com/pola-rs/polars) | Python-/Rust-Projekt; Quellbuild kann teuer sein |
| Matplotlib | Diagramme | [matplotlib/matplotlib](https://github.com/matplotlib/matplotlib) | Bibliothek, native Build-Abhaengigkeiten beachten |
| Seaborn | statistische Visualisierung | [mwaskom/seaborn](https://github.com/mwaskom/seaborn) | Bibliothek auf numerischem Python-Stack |
| PyTorch | Training und Inferenz | [pytorch/pytorch](https://github.com/pytorch/pytorch) | heavy; CUDA-/GPU-Kompatibilitaet gesondert pruefen |
| scikit-learn | klassische ML-Verfahren | [scikit-learn/scikit-learn](https://github.com/scikit-learn/scikit-learn) | Daten-/RAM-Bedarf variabel, native Abhaengigkeiten |
| mypy | statische Typpruefung | [python/mypy](https://github.com/python/mypy) | optionaler vorhandener Setup-Baustein |
| Pydantic | Validierung strukturierter Daten | [pydantic/pydantic](https://github.com/pydantic/pydantic) | Bibliothek, keine Berechtigungsgrenze |
| pytest | automatisierte Tests | [pytest-dev/pytest](https://github.com/pytest-dev/pytest) | Testwerkzeug; Tests koennen Code ausfuehren |

`asyncio` und `unittest` gehoeren zur Python-Standardbibliothek und brauchen
keinen eigenen Tool-Installer. Projektabhaengigkeiten in ein privates venv
installieren; fehlendes `venv`/`ensurepip` zuerst mit dem gewaehlten Python
abgleichen. Keine automatische Reparatur des System-Python aus diesem Tutorial.

### JavaScript und TypeScript

| Werkzeug | Zweck | GitHub-Quelle | Einordnung |
|---|---|---|---|
| React | Benutzeroberflaechen | [react/react](https://github.com/react/react) | frueher `facebook/react`; Projektbibliothek |
| Next.js | React-Anwendungsframework | [vercel/next.js](https://github.com/vercel/next.js) | Build-/Serverbedarf, nicht zusaetzlich zu jedem anderen Framework |
| Vue | Benutzeroberflaechen | [vuejs/core](https://github.com/vuejs/core) | Alternative zu React |
| Svelte | kompilierte Benutzeroberflaechen | [sveltejs/svelte](https://github.com/sveltejs/svelte) | alternative Frontend-Wahl |
| Node.js | JavaScript-Laufzeit | [nodejs/node](https://github.com/nodejs/node) | Version nach Projektanforderung waehlen |
| Express | Node-Webserver | [expressjs/express](https://github.com/expressjs/express) | Bibliothek, Netzwerkfreigabe separat |
| NestJS | strukturiertes Backend | [nestjs/nest](https://github.com/nestjs/nest) | Anwendungsframework |
| Bun | alternative Laufzeit und Werkzeuge | [oven-sh/bun](https://github.com/oven-sh/bun) | kein automatischer Ersatz fuer Node/npm |
| Deno | alternative Laufzeit | [denoland/deno](https://github.com/denoland/deno) | Berechtigungen und Kompatibilitaet bewusst konfigurieren |
| TypeScript | Typpruefung und Uebersetzung | [microsoft/TypeScript](https://github.com/microsoft/TypeScript) | Build-Abhaengigkeit |
| Zod | Laufzeitvalidierung | [colinhacks/zod](https://github.com/colinhacks/zod) | Bibliothek, keine Sandbox |
| Vite | Dev-Server und Build | [vitejs/vite](https://github.com/vitejs/vite) | Vorschau nur lokal binden |
| Webpack | Bundling | [webpack/webpack](https://github.com/webpack/webpack) | Alternative je nach bestehendem Projekt |
| ESLint | statische JS-/TS-Pruefung | [eslint/eslint](https://github.com/eslint/eslint) | Plugins fuehren ebenfalls Code aus |
| Jest | Testausfuehrung | [jestjs/jest](https://github.com/jestjs/jest) | projektspezifisch auswaehlen |
| Vitest | Vite-nahe Tests | [vitest-dev/vitest](https://github.com/vitest-dev/vitest) | Alternative zu Jest |

### Go, C/C++ und Rust

| Werkzeug | Zweck | GitHub-Quelle | Einordnung |
|---|---|---|---|
| Go | Compiler und Standardbibliothek | [golang/go](https://github.com/golang/go) | goroutines, channels, context und Fehlerbehandlung sind Sprach-/Standardmittel |
| Gin / Chi / Fiber | HTTP-Anwendungen | [Gin](https://github.com/gin-gonic/gin), [Chi](https://github.com/go-chi/chi), [Fiber](https://github.com/gofiber/fiber) | eines passend zum Projekt auswaehlen |
| gRPC / Protobuf | typisierte RPC-Schnittstellen | [grpc-go](https://github.com/grpc/grpc-go), [protobuf](https://github.com/protocolbuffers/protobuf) | Codegeneratoren und Runtime getrennt versionieren |
| LLVM / CMake / Make | C-/C++-Toolchain und Builds | [LLVM](https://github.com/llvm/llvm-project), [CMake](https://github.com/Kitware/CMake), [GNU-Make-Mirror](https://github.com/mirror/make) | grosse Quellbuilds; Make-Mirror ist nicht das primaere GNU-Hosting |
| Rust / Cargo / Clippy | Compiler, Pakete, Linting | [Rust](https://github.com/rust-lang/rust), [Cargo](https://github.com/rust-lang/cargo), [Clippy](https://github.com/rust-lang/rust-clippy) | keine neue globale Toolchain durch diese Doku |
| thiserror / anyhow | Fehlerdarstellung | [thiserror](https://github.com/dtolnay/thiserror), [anyhow](https://github.com/dtolnay/anyhow) | Bibliotheks-/Anwendungsfehler passend trennen |
| Tokio / Serde | Async und Serialisierung | [Tokio](https://github.com/tokio-rs/tokio), [Serde](https://github.com/serde-rs/serde) | Projektbibliotheken |
| Axum / clap | Web-API und CLI-Argumente | [Axum](https://github.com/tokio-rs/axum), [clap](https://github.com/clap-rs/clap) | alternative Anwendungstypen, kein Pflichtpaket |

C++11 bis C++23 sind Sprachstandards, keine separat installierbaren Dienste.
Rust verhindert nicht alle Fehler: `unsafe`, FFI, Build-Skripte und prozedurale
Makros brauchen weiterhin Review. Fuer CI-Beispiele siehe
[Go-/Rust-Pipelines](manus-ci-cd-deployment.md); deren allgemeine Muster sind
auch fuer Gemini-gestuetzte Entwicklung nutzbar, ohne Manus vorauszusetzen.

### Shells, SQL und Infrastruktur

| Werkzeug | Zweck | GitHub-Quelle | Grenze |
|---|---|---|---|
| PowerShell | plattformuebergreifende Shell | [PowerShell/PowerShell](https://github.com/PowerShell/PowerShell) | PowerShell 7 ist nicht Windows PowerShell 5.1; AD/WMI/CIM nicht ueberall verfuegbar |
| jq | JSON auf der Kommandozeile | [jqlang/jq](https://github.com/jqlang/jq) | Filter testen, Logs ohne Secrets |
| PostgreSQL / MySQL / SQLite | relationale Daten | [PostgreSQL-Mirror](https://github.com/postgres/postgres), [MySQL](https://github.com/mysql/mysql-server), [SQLite-Mirror](https://github.com/sqlite/sqlite) | SQLite eingebettet; Server, Daten und Backups separat verwalten |
| SQLAlchemy / Prisma / GORM | Datenzugriff und Modelle | [SQLAlchemy](https://github.com/sqlalchemy/sqlalchemy), [Prisma ORM](https://github.com/prisma/orm), [GORM](https://github.com/go-gorm/gorm) | `prisma/prisma` leitet auf `prisma/orm` um; Migrationen brauchen Freigabe |
| Docker / Kubernetes | optionale Laufzeit und Orchestrierung | [Moby](https://github.com/moby/moby), [Kubernetes](https://github.com/kubernetes/kubernetes) | Referenzen, keine Docker-Installation dieses Tutorials |
| Terraform / OpenTofu | Infrastrukturdefinition | [Terraform](https://github.com/hashicorp/terraform), [OpenTofu](https://github.com/opentofu/opentofu) | Terraform BSL-1.1 und OpenTofu MPL-2.0 unterscheiden |

Microsoft SQL Server ist kein hier aus GitHub installierbarer Open-Source-
Datenbankserver. Bash, awk, sed, grep, cron und logrotate sind allgemeine
Systemwerkzeuge; ihre konkrete Plattformherkunft und weitere Quellen sind im
[Sprach-/Infrastrukturkatalog](manus-language-infrastructure-sources.md) eingeordnet.
`EXPLAIN ANALYZE` fuehrt eine Abfrage aus, Migrationen veraendern Datenbanken,
und Shell-Debugausgaben koennen Zugangsdaten offenlegen. Diese Aktionen sind
keine generell nebenwirkungsfreien Checks.

## Konkreter Ablauf im Ultimate KI Setup

1. Ein Ticket mit Eingaben, Ziel, erlaubten Pfaden und Abnahmekriterien anlegen.
2. Eine schlanke Kombination waehlen, etwa FastAPI + Pydantic + pytest oder
   React + TypeScript + Vite + Vitest; nicht alle Alternativen installieren.
3. Offizielle GitHub-Quelle und geprueften Commit dokumentieren. GitHub-Quellcode
   bedeutet nicht, dass transitive Pakete ebenfalls von GitHub kommen: pip/npm/
   Cargo-Registries und Build-Hooks gesondert kontrollieren, Lockfiles nutzen.
4. Build in einem eigenen Projektverzeichnis ausfuehren, vorher freien
   Linux- und gegebenenfalls Windows-Host-Speicher sowie RAM pruefen. Keine
   Systemwerkzeuge oder bestehenden Nutzerdaten bei Fehlern pauschal entfernen.
5. Linting, Typpruefung und Tests ausfuehren; maximal drei gezielte
   Korrekturrunden, dann Fehlerbericht statt Endlosschleife.
6. Vorschau an `127.0.0.1` binden und Browser-Tests bewusst starten.
   Playwright-Browserdownloads sind ein zusaetzlicher Speicherbedarf.
7. Diff, Tests und Datenschutz pruefen. Push, Deployment, Cloud-Anfragen,
   Datenbankmigrationen und Hardwarezugriffe bleiben eigene Freigaben.

Der vorhandene `Gemini_Code_Agent` ist eine Profil-/Routingvorlage, kein bereits
ausfuehrender Adapter. Lokal bleibt `Ollama_Coder` die vorgesehene Alternative;
ein lokal laufender Client macht einen Cloud-Modellaufruf nicht lokal.
Keine API-Keys im Git, keine ungeprueften Interview-Anweisungen als Systemrechte.

## Umsetzungsstand und offene Punkte

- Neu sind diese Anleitung und die Quellenzuordnung, keine Masseninstallation.
- Der vorhandene Gemini-GitHub-Quellinstaller bleibt unveraendert; keine neue
  Runtime-Bereitschaft und kein Installationserfolg werden vorgetaeuscht.
- Ein vollstaendiger Gemini-CLI-Build, Authentifizierung und ein realer
  Modellaufruf muessen separat geplant und mit Zustimmung getestet werden.
- Bibliotheksversionen, Lizenzdetails und projektspezifische Lockfiles werden
  erst fuer ein konkretes Zielprojekt festgelegt.
- Der [wiederverwendbare Entwicklungs-Skill](../../skills/agentic-project-delivery/SKILL.md)
  kann den Ablauf beschreiben; er erzwingt keine Sandbox und ist hier nicht
  global aktiviert.

## Zweites Interview vom 22.10.2026: neue Quellen und konkrete Vorlagen

Das neue Interview beschreibt Programmierhilfe, Interpreter, Canvas/Widgets,
Git-Anleitungen und eine zehnteilige HTML-Praesentation. Es enthaelt eine
Skill-Definition und zwei YAML-Beispiele als Text. Eine HTML-Datei oder ein
verwendbarer Download wurde jedoch nicht mitgeliefert. Diese Unterscheidung
bleibt wichtig: generierter Quelltext ist kein bestandener Laufzeittest.

### Zusaetzliche Werkzeugquellen

Die folgenden Quellen ergaenzen die Tabellen oben. Bibliotheken sind nicht
automatisch neue Setup-Installer; vorhandene Rezepte stehen im
[62er-Installationsweg](../tools/development-toolchain-check.md). Keine Pakete
werden aus diesem Tutorial heraus installiert und keine Installed-Marker gesetzt.

| Werkzeug | Quelle | Zweck und Grenze |
|---|---|---|
| Streamlit | [streamlit/streamlit](https://github.com/streamlit/streamlit) | Python-Datenapps; lokal betreibbar, kein automatisch gestartetes Dashboard |
| Gradio | [gradio-app/gradio](https://github.com/gradio-app/gradio) | Modell-/Funktions-UIs; keine oeffentlichen Share-Links oder Uploads ohne Freigabe |
| Reflex | [reflex-dev/reflex](https://github.com/reflex-dev/reflex) | Webanwendungen mit Python; generierter Frontend-Stack und Buildbedarf separat pruefen |
| Echo | [labstack/echo](https://github.com/labstack/echo) | Go-Webframework als Alternative, kein Pflichtzusatz zu Gin/Chi |
| Cobra | [spf13/cobra](https://github.com/spf13/cobra) | Go-CLI-Bibliothek, keine eigenstaendige Agenten-Runtime |
| Criterion.rs | [bheisler/criterion.rs](https://github.com/bheisler/criterion.rs) | Rust-Benchmarks; Messaufbau und Streuung dokumentieren, kein LLM-Qualitaetsscore |
| Docker CLI / Compose | [docker/cli](https://github.com/docker/cli), [docker/compose](https://github.com/docker/compose) | Quellprojekte getrennt von Moby; keine Docker-Installation aus dieser Anleitung |
| Helm / Kustomize | [helm/helm](https://github.com/helm/helm), [kubernetes-sigs/kustomize](https://github.com/kubernetes-sigs/kustomize) | Manifest-/Paketwerkzeuge; Rendering und Cluster-Aenderung unterscheiden |

PostgreSQL und SQLite bleiben offiziell bezeichnete GitHub-Mirrors; ein Mirror
ist nicht automatisch das primaere Entwicklungs-Hosting. Rust-Compiler und
Cargo sind getrennte Quellprojekte, nicht ausschliesslich rust-lang/rust.
Die im Interview verwendete Prisma-Adresse verweist auf die bereits oben
dokumentierte neue Quelle. Alte URLs als Herkunftshinweis erhalten, nicht
als unabhaengige neue Programme zaehlen.

### Wiederverwendbarer Skill: tech-stack-architect

Die mitgelieferte Markdown-Definition dient als Grundlage fuer unseren
[Repository-Skill tech-stack-architect](../../skills/tech-stack-architect/SKILL.md).
Er unterstuetzt Architekturentscheidungen und die Vorbereitung von Go-/Rust-CI
und Deployment-Dateien. Die Beispiele werden aus dem vorhandenen
[CI/CD-Verzeichnis](../../examples/manus-ci-cd/README.md) wiederverwendet.

Die Namen `/ci-cd`, `/dockerize` und `/k8s-manifest` aus dem Interview sind
**keine hier registrierten Slash-Befehle**. Sie beschreiben moegliche Aufgaben.
Auch `/skill-creator` ist kein automatisch aktivierter Gemini-Befehl unseres
Installers. Der neue Skill ist projektlokal dokumentiert, nicht global installiert.

Anders als die Vorlage verspricht er keine ungepruefte Produktionsreife und
verbietet nicht jeden Platzhalter: ungepruefte Image-Digests, Secrets, Domains
und Clusterziele muessen deutlich als fehlende Eingaben markiert bleiben,
statt angeblich fertige Werte zu erfinden.

### CI-Korrekturen gegenueber den Interviewbeispielen

- Die Go-Beispiele pinnen alte Sprach-/Linterversionen. Fuer ein Zielprojekt
  kompatible, gepflegte Versionen anhand seiner Manifeste waehlen; diese Werte
  nicht ungeprueft als aktuelle Empfehlung uebernehmen.
- Ein Push nach main ist keine menschliche Release-Freigabe. Das Beispiel
  veroeffentlicht automatisch Images; wir verwenden stattdessen den bereits
  vorhandenen manuellen Release-Weg. Keine neue aktive Workflow-Datei anlegen.
- GHCR-Publishing braucht passende Paket-Schreibrechte. Diese nur dem
  Publish-Job geben, nicht pauschal PR-/Testjobs. Repository-Voreinstellungen
  nicht als garantierte Rechte voraussetzen:
  [GitHub: GITHUB_TOKEN und minimale Rechte](https://docs.github.com/en/actions/tutorials/authenticate-with-github_token).
- Actions-Tags und Rust stable sind veraenderlich. Workflow-Zeitlimit,
  nachvollziehbare Pins und Lockfiles beruecksichtigen. Im Rust-Kurzbeispiel
  ist nur der abschliessende Build explizit gelockt, nicht der Testlauf.
- Der Rust-Release-Job baut lediglich ein Binary: Ohne Upload-/Publish-Schritt
  entsteht daraus kein dauerhaft bereitgestelltes Release-Artefakt. Die
  vorhandene Vorlage enthaelt dagegen einen Artefaktschritt.
- Das Go-Interview aktiviert Caching; unsere vorhandene Vorlage verwendet
  ausdruecklich cache: false. Buildx-/Cache-/Image-Push-Schritte aus dem
  Interview sind hier nicht neu implementiert oder ausgefuehrt.

### Container und Kubernetes: wichtige Grenzen

Ein non-root Anwendungsprozess mit USER 10001 bedeutet nicht automatisch
Rootless Docker. Rootless betrifft auch den Daemon und seine User-Namespace-
Ausfuehrung: [offizielle Docker-Erklaerung](https://docs.docker.com/engine/security/rootless/).

Requests und Limits verhindern OOM-Kills nicht: Requests dienen der
Ressourcenplanung, ein ueberschrittenes Speicherlimit kann zur Beendigung
fuehren. CPU-Limits koennen drosseln. Werte unter realer Last messen, statt
"strikte Limits" als Ausfallschutz zu versprechen:
[Kubernetes-Ressourcenverwaltung](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

Rust-gnu-Binaries passen nicht ungeprueft in Alpine/musl oder scratch. libc,
TLS-Zertifikate und dynamische Bibliotheken muessen zum Ziel passen.
Groessenoptimierung mit opt-level=z/LTO kann andere Leistungsziele verschlechtern;
Stripping entfernt Debug-Informationen. Vorher messen und Debug-Artefakte planen.
Read-only Root-FS braucht passende beschreibbare Temp-/Datenpfade; Probes,
Graceful Shutdown und Zeitbudgets sind anwendungsbezogen zu testen.

### KI-Toolauswahl: Korrekturen der Empfehlungen

| Interviewempfehlung | Einordnung fuer uns |
|---|---|
| vLLM / SGLang als leistungsfaehige Server | Quellen und Auswahlgrenzen im [Grok-Abgleich](grok-development-tooling.md); kein pauschaler Speed-Vergleich ohne Messung |
| OpenHands / Claude Code | [OpenHands-Quelle](https://github.com/OpenHands/OpenHands) und [Claude-Code-Lizenzgrenze](../tools/claude-code.md) getrennt betrachten; keine identische Open-Source-/Installationszusage |
| Jan / LM Studio beide als Open Source | [Jan](https://github.com/janhq/jan) ist ein eigenes Quellprojekt. [LM-Studio-Dokumentation](https://lmstudio.ai/docs/app) beschreibt lokale Nutzung, belegt aber nicht die pauschale Open-Source-Aussage des Interviews |
| Suno / MusicGen | Suno als Cloud-Dienst nicht mit dem [AudioCraft-/MusicGen-Quellprojekt](https://github.com/facebookresearch/audiocraft) gleichsetzen; Code- und Modelllizenzen sowie kommerzielle Nutzbarkeit getrennt pruefen |
| k3s / microk3s | Gemeint sind wahrscheinlich [K3s](https://github.com/k3s-io/k3s) oder [MicroK8s](https://github.com/canonical/microk8s); microk3s ist keine hier belegte offizielle Projektbezeichnung |

ComfyUI, Ollama, Open WebUI und OpenClaw nicht wegen Formulierungen wie
"ultimative Wahl" oder "voll ausgestattetste" mehrfach installieren. Bestehende
Integration, Hardware, Datenfluss, Lizenz, Kosten und eigene Tests entscheiden.
GitHub als Quelle bedeutet weiterhin nicht, dass ein Projekt Docker-frei
startet oder eine Cloud-Modell-API lokal wird.

### Praesentation und Pruefgrenzen

Das angekuendigte zehnteilige HTML-Deck fehlt im Anhang. Die bestehende
[13-Folien-Praesentation](../presentations/technology-tooling-overview.pptx)
bleibt unveraendert und wird nicht als Gemini-HTML-Original ausgegeben.
Kein Gemini-Login, Modellaufruf, Live-CI, Container-/Clusterstart oder WSL-Zugriff
wurde fuer diese Ergaenzung ausgefuehrt.

Pruefung: sieben Gemini-Tests sowie 38 Grok-/Meta-/Manus-Regressionstests
bestanden; Diff-Pruefung ohne Fehler. Der Standard-Skillvalidator konnte
wegen fehlendem PyYAML nicht starten. Skill-Metadaten, Quellenzuordnung und
lokale Verweise wurden durch die Offline-Tests geprueft; kein Paket nachinstalliert.
