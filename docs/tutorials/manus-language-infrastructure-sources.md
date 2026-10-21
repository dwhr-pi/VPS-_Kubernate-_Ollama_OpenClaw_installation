# Sprachen, Shells und Infrastruktur: weitere Quellen aus dem Manus-Interview

Konkrete Umsetzung: [Skill, Go-/Rust-CI, Deployment und Praesentation](manus-ci-cd-deployment.md).

**Im Setup installierbar/verwalten:** [Alle 62 Quellen: Voraussetzungen und Installer](../tools/development-toolchain-check.md),
Hauptmenue 16 oder Zusatzschaltflaeche im Tools-Menue 8.
52 neue experimentelle private Build-/Paketrezepte plus zehn vorhandene Adapter;
keine automatischen Dienste oder aktivierten CI-/Editor-Pakete. Die folgende
Quelleneinordnung ist kein Nachweis von 62 erfolgreichen Livebuilds.

**Direkte Werkzeugtabelle:** [alle 62 Eintraege mit konkretem Setup-/Projektweg](../DEVELOPMENT_TOOLS_OVERVIEW.md).
Jetzt auch [sieben weitere echte GitHub-Go-Build-Installer](../tools/development-go-tools.md),
statt diese CLIs nur als TODO im Quellenkatalog stehen zu lassen.

**Sinn und Zweck:** Die passenden lokalen Pruefwerkzeuge fuer ein konkretes
Agentenprojekt finden, statt jede Sprache und jede Infrastruktur zu installieren.
Diese Ergaenzung ordnet die **62 GitHub-Repositories** aus der neuen Nutzerquelle
in zehn Stacks ein. Einige waren bereits im ersten Quellenkatalog enthalten;
62 bedeutet deshalb nicht 62 neue Tools oder Installer. Die Uebersicht ist kein
Nachweis fuer Manus-interne Software, Versionen oder eine offene Manus-Runtime.

Stand: **21.10.2026**. GitHub-Metadaten wurden fuer alle Adressen angefragt;
die Abfrage wurde teilweise mit **HTTP 403** begrenzt. Fuer diese Eintraege ist
der aktuelle Metadaten-/Archivstatus **nicht vollstaendig verifiziert**. Wichtige
Korrekturen unten wurden anhand der verlinkten Primaerquellen geprueft.
Keine pauschale Erreichbarkeits-, Lizenz-, Funktions- oder Sicherheitsgarantie.
Lizenzen, Pins, Toolchains und Plattformen vor einer Installation einzeln pruefen.

**Urspruenglicher Quellenkatalog:** Keine neuen Installer oder Installed-Marker
im ersten Dokumentationsschritt; keine Programme installiert, kein Docker-/WSL-Zugriff, keine Shellprofile,
Git-Hooks, Runner, Datenbanken, Cluster oder Cloud-Ressourcen eingerichtet.
Bestehende Tools und Installer werden hier nicht automatisch migriert.
Die im Text genannten Befehle sind Beispiele nach gesonderter Freigabe.

**Jetzt als Tools ergaenzt:** [SQLFluff, Bats_Core und Invoke_Build](../tools/language-quality-tools.md)
mit gepinnten GitHub-Installern, Menue, Status, Doctor und Deinstallation.
Die verlinkte Seite trennt neue Tools, vorhandene Eintraege und verbleibende TODOs.
Keine neuen Installer fuer reine Bibliotheken oder Workflow-Actions vortaeuschen.

## JavaScript und TypeScript

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [Node.js](https://github.com/nodejs/node) | JS-Laufzeit | Version projektbezogen waehlen; kein globales Upgrade |
| [TypeScript](https://github.com/microsoft/TypeScript) | Typen und Build | tsc --noEmit fuer Typpruefung; kein Funktionstest |
| [Prettier](https://github.com/prettier/prettier) | Formatierung | Zunaechst --check; Schreibmodus aendert Dateien |
| [ESLint](https://github.com/eslint/eslint) | Statische Regeln | Konfiguration und Plugins koennen Code ausfuehren |
| [Vitest](https://github.com/vitest-dev/vitest) | Unit-/Integrationstests | Testcode ausfuehren, kein nebenwirkungsfreier Check |
| [Vite](https://github.com/vitejs/vite) | Dev-Server und Build | Nur 127.0.0.1; festen freien Port nutzen |
| [Playwright](https://github.com/microsoft/playwright) | Browser-/E2E-Tests | Browserdownload und RAM/Disk separat freigeben |
| [pnpm](https://github.com/pnpm/pnpm) | JS-Paketverwaltung | Version und Lockfile festlegen, Lifecycle-Skripte pruefen |

Im vorbereiteten Projekt etwa Format-Check, Lint, `tsc --noEmit`, Tests und Build
vereinbaren. Nicht jede package.json bietet dieselben Skriptnamen. Installationen
koennen Netzwerk und Codeausfuehrung ausloesen. Den Node-Debugger niemals
oeffentlich freigeben; Inspector-Zugriff kann Codeausfuehrung ermoeglichen.

## Go

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [Go](https://github.com/golang/go) | Module, Build, Test, vet, Benchmarks | Toolchain/Module pinnen; Downloads und Testcode beachten |
| [golang/tools](https://github.com/golang/tools) | gopls und Editorwerkzeuge | gopls ist ein Teilprojekt, kein eigener Go-Compiler |
| [Delve](https://github.com/go-delve/delve) | Debugging | Zugriff auf Prozessspeicher; kein oeffentlicher Debug-Port |
| [golangci-lint](https://github.com/golangci/golangci-lint) | Zusaetzliche Linter | Version und Regeln zur Go-Version passend festlegen |
| [Actions Checkout](https://github.com/actions/checkout) | CI-Checkout | Workflow-Action, kein lokaler Installer |
| [Actions Setup Go](https://github.com/actions/setup-go) | Go in CI bereitstellen | Kann Laufzeiten laden; keine Freigabe fuer lokale Systeminstallation |

Originaler gopls-Unterordner: [gopls](https://github.com/golang/tools/tree/master/gopls).
`go fmt ./...` schreibt Dateien; `go test ./...` fuehrt Tests aus und kann Module
laden. Race- und Coverage-Laeufe brauchen zusaetzliche Ressourcen und passende
Plattform-/Compilerunterstuetzung. Der private Go-Bootstrap fuer
[Anthropic CLI](../tools/anthropic-cli.md) ist kein allgemeiner globaler Go-Installer.

## C und C++

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [GCC GitHub-Mirror](https://github.com/gcc-mirror/gcc) | Compilerquellen | Mirror, nicht pauschal GitHub als fuehrendes GNU-Repository ausgeben |
| [LLVM](https://github.com/llvm/llvm-project) | Clang, clang-format, clang-tidy, LLDB | Monorepo und potenziell sehr schwerer Build |
| [CMake](https://github.com/kitware/cmake) | Buildsystem und CTest | CMake-Konfiguration kann bereits Programme starten/Dependencies laden |
| [GoogleTest](https://github.com/google/googletest) | C++-Tests | Projektbibliothek, kein globaler Dienst |
| [Catch2](https://github.com/catchorg/Catch2) | Alternative C++-Tests | Lizenz BSL-1.0 bedeutet hier Boost Software License |

GCC nennt als Upstream [gcc.gnu.org/git/gcc.git](https://gcc.gnu.org/git.html).
Ein GitHub-Mirror kann lesbar sein, ersetzt aber keine Release-/Pinpruefung.
Compiler, Sprachstandard, ABI und Zielplattform festlegen; getrennte
Buildverzeichnisse fuer Debug/Release/Sanitizer nutzen. `ctest --test-dir build
--output-on-failure` fuehrt Testprogramme aus. Sanitizer pruefen ausgefuehrte
Pfade, nicht alle moeglichen Fehler. GDB stammt aus dem
[GNU-GDB-Projekt](https://www.gnu.org/software/gdb/), nicht einem hier erfundenen
offiziellen GitHub-Repository. Hardwarezugriffe separat freigeben:
[Embedded Debug HIL](../tools/embedded-debug-hil.md).

## Rust

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [rustup](https://github.com/rust-lang/rustup) | Toolchains verwalten | Kann Compiler/Komponenten laden und Profile veraendern |
| [Cargo](https://github.com/rust-lang/cargo) | Paketverwaltung und Build | build.rs und prozedurale Makros fuehren Code aus |
| [rustfmt](https://github.com/rust-lang/rustfmt) | Formatierung | --check vor schreibender Formatierung |
| [Clippy](https://github.com/rust-lang/rust-clippy) | Rust-Linting | Baut Projektbestandteile; keine reine Textsuche |
| [rust-analyzer](https://github.com/rust-lang/rust-analyzer) | Editor-/Sprachserver | Projekt- und Buildscript-Vertrauen beachten |

Toolchain in rust-toolchain.toml und Dependencies in Cargo.lock festlegen.
`cargo build --locked` verhindert eine unbemerkte Lockfile-Aenderung, **nicht**
Netzwerkzugriff oder Codeausfuehrung. `--offline` verlangt bereits vorhandene
Dependencies. `--all-features` nicht blind aktivieren: Features koennen sich
ausschliessen oder GPU-/Systembibliotheken verlangen. nextest und llvm-cov sind
weitere optionale Ausbauideen, hier ohne neuen Installer oder Laufzeitnachweis.

## Bash

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [ShellCheck](https://github.com/koalaman/shellcheck) | Statische Shellanalyse | Vorhandener Setup-Baustein, keine Funktionsgarantie |
| [shfmt](https://github.com/mvdan/sh) | Shellformatierung | Vorhandener Setup-Baustein; zuerst Diff-/Pruefmodus |
| [Bats-core](https://github.com/bats-core/bats-core) | Verhaltenstests | Tests brauchen Mocks fuer Dateisystem/Netz/Systemaktionen |
| [BashDB](https://github.com/Trepan-Debuggers/bashdb) | Optionaler Debugger | Fuehrt das debuggete Skript aus; nicht nur Syntaxanalyse |

Bash-Upstream ist GNU/Savannah, kein beliebiger GitHub-Fork:
[GNU Bash](https://www.gnu.org/software/bash/). Diese GNU-Seite war beim
Abruf zeitweise nicht erreichbar; kein positiver Live-Erreichbarkeitsnachweis.
`bash -n` prueft Syntax ohne das Skript auszufuehren. `bash -x` fuehrt es dagegen
aus und kann expandierte Secrets protokollieren. ShellCheck-/shfmt-Hooks sind
bereits in unserer [.pre-commit-config.yaml](../../.pre-commit-config.yaml)
konfiguriert; das ist kein Nachweis fuer aktivierte oder installierte Hooks.

## PowerShell

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [PowerShell](https://github.com/PowerShell/PowerShell) | Plattformuebergreifende Shell | PowerShell 7+ nicht mit Windows PowerShell 5.1 gleichsetzen |
| [VS-Code-PowerShell](https://github.com/PowerShell/vscode-powershell) | Editor und Debugging | Optionale Erweiterung, keine Pflicht fuer Coding-Agenten |
| [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) | Statische Regeln | Version und Regelsatz projektbezogen festlegen |
| [Pester](https://github.com/pester/Pester) | Tests und Mocks | Skripte/Module ausfuehren; Seiteneffekte mocken |
| [Invoke-Build](https://github.com/nightroman/Invoke-Build) | Optionale Buildablaeufe | Build-Tasks koennen echte Systemaenderungen enthalten |

`pwsh -NoProfile -File` verhindert das Laden persoenlicher Shellprofile,
**nicht** die Nebenwirkungen des Skripts. Analyzer, Pester und Module bleiben
separat freizugebende Dependencies. Kein ExecutionPolicy-Bypass oder automatischer
Moduldownload. Insbesondere keine WSL-Aufrufe aus Windows heraus durch diese Doku.

## SQL und Datenbanken

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [PostgreSQL GitHub-Mirror](https://github.com/postgres/postgres) | DBMS/psql-Quellen | Mirror; kein automatisch gestarteter Datenbankdienst |
| [Flyway](https://github.com/flyway/flyway) | Schema-Migrationen | Editionen/Module getrennt lizenzieren; Migrationen veraendern Datenbanken |
| [SQLFluff](https://github.com/sqlfluff/sqlfluff) | SQL-Linting/Formatierung | Dialekt und Templater festlegen; Plugins/Templater pruefen |
| [dbt Core](https://github.com/dbt-labs/dbt-core) | Analytische Datenmodelle | Adresse leitet aktuell auf dbt-labs/dbt weiter; Layout/Paketpfad am Pin pruefen |
| [pgTAP](https://github.com/theory/pgtap) | PostgreSQL-nahe Tests | Extension/Testinstallation und DB-Rechte separat freigeben |

PostgreSQL nennt [git.postgresql.org](https://www.postgresql.org/docs/current/git.html)
fuer seinen offiziellen Git-Zugang. Der GitHub-Mirror ist keine eigenstaendige
Quelle fuer Contributions per GitHub-PR. Aktuelles dbt-Ziel:
[dbt-labs/dbt](https://github.com/dbt-labs/dbt). Die Weiterleitung ist kein Grund,
den vorhandenen Installer ohne Pin-/Layouttests auf main umzustellen.

Nur frische freigegebene Testdatenbanken mit synthetischen Daten verwenden.
`EXPLAIN ANALYZE` **fuehrt die SQL-Anweisung aus**, einschliesslich moeglicher
Schreiboperationen. Ein ROLLBACK ist kein universeller Schutz vor allen
Nebenwirkungen. Quelle: [PostgreSQL EXPLAIN](https://www.postgresql.org/docs/current/sql-explain.html).
Migrationen, Locks, DDL-Transaktionen, Backup und Restore sind je DBMS zu planen.

## Docker und Container: Referenz, keine Installation

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [Docker CLI](https://github.com/docker/cli) | Container-Bedienung | CLI allein ist kein Daemon; kein Socket-Zugriff hier |
| [Compose](https://github.com/docker/compose) | Dienstkonfiguration | Kein automatisches compose up/down |
| [Buildx](https://github.com/docker/buildx) | Erweiterte Builds | Kann Builder anlegen und Ressourcen verbrauchen |
| [BuildKit](https://github.com/moby/buildkit) | Buildengine | Build-Daemon und Buildcode brauchen eigene Freigabe |
| [Hadolint](https://github.com/hadolint/hadolint) | Dockerfile-Linting | Quell-/Binary-Nutzung ohne Docker moeglich, hier kein Installer |
| [Setup Buildx Action](https://github.com/docker/setup-buildx-action) | Builder in CI vorbereiten | Keine neue Workflow-Aktivierung |
| [Build Push Action](https://github.com/docker/build-push-action) | Images bauen/veroeffentlichen | Push und Registry-Zugriff separat freigeben |
| [Login Action](https://github.com/docker/login-action) | Registry-Anmeldung | Keine Anmeldung oder Schluesselverwendung hier |

**Deine Vorgabe bleibt: GitHub statt Docker fuer neue Tool-Installationen.**
Diese Quellen dienen nur dem Verstehen/Pruefen vorhandener Containerprojekte.
Docker CLI/Engine sind nicht Docker Desktop; Desktop-Nutzungsbedingungen nicht
aus der CLI-Lizenz ableiten. Keine Daemon-, Gruppen-, Socket- oder Firewall-
Aenderung. Compose-Konfigurationsausgaben koennen interpolierte Secrets zeigen;
keine ungefilterten Logs. Build-Secrets nicht als ARG oder Image-Layer ablegen.

## Kubernetes

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [kubectl](https://github.com/kubernetes/kubectl) | Clusterverwaltung | Issue-Tracker/Code-Mirror; Source-Build nicht pauschal aus diesem Root ableiten |
| [kind](https://github.com/kubernetes-sigs/kind) | Lokale/CI-Testcluster | Braucht Container-Runtime und Node-Images; kein Docker-freier Kubernetes-Ersatz |
| [Helm](https://github.com/helm/helm) | Charts rendern/verwalten | Vorhandener Setup-Eintrag; Rendern von Installieren unterscheiden |
| [Kustomize](https://github.com/kubernetes-sigs/kustomize) | Manifeste zusammensetzen | Vorhandener Setup-Eintrag; Remote-Basen/Plugins gesondert pruefen |
| [Kubeconform](https://github.com/yannh/kubeconform) | Schemapruefung | Schemaquellen/Downloads pinnen; keine Laufzeitgarantie |
| [KubeLinter](https://github.com/stackrox/kube-linter) | Manifestregeln | Keine vollstaendige Cluster-/Security-Pruefung |
| [Skaffold](https://github.com/GoogleContainerTools/skaffold) | Build-/Deploy-Schleifen | Deployment ist nicht automatisch freigegeben |
| [Argo CD](https://github.com/argoproj/argo-cd) | GitOps | CLI-Eintrag vorhanden; Controller/Sync separat freigeben |
| [Flux](https://github.com/fluxcd/flux2) | Alternative GitOps-Implementierung | CLI-Eintrag vorhanden; kein automatisches Bootstrap/Sync |

Helm oder Kustomize passend zum Projekt waehlen; Argo CD/Flux nicht ungeprueft
beide als Controller fuer dieselben Ressourcen einsetzen. kind kann laut
[Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/) Container-Runtimes
verwenden; ein aus GitHub gebautes kind macht die Node-Images nicht entbehrlich.
Hier wird kein Cluster angelegt oder geloescht.

Vor Clusteraktionen Kontext, Namespace, RBAC, Kosten und Datenbestand pruefen.
`kubectl apply --dry-run=server` **kontaktiert den API-Server**, ist also kein
Offline-Check. Auch `kubectl diff` kann serverseitige Verarbeitung anfordern.
Quelle: [kubectl apply](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_apply/).
`exec`, `debug`, GitOps-Sync und Deployments sind eigene Freigabeschritte.

## Terraform und IaC

| Quelle | Nutzen | Einsatz / Grenze |
|---|---|---|
| [Terraform](https://github.com/hashicorp/terraform) | Infrastruktur deklarieren | Business Source License; nicht pauschal Open Source nennen |
| [Terraform Language Server](https://github.com/hashicorp/terraform-ls) | Editorunterstuetzung | Separates Projekt, Lizenz am gewaehlten Pin pruefen |
| [TFLint](https://github.com/terraform-linters/tflint) | IaC-Regeln | Plugins/Provider koennen Downloads/Codeausfuehrung bedeuten |
| [Checkov](https://github.com/bridgecrewio/checkov) | IaC-Sicherheitschecks | Lokal konfigurieren; Cloud-/Upload-Funktionen nicht implizit freigeben |
| [terraform-docs](https://github.com/terraform-docs/terraform-docs) | Moduldokumentation | Schreibende Ausgabe bewusst aktivieren |
| [Terratest](https://github.com/gruntwork-io/terratest) | Infrastruktur-Integrationstests | Kann reale Ressourcen, Kosten und Cleanup verursachen |
| [Setup Terraform Action](https://github.com/hashicorp/setup-terraform) | Laufzeit in CI | Keine lokale Terraform-Installation oder CI-Aktivierung hier |

**Lizenzgrenze:** Die aktuelle [Terraform-Lizenz](https://github.com/hashicorp/terraform/blob/main/LICENSE)
enthaelt die **Business Source License 1.1** mit Nutzungsbedingungen. Das ist
nicht dieselbe Lizenz wie die **Boost Software License 1.0** von Catch2, obwohl
beide gelegentlich als BSL abgekuerzt werden. Fuer einen quelloffenen Ansatz
ist [OpenTofu](https://github.com/opentofu/opentofu) unter
[MPL-2.0](https://github.com/opentofu/opentofu/blob/main/LICENSE) eine Alternative
mit vorhandenem Setup-Eintrag. Keine automatische State-/Provider-Migration.

`init` kann Provider/Module laden; `plan` kann Provider und Datenquellen
kontaktieren. Auch `terraform test` ist nicht generell kostenlos oder ohne
Seiteneffekt: Tests koennen Ressourcen erstellen. `apply`/`destroy` nur mit
separater Freigabe in geschuetzten Umgebungen. Versionen und Lockfiles pinnen;
State, Plan, Logs und Reports koennen sensible Daten enthalten.

## Prioritaeten fuer unser Setup

Zuerst vorhandene ShellCheck-/shfmt-Pruefungen und die dokumentierten Python-
Werkzeuge nutzen. JS-Projekte profitieren projektlokal von ESLint/Prettier/
Vitest; keine globale Pflichtinstallation. Pester/PSScriptAnalyzer sind fuer
eigene Windows-Skripte interessante Ausbaukandidaten. C/C++/Rust nur fuer ein
konkretes Source-Build-Projekt, SQL nur mit separater Testdatenbank. Container,
Cluster und Cloud zuletzt und mit eigenem Ressourcen-/Kostenbudget.

Bei spaeteren Installern: gepruefter GitHub-Pin, Zielarchitektur, Lizenz,
Dependencies, Dry-Run, aktuelles Log, Disk-/Hostreserve, Lock, belastbarer
Installed-Status und Rollback. Schwere Builds seriell ueber die vorhandene
[Queue](../CODEX_TASK_QUEUE.md); sie ist keine harte Ressourcen-Sandbox.
Automaton/OpenClaw erhalten dadurch weder Cloud-/Wallet-/Hardware-Rechte noch
die Erlaubnis, ihre Toolchains eigenmaechtig zu installieren.

Weiter: [Erster Quellenkatalog](manus-development-sources.md),
[Lokaler Entwicklungsablauf](manus-development-workflow.md),
[Black und mypy](../tools/dev-quality.md).
