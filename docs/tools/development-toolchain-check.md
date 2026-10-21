# 62 Werkzeugquellen installieren und verwalten

Stand: 21.10.2026. Der bisherige reine Pruefbericht ist um einen
**auswaehlbaren Installations-/Lifecycle-Einstieg fuer alle 62 Quellen** erweitert.
[Zentrale Tabelle](../DEVELOPMENT_TOOLS_OVERVIEW.md), [Buildrezepte](../../config/development_installers.json).

## Im Setup

Hauptmenue **16: 62 Werkzeugquellen: installieren / verwalten** oder im
Tools-Menue **8** die Schaltflaeche **62 Quellen verwalten**.

1. Zuerst den Installationsplan waehlen und Quelle, Voraussetzungen, Paketart
   und Speicherbudget lesen.
2. Installation waehlen und genau ein Werkzeug aus der A-Z-Liste auswaehlen.
3. Buildcode/Dependencies und Lizenz bewusst freigeben; schwere Builds
   erfordern zusaetzlich `INSTALL_HEAVY_TOOLS=1` in der Setup-Umgebung.
4. Ergebnis mit Logpfad lesen. Danach Status pruefen; ohne Artefaktnachweis
   wird keine neue Installation als erfolgreich gemeldet.

Der Einstieg bleibt separat von den bisherigen Tool-Haekchen. Er uebernimmt
keine Auswahl des Tools-Menues und aktiviert keine Dienste, Cluster oder CI.
Private Builds der 52 ergaenzten Rezepte aendern nicht die alten systemweiten
Installationen gleichnamiger Programme. Zehn bereits vorhandene private
Adapter werden explizit weiterverwendet; ihre eigenen Regeln bleiben bestehen.

## Was bedeutet hier installierbar?

| Art | Tatsachliches Ergebnis |
|---|---|
| CLI/Compiler | Binary oder interpretierter CLI-Einstieg samt Build-/Paketdateien im privaten Workspace |
| JS-/Python-Paket | Gebaute Dateien bzw. private venv; keine globale npm-/pip-Installation |
| C++-Bibliothek | Installierte Header/Bibliotheken mit privatem CMake-Prefix |
| Go-Bibliothek Terratest | Lokaler Quellstand, verifizierte Module und erfolgreicher Bibliotheksbuild; keine Infrastrukturtests |
| PowerShell-Modul | Gebautes Modul mit Manifest/DLL; kein automatischer Import |
| VS-Code-PowerShell | Gebautes VSIX-Paket; Editorinstallation bewusst separat |
| pgTAP | Extension-Dateien per DESTDIR im privaten Ziel; kein CREATE EXTENSION oder DB-Zugriff |
| GitHub Action | Lokaler Quellcheckout und auf Commit fixierte `uses`-Referenz; keine aktive Workflow-Datei |

**Kein 62er-Massenbuild und keine Garantie fuer 62 erfolgreiche Livebuilds.**
Alle 52 neuen Rezepte sind experimentell: Buildpfade koennen sich upstream
aendern, SDKs/Systembibliotheken oder passende Compiler koennen fehlen.
Die Tests verwenden synthetische Buildausgaben, nicht echte Upstream-Builds.
Ein vorhandenes Rezept ist nicht dasselbe wie ein erfolgreich gebautes,
gestartetes oder sicherheitsgeprueftes Programm.

## Direkt auf dem vorgesehenen Linux-Host

Python 3.10+ und die im Plan genannten Werkzeuge muessen vorhanden sein.
Der Installer fuehrt keine apt-/sudo-Systeminstallation aus. Node/Go/Rust/
.NET/Haskell koennen zum Bauen ihres eigenen Nachfolgers eine bereits
vorhandene Bootstrap-Toolchain benoetigen; Rust-Compilerwerkzeuge teilweise
genau passende Nightly-/rustc-dev-Komponenten. Nicht alle Komponenten werden
durch Installation eines einzelnen Compilers automatisch bereitgestellt.

Erfolgreiche private Node-/Go-/CMake-/Cargo-/PowerShell-Builds aus diesem
Einstieg werden fuer nachfolgende neue Rezepte automatisch im Prozess-PATH
beruecksichtigt. Es wird kein globaler PATH und kein Shellprofil geaendert.
Die downloadfreie Vorpruefung sucht weiterhin im aktuellen PATH; dort kann
eine private Toolchain noch als fehlend erscheinen, obwohl der Build sie erkennt.

```bash
bash scripts/install_development_toolchain.sh list
bash scripts/install_development_toolchain.sh plan --tool bashdb
bash scripts/install_development_toolchain.sh install --tool bashdb --accept-build-risk
bash scripts/install_development_toolchain.sh status --tool bashdb
bash scripts/install_development_toolchain.sh doctor --tool bashdb
bash scripts/install_development_toolchain.sh update --tool bashdb --ref TAG_ODER_COMMIT --accept-build-risk
bash scripts/install_development_toolchain.sh uninstall --tool bashdb
```

Die neuen Rezepte sind fuer Linux/macOS ausgelegt, nicht vollstaendig auf
beiden Plattformen live getestet. Das kubectl-Source-Buildrezept ist vorerst
**Linux amd64** und nutzt `kubernetes/kubernetes`, nicht den
`kubernetes/kubectl`-Code-Mirror. Fuer dbt wird das kanonische
`dbt-labs/dbt`-Repository verwendet; der erwartete Python-Paketpfad wird
nicht still durch ein beliebiges Root-Paket ersetzt.

Nativ unter Windows bleiben Listen, Plan und Offline-Vorpruefung moeglich:

```powershell
py -3 -I -B scripts/quality/development_install.py list
py -3 -I -B scripts/quality/development_install.py plan --tool llvm
py -3 -I -B scripts/quality/development_toolchains.py --json
```

Windows startet **keine WSL-Distro**. Diese Aenderung am Setup hat keine
Installation auf deinem Linux-/WSL-System ausgefuehrt.

## Sicherheit, Speicher und Fehler

Neue Ziele: `$OPENCLAW_USER_DATA_DIR/development-tools/<id>/generation-.../`
oder standardmaessig `~/.openclaw_ultimate_user_data/development-tools/`.
`installed.json` benennt die aktive Generation, Quelle, Commit und
SHA256-Pruefwerte. Die Generation bleibt an ihrem Ort, damit eingebaute
absolute Prefix-Pfade nicht durch nachtraegliches Verschieben brechen.

- Primaerquelle ist GitHub; Paketregistries fuer Buildabhaengigkeiten bleiben
  erforderlich. Buildhooks fuehren fremden Code mit Benutzerrechten aus:
  privater Workspace ist **keine Sicherheits-Sandbox**.
- Vor dem ersten Download und jeder Buildphase werden Disk/RAM-Reserven
  geprueft; unter bereits laufendem WSL konservativ zusaetzlich `/mnt/c`.
  Der tatsaechliche VHDX-Speicherort wird nicht automatisch ermittelt.
- GCC/LLVM/Node/Rust und weitere schwere Builds brauchen bewusstes Opt-in.
  LLVM reserviert 96 GiB Disk; Werte sind Planungsbudgets, keine Messwerte.
- Ein globaler Lock verhindert parallele Jobs dieses Einstiegs. Compiler
  bekommen grundsaetzlich zwei Buildprozesse; Upstream-Subprozesse koennen
  trotzdem weitere Ressourcen benoetigen. Pro Buildphase maximal zwei Stunden.
- Erst nach erfolgreichen Kommandos und vorhandenen, nichtleeren Artefakten
  entsteht ein Erfolgsnachweis. `runtime_tested=false` bleibt sichtbar.
- Bei Fehler/Speicherabbruch werden nur die neue Generation und deren Caches
  entfernt. Bestehende aktive Installation und deren Nachweis bleiben erhalten.
  Es wird nicht pauschal alles deinstalliert.
- Jeder neue Rezeptlauf hat ein eigenes Log unter `development-tools/logs/`,
  auch ein Speicherabbruch vor dem Clone. Buildausgabe steht dort; das Setup
  zeigt Ergebnis und Logpfad. Alte Logs werden nicht als aktueller Lauf ausgegeben.
- Deinstallation prueft Besitzmarker und Artefakthashes und entfernt nur die
  aktive eigene Generation. Geaenderte Artefakte werden nicht still geloescht.
  Logs, Basiswerkzeuge und vorherige erfolgreiche Update-Generationen bleiben
  erhalten; es gibt keine automatische Systembereinigung.

Bei einer Erstinstallation ohne `--ref` wird der damalige GitHub-HEAD einmal
auf einen Commit aufgeloest und im Nachweis festgehalten. Das ist **kein vorab
fachlich freigegebener Pin**. Fuer reproduzierbare Freigaben vorher einen
geprueften Tag/Commit im Plan festlegen und explizit `--ref` verwenden.
Ein weiterer Install-/Update-Aufruf ohne neue Referenz behaelt den vorhandenen
Stand. Die zehn bisherigen Adapter haben weiterhin ihre eigenen festen Pins;
dort wird `--ref` nicht durchgereicht.

## Vorpruefung und Exitcodes

Der [Offline-Pruefer](../../scripts/check_development_toolchains.sh) bleibt
downloadfrei. Er beruecksichtigt jetzt auch neue Rezepte und deren
Voraussetzungen, ohne einen Build zu behaupten:

```bash
bash scripts/check_development_toolchains.sh --list
bash scripts/check_development_toolchains.sh --tool bashdb
bash scripts/check_development_toolchains.sh --json
```

`BUILD-/PAKETREZEPT VORHANDEN` bedeutet nur: ein neuer Adapter und lokal
erkennbare Voraussetzungen sind vorhanden. `VORAUSSETZUNGEN FEHLEN` benennt
fehlende Werkzeuge/Reserven/Opt-ins oder die Windows-Plattformgrenze.
Versionen und transitive Bibliotheken bleiben bis zum Build ungeprueft.
Installations-Exit 0 bedeutet Artefakte bereitgestellt, nicht Runtime/Deployment
getestet; Status liefert JSON, Doctor Exit 1 bei fehlendem/ungueltigem Nachweis.
Der Offline-Pruefer liefert standardmaessig Exit 0 fuer einen erzeugten Bericht,
mit `--strict` Exit 1 bei offenen Voraussetzungen.

## Quellen und Praesentation

Die [Technologie-/Tooling-Praesentation](../presentations/technology-tooling-overview.pptx)
mit **13 Folien** bleibt als Quellenmaterial verlinkt:
[lesbare Folienquelle](../presentations/technology-tooling-overview.json).
Sie ersetzt keinen Buildnachweis.

Buildreferenzen: [Node BUILDING](https://github.com/nodejs/node/blob/main/BUILDING.md),
[PowerShell](https://github.com/PowerShell/PowerShell/blob/master/build.psm1),
[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer#building),
[Pester Build](https://github.com/pester/Pester/blob/main/build.ps1),
[VS-Code-PowerShell](https://github.com/PowerShell/vscode-powershell/blob/main/docs/development.md).
Weitere offizielle Quellen stehen in der zentralen Tabelle.
