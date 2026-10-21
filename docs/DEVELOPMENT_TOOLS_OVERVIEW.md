# Werkzeuge fuer Sprachen, Shells und Infrastruktur

Stand: 21.10.2026. **Alle 62 Quellen aus der Nutzer-Uebersicht** stehen hier
mit ihrem konkreten Setup-Weg. Diese Tabelle ist die zentrale lesbare
Ergaenzung zum [Pruefkatalog](../config/development_toolchains.json).

## Direkt im Setup pruefen

Hauptmenue **16** oder Tools-Menue **8**, Schaltflaeche **62 Quellen pruefen**.
[Bedienung und Ergebnislegende](tools/development-toolchain-check.md).
Die Vorpruefung fuehrt keine Installation, keinen Toolstart und keine
Netzwerkabfrage aus. Sie bestaetigt weder Build noch Laufzeitfunktion.

**Zehn neu ergaenzte optionale Installer:**
[SQLFluff, Bats_Core, Invoke_Build](tools/language-quality-tools.md) sowie
[Gopls, Delve, GolangCI_Lint, Kubeconform, KubeLinter, TFLint und Terraform_Docs](tools/development-go-tools.md).
Pins, Go-Minima, Buildpfade, Status und Deinstallation sind dokumentiert.
Die neuen Go-Builds sind ohne Docker; zwei schwere Builds erfordern Opt-in.
Kein Livebuild wurde auf dem Nutzerhost ausgefuehrt.

## Vollstaendige Tabelle

| Bereich | Werkzeug / offizielle Quelle | Zweck | Stand und Einstieg |
|---|---|---|---|
| JavaScript und TypeScript | [Node.js](https://github.com/nodejs/node) | JS-Laufzeit | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| JavaScript und TypeScript | [TypeScript](https://github.com/microsoft/TypeScript) | Typen und Build | Projektabhaengigkeit; im Zielprojekt pinnen |
| JavaScript und TypeScript | [Prettier](https://github.com/prettier/prettier) | Formatierung | Projektabhaengigkeit; im Zielprojekt pinnen |
| JavaScript und TypeScript | [ESLint](https://github.com/eslint/eslint) | Statische Regeln | Projektabhaengigkeit; im Zielprojekt pinnen |
| JavaScript und TypeScript | [Vitest](https://github.com/vitest-dev/vitest) | Unit-/Integrationstests | Projektabhaengigkeit; im Zielprojekt pinnen |
| JavaScript und TypeScript | [Vite](https://github.com/vitejs/vite) | Dev-Server und Build | Projektabhaengigkeit; im Zielprojekt pinnen |
| JavaScript und TypeScript | [Playwright](https://github.com/microsoft/playwright) | Browser-/E2E-Tests | Vorhandener Adapter, gesondert pruefen: [playwright](../scripts/tools/playwright_install.sh) |
| JavaScript und TypeScript | [pnpm](https://github.com/pnpm/pnpm) | JS-Paketverwaltung | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Go | [Go](https://github.com/golang/go) | Module, Build, Test, vet, Benchmarks | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Go | [golang/tools](https://github.com/golang/tools) | gopls und Editorwerkzeuge | Neuer Build-/Skriptinstaller: [gopls](../scripts/tools/gopls_install.sh) |
| Go | [Delve](https://github.com/go-delve/delve) | Debugging | Neuer Build-/Skriptinstaller: [delve](../scripts/tools/delve_install.sh) |
| Go | [golangci-lint](https://github.com/golangci/golangci-lint) | Zusaetzliche Linter | Neuer Build-/Skriptinstaller: [golangci_lint](../scripts/tools/golangci_lint_install.sh) |
| Go | [Actions Checkout](https://github.com/actions/checkout) | CI-Checkout | CI-Action; im Projekt einsetzen, kein lokaler Installer |
| Go | [Actions Setup Go](https://github.com/actions/setup-go) | Go in CI bereitstellen | CI-Action; im Projekt einsetzen, kein lokaler Installer |
| C und C++ | [GCC GitHub-Mirror](https://github.com/gcc-mirror/gcc) | Compilerquellen | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| C und C++ | [LLVM](https://github.com/llvm/llvm-project) | Clang, clang-format, clang-tidy, LLDB | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| C und C++ | [CMake](https://github.com/kitware/cmake) | Buildsystem und CTest | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| C und C++ | [GoogleTest](https://github.com/google/googletest) | C++-Tests | Projektabhaengigkeit; im Zielprojekt pinnen |
| C und C++ | [Catch2](https://github.com/catchorg/Catch2) | Alternative C++-Tests | Projektabhaengigkeit; im Zielprojekt pinnen |
| Rust | [rustup](https://github.com/rust-lang/rustup) | Toolchains verwalten | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Rust | [Cargo](https://github.com/rust-lang/cargo) | Paketverwaltung und Build | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Rust | [rustfmt](https://github.com/rust-lang/rustfmt) | Formatierung | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Rust | [Clippy](https://github.com/rust-lang/rust-clippy) | Rust-Linting | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Rust | [rust-analyzer](https://github.com/rust-lang/rust-analyzer) | Editor-/Sprachserver | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Bash | [ShellCheck](https://github.com/koalaman/shellcheck) | Statische Shellanalyse | Vorhandener Adapter, gesondert pruefen: [shellcheck](../scripts/tools/shellcheck_install.sh) |
| Bash | [shfmt](https://github.com/mvdan/sh) | Shellformatierung | Vorhandener Adapter, gesondert pruefen: [shfmt](../scripts/tools/shfmt_install.sh) |
| Bash | [Bats-core](https://github.com/bats-core/bats-core) | Verhaltenstests | Neuer Build-/Skriptinstaller: [bats_core](../scripts/tools/bats_core_install.sh) |
| Bash | [BashDB](https://github.com/Trepan-Debuggers/bashdb) | Optionaler Debugger | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| PowerShell | [PowerShell](https://github.com/PowerShell/PowerShell) | Plattformuebergreifende Shell | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| PowerShell | [VS-Code-PowerShell](https://github.com/PowerShell/vscode-powershell) | Editor und Debugging | Editor-Erweiterung; separat aktivieren |
| PowerShell | [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) | Statische Regeln | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| PowerShell | [Pester](https://github.com/pester/Pester) | Tests und Mocks | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| PowerShell | [Invoke-Build](https://github.com/nightroman/Invoke-Build) | Optionale Buildablaeufe | Neuer Build-/Skriptinstaller: [invoke_build](../scripts/tools/invoke_build_install.sh) |
| SQL und Datenbanken | [PostgreSQL GitHub-Mirror](https://github.com/postgres/postgres) | DBMS/psql-Quellen | Vorhandener Adapter, gesondert pruefen: [postgres](../scripts/tools/postgres_install.sh) |
| SQL und Datenbanken | [Flyway](https://github.com/flyway/flyway) | Schema-Migrationen | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| SQL und Datenbanken | [SQLFluff](https://github.com/sqlfluff/sqlfluff) | SQL-Linting/Formatierung | Neuer Build-/Skriptinstaller: [sqlfluff](../scripts/tools/sqlfluff_install.sh) |
| SQL und Datenbanken | [dbt Core](https://github.com/dbt-labs/dbt-core) | Analytische Datenmodelle | Vorhandener Adapter, gesondert pruefen: [dbt](../scripts/tools/dbt_install.sh) |
| SQL und Datenbanken | [pgTAP](https://github.com/theory/pgtap) | PostgreSQL-nahe Tests | Projektabhaengigkeit; im Zielprojekt pinnen |
| Docker und Container: Referenz, keine Installation | [Docker CLI](https://github.com/docker/cli) | Container-Bedienung | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Docker und Container: Referenz, keine Installation | [Compose](https://github.com/docker/compose) | Dienstkonfiguration | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Docker und Container: Referenz, keine Installation | [Buildx](https://github.com/docker/buildx) | Erweiterte Builds | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Docker und Container: Referenz, keine Installation | [BuildKit](https://github.com/moby/buildkit) | Buildengine | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Docker und Container: Referenz, keine Installation | [Hadolint](https://github.com/hadolint/hadolint) | Dockerfile-Linting | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Docker und Container: Referenz, keine Installation | [Setup Buildx Action](https://github.com/docker/setup-buildx-action) | Builder in CI vorbereiten | CI-Action; im Projekt einsetzen, kein lokaler Installer |
| Docker und Container: Referenz, keine Installation | [Build Push Action](https://github.com/docker/build-push-action) | Images bauen/veroeffentlichen | CI-Action; im Projekt einsetzen, kein lokaler Installer |
| Docker und Container: Referenz, keine Installation | [Login Action](https://github.com/docker/login-action) | Registry-Anmeldung | CI-Action; im Projekt einsetzen, kein lokaler Installer |
| Kubernetes | [kubectl](https://github.com/kubernetes/kubectl) | Clusterverwaltung | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Kubernetes | [kind](https://github.com/kubernetes-sigs/kind) | Lokale/CI-Testcluster | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Kubernetes | [Helm](https://github.com/helm/helm) | Charts rendern/verwalten | Vorhandener Adapter, gesondert pruefen: [helm](../scripts/tools/helm_install.sh) |
| Kubernetes | [Kustomize](https://github.com/kubernetes-sigs/kustomize) | Manifeste zusammensetzen | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Kubernetes | [Kubeconform](https://github.com/yannh/kubeconform) | Schemapruefung | Neuer Build-/Skriptinstaller: [kubeconform](../scripts/tools/kubeconform_install.sh) |
| Kubernetes | [KubeLinter](https://github.com/stackrox/kube-linter) | Manifestregeln | Neuer Build-/Skriptinstaller: [kubelinter](../scripts/tools/kubelinter_install.sh) |
| Kubernetes | [Skaffold](https://github.com/GoogleContainerTools/skaffold) | Build-/Deploy-Schleifen | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Kubernetes | [Argo CD](https://github.com/argoproj/argo-cd) | GitOps | Vorhandener Adapter, gesondert pruefen: [argocd_cli](../scripts/tools/argocd_cli_install.sh) |
| Kubernetes | [Flux](https://github.com/fluxcd/flux2) | Alternative GitOps-Implementierung | Vorhandener Adapter, gesondert pruefen: [flux_cli](../scripts/tools/flux_cli_install.sh) |
| Terraform und IaC | [Terraform](https://github.com/hashicorp/terraform) | Infrastruktur deklarieren | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Terraform und IaC | [Terraform Language Server](https://github.com/hashicorp/terraform-ls) | Editorunterstuetzung | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Terraform und IaC | [TFLint](https://github.com/terraform-linters/tflint) | IaC-Regeln | Neuer Build-/Skriptinstaller: [tflint](../scripts/tools/tflint_install.sh) |
| Terraform und IaC | [Checkov](https://github.com/bridgecrewio/checkov) | IaC-Sicherheitschecks | Kein fertiger Setup-Installer; Voraussetzungen im Pruefkatalog sichtbar |
| Terraform und IaC | [terraform-docs](https://github.com/terraform-docs/terraform-docs) | Moduldokumentation | Neuer Build-/Skriptinstaller: [terraform_docs](../scripts/tools/terraform_docs_install.sh) |
| Terraform und IaC | [Terratest](https://github.com/gruntwork-io/terratest) | Infrastruktur-Integrationstests | Projektabhaengigkeit; im Zielprojekt pinnen |
| Terraform und IaC | [Setup Terraform Action](https://github.com/hashicorp/setup-terraform) | Laufzeit in CI | CI-Action; im Projekt einsetzen, kein lokaler Installer |

## Nach einem Programmabbruch

Die Dateien liegen versionierbar im Windows-Arbeitsverzeichnis; die
Pruefansicht erzeugt keine Installed-Marker. Ein Dateiname in dieser Tabelle
oder eine bestandene Vorpruefung bedeutet nicht, dass ein Tool gebaut wurde.
Bei den neuen Installern unterscheiden Marker und Doctor zwischen Dateien,
erfolgreicher Vorbereitung und einem noch nicht getesteten Anwendungslauf.

Die [Praesentation](presentations/technology-tooling-overview.pptx) ist bereits
im Repository; die [13 Folien sind dem Setup textlich zugeordnet](tools/development-toolchain-check.md#praesentation-mit-eingearbeitet).
CI-/Deployment-Beispiele bleiben inaktiv. Keine Docker-/WSL-/Cloud-Aktion
ist durch das Lesen dieser Uebersicht freigegeben.

## Was noch offen bleibt

Compiler-/Runtime-Bootstraps, Plattform-/Lizenzsonderfaelle und weitere
CLI-Builds ohne fertigen Adapter sind in der Tabelle offen ausgewiesen.
Workflow-Actions und Projektbibliotheken erhalten nicht nur zur Vervollstaendigung
einer Zahl fingierte globale Installer. Diese Tabelle behauptet deshalb nicht,
dass bereits 62 vollstaendige Installationsrezepte oder Livebuilds vorliegen.

