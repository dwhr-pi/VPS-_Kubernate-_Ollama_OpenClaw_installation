# Sieben weitere Entwicklungswerkzeuge aus GitHub bauen

Diese Tools sind jetzt echte optionale Installationsadapter, nicht nur
Eintraege im Pruefkatalog. Kein Docker, kein globaler PATH-Eintrag und kein
automatischer Start der erzeugten Programme. Die Integration ist
**experimental**: Offline-Fixtures beweisen keinen erfolgreichen Livebuild.

| Tool im Setup | Offizielle Quelle / gepruefter Pin | Go mindestens | Lizenz | Disk / RAM MiB |
|---|---|---|---|---|
| Gopls | [golang/tools, gopls/v0.18.1](https://github.com/golang/tools/tree/0b62b3fcb903046d1ed6e0c50a94871e9fdcae2a) | 1.23.4 | BSD-3-Clause | 4096 / 1024 |
| Delve | [go-delve/delve, v1.24.0](https://github.com/go-delve/delve/tree/0b7bffc7d40411f8361e10009e73fb9c9b318fb6) | 1.21 | MIT | 4096 / 1024 |
| GolangCI_Lint | [golangci/golangci-lint, v2.1.6](https://github.com/golangci/golangci-lint/tree/eabc2638a66daf5bb6c6fb052a32fa3ef7b6600d) | 1.23.0 | GPL-3.0 | 8192 / 2048, heavy |
| Kubeconform | [yannh/kubeconform, v0.6.7](https://github.com/yannh/kubeconform/tree/1bd44986dd3d281725afab6b173770ec86b454fc) | 1.22 | Apache-2.0 | 4096 / 1024 |
| KubeLinter | [stackrox/kube-linter, v0.7.1](https://github.com/stackrox/kube-linter/tree/00ad4327e3ad9e86f6956feca92917be049bcb9f) | 1.22.5 | Apache-2.0 | 8192 / 2048, heavy |
| TFLint | [terraform-linters/tflint, v0.57.0](https://github.com/terraform-linters/tflint/tree/e352b5712a786958c94553e0859043b2a958e4b9) | 1.24.1 | MPL-2.0 | 4096 / 1024 |
| Terraform_Docs | [terraform-docs/terraform-docs, v0.20.0](https://github.com/terraform-docs/terraform-docs/tree/cf462c5da36feb66051cf0a6f1124594ed9adc7c) | 1.23.0 | MIT | 4096 / 1024 |

Pins sind bewusst feste Release-Staende, keine Behauptung der neuesten Version.
Lizenzhinweise gelten fuer das Hauptprojekt; transitive Lizenzen separat pruefen.
Budgets sind Reserven, keine gemessenen Installationsgroessen. Ziel: Linux,
MiniPC, macOS und Windows mit vorhandener kompatibler Go-Toolchain; kein
pauschaler Architektur-/ARM-Livebuildnachweis. CGO wird deaktiviert. Falls ein
Paket oder eine Zielplattform damit nicht baut, erfolgt ein Fehler, kein
automatischer Compiler-/Systemumbau.

## Vorpruefen und bewusst installieren

Im Setup: Hauptmenue 16 oder Tools-Menue 8, Schaltflaeche "62 Quellen pruefen".
Die eigentliche Installation erfolgt im Tools-Menue beim jeweiligen Tool.

```bash
bash scripts/tools/kubeconform_install.sh --dry-run
bash scripts/tools/kubeconform_install.sh
bash scripts/tools/kubeconform_doctor.sh
bash scripts/tools/kubeconform_uninstall.sh
# Diese zwei Builds brauchen ausdrueckliches Opt-in:
INSTALL_HEAVY_TOOLS=1 bash scripts/tools/golangci_lint_install.sh
INSTALL_HEAVY_TOOLS=1 bash scripts/tools/kubelinter_install.sh
```

Fuer alle sieben gibt es Install/Update/Uninstall/Check/Doctor/Status-Wrapper
und `--repair`. Windows nativ, ohne Bash oder WSL:

```powershell
py -3 -B scripts/tools/helpers/development_go.py tflint install --dry-run
py -3 -B scripts/tools/helpers/development_go.py tflint install
```

Python 3.10+, Git und eine vorhandene Go-Toolchain erforderlich.
`DEV_GO_BIN` kann deren absoluten Pfad auswaehlen;
`DEV_QUALITY_PYTHON_BIN` waehlt Python fuer die Bash-Wrapper.
Der Installer prueft `go version` vor dem Download. `GOTOOLCHAIN=local`
verhindert automatische Go-Downloads. Fehlendes/zu altes Go wird klar
protokolliert, nicht am System repariert. Die schnelle Vorpruefung startet Go
dagegen nicht und sagt deshalb noch nichts ueber die Go-Version aus.

## Build und Abhaengigkeiten

Die Rezepte in [development_go_tools.json](../../config/development_go_tools.json)
enthalten Commit, Modul-Unterordner, Paketpfad, Go-Minimum und Ressourcen.
Gopls wird aus dem Untermodul `gopls/` gebaut, nicht aus dem Monorepo-Root.
KubeLinter hat `cmd/kube-linter/kube-linter.go` statt einer angenommenen `main.go`.

Das Hauptprojekt wird vom GitHub-Pin geladen und vor/nach dem Build auf sauberen
Stand geprueft. Dependencies kommen ueber `proxy.golang.org` mit Go-SumDB und
den vorhandenen go.mod/go.sum; **nicht alle Dependencies stammen direkt aus
GitHub**. Kein ungepinntes `go install ...@latest`, kein ausgefuehrtes Makefile,
kein `go generate`. `go mod download`, `go mod verify` und
`go build -mod=readonly -trimpath -buildvcs=false -p=2` laufen in einer privaten
Kopie. Compiler und Module sind vertrauensrelevanter Code, keine Sandbox.

Private HOME-/Cache-/Temp-Verzeichnisse, zwei Buildprozesse und ein
30-Minuten-Zeitlimit je Buildphase begrenzen den Ablauf; das ist kein hartes
RAM-/CPU-cgroup-Limit. API-Keys, GOFLAGS, private Modulzugriffe und globale
Go-Konfiguration werden nicht an den Buildprozess vererbt. Module werden nicht
in gemeinsame System-Caches installiert. Der Buildjob samt Cache wird entfernt,
bevor ein erfolgreicher Marker veroeffentlicht wird.

## Status, Rollback und Deinstallation

Unter `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/<id>/`
liegen die private Binary, `source/` und `build-ready.json`. Der Marker wird
erst nach erzeugter Binary, geprueften Go-Buildmetadaten und Jobbereinigung
geschrieben. Er enthaelt Commit und SHA256; `application_tested=false` bleibt
ausdruecklich erhalten. Die Binary wird vom Installer nicht gestartet.

Locks und aktuelle Einzel-Logs unter `install_logs/` erfassen auch
fehlendes Go, Opt-in, Speicherabbruch und Rollback. Unter erkanntem WSL wird
zusaetzlich `/mnt/c` auf Reserve geprueft; der echte VHDX-Speicherort wird nicht
automatisch ermittelt. Von Windows aus wird keine WSL-Distro aufgerufen.

Fehler entfernen nur den neuen Buildjob und eine in diesem Versuch neu
veroeffentlichte Binary. Verifizierter Quellcache und Logs bleiben bewusst
erhalten. Die Deinstallation entfernt nur die nachgewiesene unveraenderte
Binary samt Marker, nicht Go, andere Projekte oder Quellen/Logs. Veraenderte
oder fremde Binaries werden nicht ueberschrieben/geloescht. Update bleibt
am Pin, statt eigenmaechtig auf latest zu wechseln.

## Grenzen bei der spaeteren Nutzung

- Delve wird installiert, aber an keinen Prozess angehaengt und oeffnet
  keinen Debug-Port. Architektur, ptrace/Rechte und Debugziel separat pruefen.
- Gopls startet keinen Sprachserver und wird in keinem Editor automatisch aktiviert.
- GolangCI-Lint prueft im Installer kein Nutzerprojekt; Projektplugins koennen Code ausfuehren.
- Kubeconform startet keinen Schema-Download oder Clustercheck im Installer;
  spaetere Schemaquellen bewusst konfigurieren.
- KubeLinter erhaelt keinen Cluster-/Dockerzugriff.
- TFLint laedt keine Plugins und fuehrt kein Terraform aus.
- terraform-docs schreibt keine Projektdokumentation im Installer.

Die [zentrale Tabelle aller 62 Quellen](../DEVELOPMENT_TOOLS_OVERVIEW.md) trennt
diese Build-Adapter von weiter offenen Toolchains, Bibliotheken und CI-Actions.
