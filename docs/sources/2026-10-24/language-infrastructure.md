# Übersicht: Werkzeuge für Sprachen, Shells und Infrastruktur

Die folgenden Stacks sind bewährte Ausgangspunkte, keine Pflichtlisten. Die konkrete Auswahl hängt
von Zielplattform, Teamstandard, Projektgröße und Sicherheitsanforderungen ab. Versionen, Lockfiles
und CI-Prüfungen sollten im Repository festgelegt werden.

## JavaScript und TypeScript

**Einsatz:** Web-Frontends, Node.js-Services, CLIs und Automatisierung. TypeScript ergänzt
JavaScript um statische Typprüfung.

**Kernwerkzeuge:** [Node.js](https://github.com/nodejs/node) und `package.json` für Laufzeit und
Skripte, [TypeScript](https://github.com/microsoft/TypeScript) für Typprüfung und Build,
[Prettier](https://github.com/prettier/prettier) für Formatierung,
[ESLint](https://github.com/eslint/eslint) für Code-Regeln und
[Vitest](https://github.com/vitest-dev/vitest) für Unit- und Integrationstests.
[Vite](https://github.com/vitejs/vite) eignet sich besonders für Frontends,
[Playwright](https://github.com/microsoft/playwright) für Browser-End-to-End-Tests und
[pnpm](https://github.com/pnpm/pnpm) als optionaler Paketmanager.

**Typischer Ablauf:** Node-Version, Lockfile und `tsconfig.json` festlegen; lokal entwickeln; vor
dem Commit formatieren, linten und mit `tsc --noEmit` prüfen; anschließend Tests und
Produktions-Build ausführen. In CI werden dieselben Schritte reproduzierbar wiederholt. Für
Node-Debugging hilft `node --inspect-brk`.

## Go

**Einsatz:** Kompilierte Services, Netzwerkprogramme, CLIs und nebenläufige Backends.

**Kernwerkzeuge:** Die offizielle [Go-Toolchain](https://github.com/golang/go) deckt `go mod`,
`go build`, `go fmt`, `go test`, Benchmarks und `go vet` ab.
[gopls](https://github.com/golang/tools/tree/master/gopls) bietet Editorfunktionen,
[Delve](https://github.com/go-delve/delve) dient dem Debugging und
[golangci-lint](https://github.com/golangci/golangci-lint) bündelt zusätzliche Linter.

**Typischer Ablauf:** Abhängigkeiten in `go.mod` verwalten; regelmäßig `go fmt ./...`,
`go test ./...` und `go vet ./...` ausführen. Bei Bedarf `go test -race ./...` und Coverage
ergänzen. In GitHub Actions richten [actions/checkout](https://github.com/actions/checkout) und
[actions/setup-go](https://github.com/actions/setup-go) die CI-Umgebung ein.

## C und C++

**Einsatz:** Systemnahe Software, Embedded-Systeme, Performance-kritische Komponenten und native
Anwendungen.

**Kernwerkzeuge:** Eine verbindlich gewählte Compilerfamilie wie
[GCC](https://github.com/gcc-mirror/gcc) oder [Clang/LLVM](https://github.com/llvm/llvm-project),
[CMake](https://github.com/kitware/cmake) für Builds und CTest für die Testausführung.
`clang-format` sorgt für Formatierung, `clang-tidy` ergänzt statische Analyse. Für C++ kommen
[GoogleTest](https://github.com/google/googletest) oder [Catch2](https://github.com/catchorg/Catch2)
infrage.

**Typischer Ablauf:** Compiler-, Sprachstandard- und Plattformversionen festlegen; mit CMake
out-of-source konfigurieren; Debug-, Release- und gegebenenfalls Sanitizer-Builds getrennt
ausführen. Danach `ctest --test-dir build --output-on-failure` starten. AddressSanitizer und
UndefinedBehaviorSanitizer helfen bei Speicher- und Laufzeitfehlern. Debugging erfolgt mit LLDB aus
LLVM oder GDB aus dem GNU-Projekt.

## Rust

**Einsatz:** Systemnahe und performante Software mit Fokus auf Speicher- und
Nebenläufigkeitssicherheit, etwa CLIs, Services und Bibliotheken.

**Kernwerkzeuge:** [rustup](https://github.com/rust-lang/rustup) verwaltet Toolchains,
[Cargo](https://github.com/rust-lang/cargo) Paketverwaltung und Build.
[rustfmt](https://github.com/rust-lang/rustfmt) formatiert,
[Clippy](https://github.com/rust-lang/rust-clippy) lintet und
[rust-analyzer](https://github.com/rust-lang/rust-analyzer) bietet Editorunterstützung.

**Typischer Ablauf:** Toolchain per `rust-toolchain.toml` festlegen; während der Entwicklung
`cargo check` nutzen; vor dem Commit `cargo fmt --all -- --check`, `cargo clippy` und
`cargo test --all-targets --all-features` ausführen. Für reproduzierbare Builds eignet sich
`cargo build --locked`. `cargo-nextest` und `cargo-llvm-cov` sind optionale Ergänzungen für große
Testsuiten beziehungsweise Coverage.

## Bash

**Einsatz:** Unix-Automatisierung, Build-/Deploy-Helfer und Systemskripte.

**Kernwerkzeuge:** Bash als Interpreter, `bash -n` für Syntaxprüfungen,
[ShellCheck](https://github.com/koalaman/shellcheck) für statische Analyse,
[shfmt](https://github.com/mvdan/sh) für Formatierung und
[Bats-core](https://github.com/bats-core/bats-core) für Verhaltenstests.
[BashDB](https://github.com/Trepan-Debuggers/bashdb) ist eine optionale Debugging-Ergänzung.

**Typischer Ablauf:** Shebang, erwartete Bash-Version, externe Abhängigkeiten und Exit-Codes
dokumentieren; danach Syntaxprüfung, ShellCheck, shfmt und Bats ausführen. Für die Fehlersuche
zunächst `bash -x` oder gezielte `DEBUG`-/`ERR`-Traps nutzen. Bash selbst wird upstream im
GNU-Savannah-Projekt gepflegt; ein GitHub-Mirror wird daher nicht als offizielle Bash-Quelle
ausgegeben.

## PowerShell

**Einsatz:** Automatisierung und Administration auf Windows, Linux und macOS, insbesondere mit
PowerShell 7+.

**Kernwerkzeuge:** [PowerShell](https://github.com/PowerShell/PowerShell) als Laufzeit, die
offizielle [VS-Code-Erweiterung](https://github.com/PowerShell/vscode-powershell),
[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) für statische Regeln und
[Pester](https://github.com/pester/Pester) für Tests und Mocks.
[Invoke-Build](https://github.com/nightroman/Invoke-Build) ist bei größeren Buildabläufen optional.

**Typischer Ablauf:** Zielversion festlegen und PowerShell 7+ nicht stillschweigend mit Windows
PowerShell 5.1 gleichsetzen. Skripte reproduzierbar mit `pwsh -NoProfile -File` starten,
Analyzer-Regeln versionieren und `Invoke-Pester -CI` ausführen. Seiteneffekte sollten in Unit-Tests
durch Pester-Mocks isoliert werden.

## SQL

**Einsatz:** Daten abfragen, modellieren und verändern. Syntax und Möglichkeiten hängen immer vom
Datenbanksystem und Dialekt ab.

**Kernwerkzeuge:** Für einen PostgreSQL-Stack sind
[PostgreSQL](https://github.com/postgres/postgres) beziehungsweise `psql` zum Ausführen und
Analysieren, [Flyway](https://github.com/flyway/flyway) für versionierte Migrationen und
[SQLFluff](https://github.com/sqlfluff/sqlfluff) für Linting und Formatierung ein guter Kern.
[dbt Core](https://github.com/dbt-labs/dbt-core) passt zu analytischen ELT-/Warehouse-Modellen,
[pgTAP](https://github.com/theory/pgtap) zu PostgreSQL-nahen Tests.

**Typischer Ablauf:** Dialekt und Zielsystem festlegen; lokale und CI-Testdatenbank bereitstellen;
jede Schemaänderung als neue Migration einchecken; auf einer frischen Datenbank migrieren; SQLFluff
ausführen und Datenbank-/Integrationstests starten. Für Performancefragen `EXPLAIN` beziehungsweise
`EXPLAIN ANALYZE` verwenden. Rollback, Locking und DDL-Transaktionen müssen je DBMS geprüft werden.

## Docker

**Einsatz:** Anwendungen und Abhängigkeiten als portable Container-Images bauen, lokal ausführen und
in CI liefern.

**Kernwerkzeuge:** [Docker CLI](https://github.com/docker/cli),
[Docker Compose](https://github.com/docker/compose),
[Docker Buildx](https://github.com/docker/buildx) und [BuildKit](https://github.com/moby/buildkit).
[Hadolint](https://github.com/hadolint/hadolint) prüft Dockerfiles. Für CI sind
[setup-buildx-action](https://github.com/docker/setup-buildx-action),
[build-push-action](https://github.com/docker/build-push-action) und
[login-action](https://github.com/docker/login-action) zentrale Bausteine.

**Typischer Ablauf:** Dockerfile mit nachvollziehbaren Basis-Images und `compose.yaml` mit Diensten
und Healthchecks erstellen; `docker compose config` und Hadolint ausführen; bauen, starten und
Anwendungstests ausführen. Bei Fehlern helfen `docker compose logs`, `docker inspect`,
`docker events` und kontrolliertes `docker exec`. Build-Secrets nicht über `ARG` oder Image-Layer
weitergeben. Image-Scans und SBOMs sind sinnvolle Ergänzungen, aber kein vollständiges
Sicherheitsprogramm.

## Kubernetes

**Einsatz:** Containerisierte Workloads deklarativ bereitstellen, skalieren und betreiben.

**Kernwerkzeuge:** [kubectl](https://github.com/kubernetes/kubectl) für Verwaltung und Diagnose,
[kind](https://github.com/kubernetes-sigs/kind) für lokale und CI-Cluster,
[Helm](https://github.com/helm/helm) **oder**
[Kustomize](https://github.com/kubernetes-sigs/kustomize) für Manifeste.
[Kubeconform](https://github.com/yannh/kubeconform) validiert Schemata,
[KubeLinter](https://github.com/stackrox/kube-linter) prüft Best Practices und
[Skaffold](https://github.com/GoogleContainerTools/skaffold) kann Build-/Deploy-Schleifen
vereinheitlichen. [Argo CD](https://github.com/argoproj/argo-cd) und
[Flux](https://github.com/fluxcd/flux2) sind alternative GitOps-Ansätze.

**Typischer Ablauf:** Manifeste oder Charts pflegen; mit Helm rendern oder mit Kustomize bauen;
gerenderte Ergebnisse linten und validieren; in einem frischen kind-Cluster deployen und mit kubectl
prüfen. Zusätzlich zu Schema-Checks sind `kubectl diff` oder `kubectl apply --dry-run=server` und
Integrationstests sinnvoll. Zur Diagnose helfen `get`, `describe`, Events, `logs`, `exec` und
gegebenenfalls `debug`.

## Terraform

**Einsatz:** Infrastruktur und Cloud-Ressourcen deklarativ, versioniert und prüfbar verwalten.

**Kernwerkzeuge:** [Terraform CLI](https://github.com/hashicorp/terraform) für `init`, `fmt`,
`validate`, `plan`, `apply` und `test`;
[Terraform Language Server](https://github.com/hashicorp/terraform-ls) für Editorunterstützung.
[TFLint](https://github.com/terraform-linters/tflint) ergänzt Regeln,
[Checkov](https://github.com/bridgecrewio/checkov) IaC-Sicherheitschecks,
[terraform-docs](https://github.com/terraform-docs/terraform-docs) Dokumentation und
[Terratest](https://github.com/gruntwork-io/terratest) weitergehende Integrationsprüfungen. Für
GitHub Actions ist [setup-terraform](https://github.com/hashicorp/setup-terraform) verfügbar.

**Typischer Ablauf:** Terraform-, Provider- und Modulversionen pinnen; `terraform init` ausführen;
vor Commits `terraform fmt -recursive` und `terraform validate` starten. Pull Requests erzeugen
einen kontrollierten Plan. `terraform test` ist ab Terraform 1.6 verfügbar; Terratest kann echte
Ressourcen, Kosten und Cleanup erfordern. `apply` gehört in geschützte Umgebungen mit Review und
minimalen Berechtigungen. State, Plan-Dateien und Logs können sensible Informationen enthalten.

## Gemeinsamer CI-/Git-Ablauf

Unabhängig von der Sprache ist ein robuster Ablauf meistens:

1. Repository auschecken und Versionen beziehungsweise Toolchains festlegen.
2. Abhängigkeiten reproduzierbar aus Lockfiles oder festgelegten Versionen installieren.
3. Formatierung und statische Analyse ausführen.
4. Unit-, Integrations- oder Infrastrukturtests ausführen.
5. Build, Container-Image oder gerenderte Infrastrukturkonfiguration prüfen.
6. Bei Pull Requests nur validieren und testen; Veröffentlichungen und Deployments an geschützte
   Branches/Umgebungen binden.
7. Logs, Testberichte und relevante Artefakte bei Fehlern sichern, aber keine Secrets oder sensiblen
   Zustandsdaten veröffentlichen.

## Meine Unterstützung

Ich kann für ein konkretes Projekt den schlanksten passenden Stack auswählen, Repository- und
Tool-Konfigurationen anlegen, Build-/Test-/Lint-Skripte vereinheitlichen, CI-Workflows entwerfen
oder prüfen und Fehler reproduzierbar eingrenzen. Ebenso kann ich Tests, Dockerfiles,
Kubernetes-Manifeste, SQL-Migrationen und Terraform-Module schreiben oder überarbeiten. Vor
produktiven Änderungen sollten Zielplattform, Versionen, Berechtigungen, Secrets, Kosten und
Rollback-Strategie konkret geprüft werden.
