# Werkzeuge fuer Sprachen, Shells und Infrastruktur

Stand: 21.10.2026. Alle **62 Quellen** sind ueber Hauptmenue **16: installieren / verwalten**
oder die Schaltflaeche **62 Quellen verwalten** erreichbar.
[Bedienung, Grenzen und Logs](tools/development-toolchain-check.md),
[maschinenlesbare Rezepte](../config/development_installers.json).

**52 neue private Build-/Paketrezepte und zehn weiterverwendete Adapter.**
Keine Installation wurde auf deiner WSL ausgefuehrt. Neue Rezepte sind experimentell;
Offline-/Mocktests sind keine 62 erfolgreichen Upstream-Livebuilds.
CI-Actions sind lokale Pakete mit gepinnter Referenz, keine gestarteten Programme;
Bibliotheken/Module/VSIX werden nicht automatisch in Zielprojekte/Editoren aktiviert.

## Vollstaendige Tabelle

| Bereich | Werkzeug / offizielle Quelle | Zweck | Installationsweg im neuen Einstieg |
|---|---|---|---|
| JavaScript und TypeScript | [Node.js](https://github.com/nodejs/node) | JS-Laufzeit | Neues Rezept `native-build`: `--tool node_js` |
| JavaScript und TypeScript | [TypeScript](https://github.com/microsoft/TypeScript) | Typen und Build | Neues Rezept `node-package`: `--tool typescript` |
| JavaScript und TypeScript | [Prettier](https://github.com/prettier/prettier) | Formatierung | Neues Rezept `node-package`: `--tool prettier` |
| JavaScript und TypeScript | [ESLint](https://github.com/eslint/eslint) | Statische Regeln | Neues Rezept `node-package`: `--tool eslint` |
| JavaScript und TypeScript | [Vitest](https://github.com/vitest-dev/vitest) | Unit-/Integrationstests | Neues Rezept `node-package`: `--tool vitest` |
| JavaScript und TypeScript | [Vite](https://github.com/vitejs/vite) | Dev-Server und Build | Neues Rezept `node-package`: `--tool vite` |
| JavaScript und TypeScript | [Playwright](https://github.com/microsoft/playwright) | Browser-/E2E-Tests | Neues Rezept `node-package`: `--tool playwright` |
| JavaScript und TypeScript | [pnpm](https://github.com/pnpm/pnpm) | JS-Paketverwaltung | Neues Rezept `node-package`: `--tool pnpm` |
| Go | [Go](https://github.com/golang/go) | Module, Build, Test, vet, Benchmarks | Neues Rezept `toolchain-build`: `--tool go` |
| Go | [golang/tools](https://github.com/golang/tools) | gopls und Editorwerkzeuge | Vorhandener privater Adapter: [gopls](../scripts/tools/gopls_install.sh) |
| Go | [Delve](https://github.com/go-delve/delve) | Debugging | Vorhandener privater Adapter: [delve](../scripts/tools/delve_install.sh) |
| Go | [golangci-lint](https://github.com/golangci/golangci-lint) | Zusaetzliche Linter | Vorhandener privater Adapter: [golangci_lint](../scripts/tools/golangci_lint_install.sh) |
| Go | [Actions Checkout](https://github.com/actions/checkout) | CI-Checkout | Neues Rezept `workflow-package`: `--tool actions_checkout` |
| Go | [Actions Setup Go](https://github.com/actions/setup-go) | Go in CI bereitstellen | Neues Rezept `workflow-package`: `--tool actions_setup_go` |
| C und C++ | [GCC GitHub-Mirror](https://github.com/gcc-mirror/gcc) | Compilerquellen | Neues Rezept `native-build`: `--tool gcc_github_mirror` |
| C und C++ | [LLVM](https://github.com/llvm/llvm-project) | Clang, clang-format, clang-tidy, LLDB | Neues Rezept `native-build`: `--tool llvm` |
| C und C++ | [CMake](https://github.com/kitware/cmake) | Buildsystem und CTest | Neues Rezept `native-build`: `--tool cmake` |
| C und C++ | [GoogleTest](https://github.com/google/googletest) | C++-Tests | Neues Rezept `native-build`: `--tool googletest` |
| C und C++ | [Catch2](https://github.com/catchorg/Catch2) | Alternative C++-Tests | Neues Rezept `native-build`: `--tool catch2` |
| Rust | [rustup](https://github.com/rust-lang/rustup) | Toolchains verwalten | Neues Rezept `cargo-build`: `--tool rustup` |
| Rust | [Cargo](https://github.com/rust-lang/cargo) | Paketverwaltung und Build | Neues Rezept `cargo-build`: `--tool cargo` |
| Rust | [rustfmt](https://github.com/rust-lang/rustfmt) | Formatierung | Neues Rezept `cargo-build`: `--tool rustfmt` |
| Rust | [Clippy](https://github.com/rust-lang/rust-clippy) | Rust-Linting | Neues Rezept `cargo-build`: `--tool clippy` |
| Rust | [rust-analyzer](https://github.com/rust-lang/rust-analyzer) | Editor-/Sprachserver | Neues Rezept `cargo-build`: `--tool rust_analyzer` |
| Bash | [ShellCheck](https://github.com/koalaman/shellcheck) | Statische Shellanalyse | Neues Rezept `haskell-build`: `--tool shellcheck` |
| Bash | [shfmt](https://github.com/mvdan/sh) | Shellformatierung | Neues Rezept `go-build`: `--tool shfmt` |
| Bash | [Bats-core](https://github.com/bats-core/bats-core) | Verhaltenstests | Vorhandener privater Adapter: [bats_core](../scripts/tools/bats_core_install.sh) |
| Bash | [BashDB](https://github.com/Trepan-Debuggers/bashdb) | Optionaler Debugger | Neues Rezept `native-build`: `--tool bashdb` |
| PowerShell | [PowerShell](https://github.com/PowerShell/PowerShell) | Plattformuebergreifende Shell | Neues Rezept `powershell-build`: `--tool powershell` |
| PowerShell | [VS-Code-PowerShell](https://github.com/PowerShell/vscode-powershell) | Editor und Debugging | Neues Rezept `editor-package`: `--tool vs_code_powershell` |
| PowerShell | [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) | Statische Regeln | Neues Rezept `powershell-module`: `--tool psscriptanalyzer` |
| PowerShell | [Pester](https://github.com/pester/Pester) | Tests und Mocks | Neues Rezept `powershell-module`: `--tool pester` |
| PowerShell | [Invoke-Build](https://github.com/nightroman/Invoke-Build) | Optionale Buildablaeufe | Vorhandener privater Adapter: [invoke_build](../scripts/tools/invoke_build_install.sh) |
| SQL und Datenbanken | [PostgreSQL GitHub-Mirror](https://github.com/postgres/postgres) | DBMS/psql-Quellen | Neues Rezept `native-build`: `--tool postgres` |
| SQL und Datenbanken | [Flyway](https://github.com/flyway/flyway) | Schema-Migrationen | Neues Rezept `java-package`: `--tool flyway` |
| SQL und Datenbanken | [SQLFluff](https://github.com/sqlfluff/sqlfluff) | SQL-Linting/Formatierung | Vorhandener privater Adapter: [sqlfluff](../scripts/tools/sqlfluff_install.sh) |
| SQL und Datenbanken | [dbt Core](https://github.com/dbt-labs/dbt-core) | Analytische Datenmodelle | Neues Rezept `python-package`: `--tool dbt` |
| SQL und Datenbanken | [pgTAP](https://github.com/theory/pgtap) | PostgreSQL-nahe Tests | Neues Rezept `postgres-extension-package`: `--tool pgtap` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [Docker CLI](https://github.com/docker/cli) | Container-Bedienung | Neues Rezept `go-build`: `--tool docker_cli` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [Compose](https://github.com/docker/compose) | Dienstkonfiguration | Neues Rezept `go-build`: `--tool compose` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [Buildx](https://github.com/docker/buildx) | Erweiterte Builds | Neues Rezept `go-build`: `--tool buildx` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [BuildKit](https://github.com/moby/buildkit) | Buildengine | Neues Rezept `go-build`: `--tool buildkit` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [Hadolint](https://github.com/hadolint/hadolint) | Dockerfile-Linting | Neues Rezept `haskell-build`: `--tool hadolint` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [Setup Buildx Action](https://github.com/docker/setup-buildx-action) | Builder in CI vorbereiten | Neues Rezept `workflow-package`: `--tool setup_buildx_action` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [Build Push Action](https://github.com/docker/build-push-action) | Images bauen/veroeffentlichen | Neues Rezept `workflow-package`: `--tool build_push_action` |
| Docker und Container: private Werkzeuge ohne Daemonstart | [Login Action](https://github.com/docker/login-action) | Registry-Anmeldung | Neues Rezept `workflow-package`: `--tool login_action` |
| Kubernetes | [kubectl](https://github.com/kubernetes/kubectl) | Clusterverwaltung | Neues Rezept `native-build`: `--tool kubectl` |
| Kubernetes | [kind](https://github.com/kubernetes-sigs/kind) | Lokale/CI-Testcluster | Neues Rezept `go-build`: `--tool kind` |
| Kubernetes | [Helm](https://github.com/helm/helm) | Charts rendern/verwalten | Neues Rezept `go-build`: `--tool helm` |
| Kubernetes | [Kustomize](https://github.com/kubernetes-sigs/kustomize) | Manifeste zusammensetzen | Neues Rezept `go-build`: `--tool kustomize` |
| Kubernetes | [Kubeconform](https://github.com/yannh/kubeconform) | Schemapruefung | Vorhandener privater Adapter: [kubeconform](../scripts/tools/kubeconform_install.sh) |
| Kubernetes | [KubeLinter](https://github.com/stackrox/kube-linter) | Manifestregeln | Vorhandener privater Adapter: [kubelinter](../scripts/tools/kubelinter_install.sh) |
| Kubernetes | [Skaffold](https://github.com/GoogleContainerTools/skaffold) | Build-/Deploy-Schleifen | Neues Rezept `go-build`: `--tool skaffold` |
| Kubernetes | [Argo CD](https://github.com/argoproj/argo-cd) | GitOps | Neues Rezept `go-build`: `--tool argocd_cli` |
| Kubernetes | [Flux](https://github.com/fluxcd/flux2) | Alternative GitOps-Implementierung | Neues Rezept `go-build`: `--tool flux_cli` |
| Terraform und IaC | [Terraform](https://github.com/hashicorp/terraform) | Infrastruktur deklarieren | Neues Rezept `go-build`: `--tool terraform` |
| Terraform und IaC | [Terraform Language Server](https://github.com/hashicorp/terraform-ls) | Editorunterstuetzung | Neues Rezept `go-build`: `--tool terraform_language_server` |
| Terraform und IaC | [TFLint](https://github.com/terraform-linters/tflint) | IaC-Regeln | Vorhandener privater Adapter: [tflint](../scripts/tools/tflint_install.sh) |
| Terraform und IaC | [Checkov](https://github.com/bridgecrewio/checkov) | IaC-Sicherheitschecks | Neues Rezept `python-package`: `--tool checkov` |
| Terraform und IaC | [terraform-docs](https://github.com/terraform-docs/terraform-docs) | Moduldokumentation | Vorhandener privater Adapter: [terraform_docs](../scripts/tools/terraform_docs_install.sh) |
| Terraform und IaC | [Terratest](https://github.com/gruntwork-io/terratest) | Infrastruktur-Integrationstests | Neues Rezept `go-library`: `--tool terratest` |
| Terraform und IaC | [Setup Terraform Action](https://github.com/hashicorp/setup-terraform) | Laufzeit in CI | Neues Rezept `workflow-package`: `--tool setup_terraform_action` |

## Besondere Grenzen

kubectl wird aus `kubernetes/kubernetes` gebaut, nicht aus dem Code-Mirror.
Der neue PostgreSQL-Weg ist ein privater Source-Build ohne DB-Initialisierung;
der bisherige systemweite apt-Installer bleibt davon getrennt.
Terraform hat eine Business Source License; Catch2s BSL-1.0 ist dagegen die
Boost Software License. Lizenzen und Voraussetzungen vor dem Build pruefen.

Die [Offline-Vorpruefung](tools/development-toolchain-check.md) erzeugt keinen
Installed-Marker. Der neue Installer tut dies erst nach erfolgreichen
Buildschritten und Artefaktpruefung. Zielhost, Compiler-/SDK-Versionen und
Upstream-Aenderungen koennen einen echten Build weiterhin scheitern lassen.

