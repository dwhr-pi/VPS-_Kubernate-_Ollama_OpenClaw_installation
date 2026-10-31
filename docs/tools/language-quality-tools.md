# Optionale Sprach- und Qualitaetswerkzeuge aus GitHub

## Zweck und Installation

Aus dem [Katalog mit 62 Quellen](../tutorials/manus-language-infrastructure-sources.md) sind drei
weitere eigenstaendige Tools im Setup-Menue nutzbar. Sie werden nicht nur als geplante Kandidaten
angezeigt: Die Installer bereiten SQLFluff in einem privaten venv beziehungsweise die direkt
nutzbaren Bats-/Invoke-Build-Skripte vor. **Optional / experimental**, keine Standardinstallation.
Kein Docker.

| Tool         | Zweck                              | Offizielle Quelle / fester Stand                                                                                                         | Voraussetzungen / Reserve                                                  |
| ------------ | ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| SQLFluff     | SQL linten und bewusst formatieren | [sqlfluff/sqlfluff, 3.5.0](https://github.com/sqlfluff/sqlfluff/tree/7f5ad66db2fe906827280fd6dfef6eb83565b4e8), MIT                      | Python 3.10-3.13 mit venv/ensurepip/SSL, Git; 2 GiB Disk                   |
| Bats_Core    | Bash-Verhaltenstests               | [bats-core/bats-core, 1.13.0](https://github.com/bats-core/bats-core/tree/3bca150ec86275d6d9d5a4fd7d48ab8b6c6f3d87), MIT                 | Python 3.10+, Git, vorhandenes Bash >=3.2 samt Unix-Werkzeugen; 1 GiB Disk |
| Invoke_Build | PowerShell-Buildablaeufe           | [nightroman/Invoke-Build, 5.14.22](https://github.com/nightroman/Invoke-Build/tree/920dec6a3eba26cf41e5adb4d9d99d8865d6dfb0), Apache-2.0 | Python 3.10+, Git, vorhandenes PowerShell 7 (`pwsh`); 1 GiB Disk           |

Zielhosts: Linux/MiniPC, macOS und bewusst vom Nutzer gestartetes WSL; Invoke-Build/SQLFluff auch
Windows nativ. Bats braucht dort eine geeignete Bash-/Unix-Umgebung, etwa Git Bash; reine
Windows-PowerShell ist kein Bash-Ersatz. Kein GPU-, Kubernetes- oder Cloud-Bedarf. Skriptinstaller
pruefen mindestens 256 MiB verfuegbaren RAM auf Linux und bei erkanntem `/mnt/c` dieselbe
Windows-C:-Reserve wie ihre Ziel-Disk. Die zentrale Menuewache kann strenger sein. Die
Windows-/WSL-Speichererkennung ist keine automatische Bestimmung des tatsaechlichen
VHDX-Speicherorts.

```bash
bash scripts/tools/sqlfluff_install.sh --dry-run
bash scripts/tools/bats_core_install.sh --dry-run
bash scripts/tools/invoke_build_install.sh --dry-run
# Erst bewusst installieren; keine Projekttests oder Buildtasks im Installer:
bash scripts/tools/sqlfluff_install.sh
bash scripts/tools/bats_core_install.sh
bash scripts/tools/invoke_build_install.sh
```

Jeweils vorhanden: `_update.sh`, `_uninstall.sh`, `_check.sh`, `_status.sh` und `_doctor.sh`.
`--repair` ist am Installationswrapper moeglich; es ueberschreibt keine fremden oder veraenderten
Quellen. Ein Update bleibt am dokumentierten Pin, es zieht nicht ungeprueft `main` oder `latest`.

Windows ohne Bash fuer den Installer:

```powershell
py -3 -B scripts/tools/helpers/dev_quality.py sqlfluff install --dry-run
py -3 -B scripts/tools/helpers/script_quality.py invoke_build install --dry-run
```

Kein fehlendes Python, Bash oder PowerShell wird automatisch installiert. `DEV_QUALITY_PYTHON_BIN`
waehlt fuer die Shellwrapper ein vorhandenes Python. Keine Shellprofile, ExecutionPolicy, globalen
Module oder PATH-Aenderungen.

`BATS_BASH_BIN` kann explizit auf vorhandenes natives Git Bash zeigen, `INVOKE_BUILD_PWSH_BIN` auf
vorhandenes PowerShell 7. Unter Windows werden System32-/WindowsApps-WSL-Launcher nicht als
Bash-Runtime akzeptiert; der Installer darf dadurch nicht unbeabsichtigt eine WSL-Distro starten.

## Nutzung und Statusgrenzen

Basis: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/`. Der Installer zeigt
die genauen lokalen Pfade an. SQLFluff liegt in `sqlfluff/env-*/`; dort den ausgegebenen Python-Pfad
mit `-m sqlfluff --help` verwenden. Abhaengigkeiten werden als Wheels von PyPI aufgeloest, nicht
alle aus GitHub und noch nicht vollstaendig mit Dependency-Hashes eingefroren. Das Hauptpaket stammt
vom festen GitHub-Commit, nicht aus einem Docker-Image.

Bats direkt mit dem vorhandenen Bash und `bats_core/source/bin/bats` aufrufen. Invoke-Build mit
`pwsh -NoProfile -File` und dem absoluten Pfad `invoke_build/source/Invoke-Build.ps1` verwenden;
eine Projektdatei explizit angeben, statt unbekannte Aufgaben automatisch entdecken zu lassen. Erst
synthetische Testprojekte verwenden. Bats-Tests und Invoke-Build-Aufgaben koennen beliebige Befehle
ausfuehren; SQLFluff-Plugins/Templater ebenfalls. Keine Datenbankanmeldung, Migration oder
SQL-Ausfuehrung durch den Installer.

- `build-ready.json` bei SQLFluff: privates Paket installiert, Paketmetadaten und `pip check`
  geprueft; keine Projektqualitaet zugesichert.
- `scripts-ready.json` bei Bats/Invoke-Build: sauberer GitHub-Pin, benoetigte Dateien und Syntax des
  Einstiegsskripts geprueft. **Kein kompletter Upstream-Selbsttest oder erfolgreicher Projektlauf.**
- Status/Doctor laden nichts herunter und starten keine Projektbefehle.
- Menueeintraege verwenden diese Marker; ein misslungener Versuch erzeugt keinen erfolgreichen
  Installationsnachweis. Manuell veraenderte Quellen werden vom expliziten Check erkannt; der
  schnelle Menue-Markercheck allein ist keine vollstaendige Integritaetspruefung.

## Logging, Rollback und Deinstallation

Operationslock je Tool verhindert parallele Installation/Deinstallation. Jeder veraendernde Aufruf
schreibt ein eigenes Log unter `install_logs/`, einschliesslich fehlender Runtime, Speicherabbruch
und Rollback. Dry-Run und Status sind schreibfrei.

Bei Fehlern wird nur eine neu angelegte Python-Umgebung beziehungsweise ein neuer unveraenderter
Skriptcheckout entfernt. Bereits vorhandene Dateien werden nicht pauschal geloescht.
Git-Download-Staging wird bei Fehlern entfernt. SQLFluff behaelt den verifizierten Quellcache und
Logs; sein venv wird nach Besitz-/Hashpruefung deinstalliert. Bats/Invoke-Build entfernen ihren
sauberen, registrierten Quellcheckout; bei lokalen Aenderungen oder fremdem Bestand wird die
Entfernung abgebrochen. Basiswerkzeuge, andere Projekte und Logs bleiben erhalten. Es wird kein
`rm -rf /opt/...` ausgefuehrt.

## Was mit den anderen Quellen passiert

**Aktualisiert 21.10.2026:** Hauptmenue **16** oder Tools-Menue **8**, Schaltflaeche **62 Quellen
verwalten**, oeffnet jetzt auch den
[Installations-/Lifecycle-Einstieg](development-toolchain-check.md). 52 neue private
Build-/Paketrezepte und zehn vorhandene Adapter sind einzeln auswaehlbar. Neue Rezepte bleiben
experimentell, nicht als live gebaut bestaetigt.

| Gruppe aus dem Katalog                                                                          | Behandlung                                                                                                                       |
| ----------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Playwright, ShellCheck, shfmt, PostgreSQL, dbt, kubectl, Helm, Kustomize, Argo-CD-CLI, Flux-CLI | Bereits registriert; kein doppelter Eintrag und keine Behauptung, dass deren bestehende Installer alle GitHub-Source-Builds sind |
| Node/Go/Rust und Compiler wie GCC/LLVM                                                          | Private Buildrezepte; Bootstrap-Toolchains/SDKs und grosse Reserven noetig, keine Systemumstellung                               |
| TypeScript, Prettier, ESLint, Vitest, Vite, pnpm                                                | Private JS-Build-/Paketrezepte; Versions-/Lockfile-Voraussetzungen pruefen                                                       |
| GoogleTest, Catch2, pgTAP, Terratest                                                            | Projekt-/Datenbankbibliotheken, keine pauschale globale Installation                                                             |
| Actions Checkout/Setup Go/Setup Terraform sowie Docker-CI-Actions                               | Workflow-Bausteine, keine lokalen Programme; Beispiele bleiben inaktiv                                                           |
| Docker CLI/Compose/Buildx/BuildKit, kind, Skaffold, GitOps-Controller                           | Keine automatische Runtime-, Cluster- oder Dienstbereitstellung                                                                  |
| Delve, golangci-lint, gopls, Kubeconform, KubeLinter, TFLint, terraform-docs                    | [Jetzt als sieben echte GitHub-Go-Builds integriert](development-go-tools.md), einschliesslich Doctor/Uninstall                  |
| rust-analyzer, BashDB, Pester, PSScriptAnalyzer, Hadolint, Checkov, Flyway, terraform-ls        | Jetzt private Build-/Paketrezepte im 62er-Einstieg, ohne Runtime-Start                                                           |
| Terraform und OpenTofu                                                                          | Lizenz-/State-Grenzen beibehalten; kein automatisches Infrastruktur-Upgrade                                                      |
| VS-Code-PowerShell                                                                              | Editor-Erweiterung, nicht ungefragt im Editor aktivieren                                                                         |

Die [zentrale 62er-Tabelle](../DEVELOPMENT_TOOLS_OVERVIEW.md) zeigt jetzt fuer alle Quellen den
ausgewaehlten Adapter/Paketweg. Actions sind lokale Pakete, Bibliotheken und VSIX werden nicht
automatisch in Zielsystemen aktiviert. Bei dieser Aenderung wurden keine Werkzeuge installiert, kein
Livebuild durchgefuehrt und weder WSL noch Docker oder Cloud angesprochen.
