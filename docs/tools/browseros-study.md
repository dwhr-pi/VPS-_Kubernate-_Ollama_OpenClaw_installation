# BrowserOS fuer Studienzwecke und Weiterentwicklung

Stand: 26.10.2026. **Experimenteller Entwicklungsweg, keine Produktionsfreigabe.** Dieser Vermerk
beschreibt den Einsatzzweck im Setup, **keine neue Lizenz**. Upstream-Lizenz und
Drittanbieterhinweise bleiben massgeblich. BrowserOS fuehrt AGPL-3.0 und Chromium-/weitere
Komponentenhinweise; nicht pauschal als MIT ausgeben.

## Zwei getrennte Eintraege

| Tool                | Zweck                                                                                                           |
| ------------------- | --------------------------------------------------------------------------------------------------------------- |
| **BrowserOS**       | Bisheriger manueller Desktop-Download aus offiziellen GitHub-Releases fuer Windows/Linux                        |
| **BrowserOS_Study** | Gepinnte GitHub-Quellen zum Lesen, Studieren und Weiterentwickeln; optional experimenteller Linux-Browser-Build |

Beide stehen in der angehaengten Browsergruppe **hinter A-Z**. Comet und der Qwen-aehnliche manuelle
EXE-Weg werden dadurch nicht ersetzt. Ein Quellcode-Download ist **keine gebaute
Browserinstallation**.

## Quellen herunterladen

Im Tools-Menue **BrowserOS_Study** waehlen. Interaktiv bietet der Installer:

1. **Nur Studienquellen** (Standard, auch ohne Terminal).
2. **Experimentellen Vollbuild**, nur nach weiterer Bestaetigung und Vorpruefung.

Alternativ aus dem Setup-Repository:

```bash
bash scripts/tools/browseros_study_install.sh --dry-run
bash scripts/tools/browseros_study_install.sh
bash scripts/tools/browseros_study_status.sh
```

Quellstand:
[9335ee7b4472b446c7b1544f396efa0805afddcd](https://github.com/browseros-ai/BrowserOS/tree/9335ee7b4472b446c7b1544f396efa0805afddcd).
Git-HEAD und Origin werden geprueft; keine privaten Submodule rekursiv geladen. Die Quellen liegen
unter `~/.openclaw_ultimate_user_data/tools/browseros_study/runtime/`. Bei `OPENCLAW_USER_DATA_DIR`
entsprechend dort. Reserve fuer den reinen Checkout: 2 GiB. Kein Browserstart, keine Kontoanbindung,
kein Docker und keine Modelle. Update prueft denselben Pin; kein automatischer Wechsel auf
`main/latest`.

Zum Entwickeln die Dateien in diesem separaten Baum bewusst bearbeiten oder eine eigene Arbeitskopie
erstellen. Installer/Doctor ueberschreiben lokale Aenderungen nicht. Ein Fork oder eine eigene
Branchentwicklung wird nicht automatisch auf den Setup-Pin zurueckgesetzt.

## Optionaler Vollbuild

Der
[Upstream-Beitragsleitfaden](https://github.com/browseros-ai/BrowserOS/blob/9335ee7b4472b446c7b1544f396efa0805afddcd/CONTRIBUTING.md)
trennt die Agentenoberflaeche vom grossen Chromium-Browser-Build. Der integrierte experimentelle
Vollbuild gilt derzeit nur fuer **Linux/WSL x86_64**, nicht fuer Windows-Crosskompilierung. Fuer
natives Windows die Upstream-Anleitung mit Visual Studio Build Tools separat verwenden; der
bestehende Desktop-Download bleibt.

Voraussetzungen des integrierten Wegs:

- Mindestens **100 GiB freier Linux-Speicher**, unter WSL auch ausreichend freier
  Windows-Hostspeicher fuer diese Reserve. Vorhandene Chromium-Daten zaehlen zusaetzlich zum bereits
  belegten Speicher, kein Gesamtgroessenversprechen.
- Mindestens **16 GiB verfuegbarer RAM**, konservative lokale Pruefung. Das ist strenger als nur 16
  GiB physisch eingebaut. Swap ersetzt diese Pruefung nicht.
- Python >=3.12 mit SSL, uv, vorhandenes Cargo/Rust, C/C++-Compiler, make, pkg-config und die exakt
  in `packages/browseros-agent/package.json` gepinnte Bun-Version. Kein automatischer
  apt-/Toolchain-/Browser-Download.
- Ein **separater, frischer Chromium-Entwicklungscheckout** unter
  `tools/browseros_study/chromium/src` innerhalb des User-Workspace. Er muss beim Start den
  `packages/browseros/BASE_COMMIT` des Pins haben und darf keine erkannten lokalen
  Aenderungen/ungeprueften Dateien enthalten.
- Passende `depot_tools` unter `tools/browseros_study/chromium/depot_tools` mit `gclient`, `gn` und
  `autoninja`. Keine Symlink-Verknuepfung zu einem produktiven Checkout. Diese Komponenten vorher
  separat nach
  [Chromiums offizieller Quellcode-Anleitung](https://www.chromium.org/developers/how-tos/get-the-code/)
  bereitstellen. Chromium/depot_tools haben eigene Upstream-Quellen, nicht nur GitHub; sie werden
  vom Setup nicht still heruntergeladen oder zurueckgesetzt.

Die derzeitigen etwa 11 GiB auf C: aus den bisherigen Logs reichen dafuer **nicht**. Der reine
Studien-Checkout ist getrennt moeglich; die Vollbuild-Wache nicht umgehen. Auf einem geeignet
ausgestatteten separaten Buildhost ausfuehren:

```bash
bash scripts/tools/browseros_study_install.sh --build-browser --dry-run
bash scripts/tools/browseros_study_install.sh \
  --build-browser --confirm-chromium-changes
```

Die Bestaetigung erlaubt bewusst das Patchen/Veraendern der separaten Chromium- Kopie und
Buildausgaben; **nicht** die Nutzung eines bestehenden privaten Browsers. Der Installer richtet die
Python-Build-CLI privat unter `development/venv` ein und verwendet den offiziellen Buildvertrag aus
[bos_build](https://github.com/browseros-ai/BrowserOS/blob/9335ee7b4472b446c7b1544f396efa0805afddcd/packages/browseros/bos_build/README.md):

```text
browseros build --preset release --product browseros
  --resource-mode source --source-sha <gepruefter Pin>
  --provision none --no-clean --no-sign --no-upload
  --chromium-src <separater Chromium-Checkout>
```

Zuerst wird dieser Aufruf mit `--show-plan` angezeigt, danach die freigegebene Pipeline ausgefuehrt.
Es wird keine `.env` aus deinem Hauptsetup eingelesen, kein Release publiziert und kein Browser
gestartet. Container-/sudo-Fallbacks werden durch Prozess-Guards blockiert.
Python-/Bun-/Cargo-/Chromium-Abhaengigkeiten koennen Netzwerkzugriff und erhebliche Buildzeit
benoetigen. Die Python-CLI- Abhaengigkeiten sind Versionsbereiche, kein vollstaendiger
Dependency-Hash-Lock. Der Compilerlauf hat maximal sechs Stunden, davorliegende Paketinstallationen
eigene Limits; kein garantierter Abschluss innerhalb dieser Zeit.

Nur ein erwartetes Linux-Artefakt `chromium/src/out/<builddir>/chrome` mit SHA256 wird als
`browser-build.json` registriert. Das belegt den Build-Artefaktstand, **nicht**
GUI-/Sandbox-/Agentenfunktion oder Produktsicherheit. Der Studien- Quellnachweis `ready.json` ist
davon getrennt; sein Vorhandensein alleine sagt ausdruecklich nicht, dass ein Browser gebaut wurde.

## Status, Weiterentwicklung und Entfernung

```bash
bash scripts/tools/browseros_study_status.sh
bash scripts/tools/browseros_study_doctor.sh
bash scripts/tools/browseros_study_uninstall.sh
```

Status meldet Studienquellen und `browser_built` getrennt, niemals eine getestete Anwendung. Doctor
prueft die urspruengliche Quellinventur: nach eigenen Aenderungen oder einem Build kann er deshalb
bewusst abweichen. Fuer eigene Weiterentwicklung ist das keine Aufforderung zum Loeschen, sondern
ein Schutz vor Ueberschreiben.

Nur unveraenderte, vom Installer nachgewiesene Quellen koennen automatisch entfernt werden. Wenn
`development/` oder ein Buildnachweis vorhanden ist, wird die automatische Entfernung blockiert:
eigene Arbeit/Artefakte zuerst separat sichern und bewusst verwalten. Chromium, Browserprofile und
Logs bleiben immer erhalten. Bei fehlgeschlagenem Vollbuild bleiben Entwicklungsdaten ebenfalls
erhalten, statt stundenlange Arbeit ungefragt zu loeschen; kein neuer erfolgreicher
Browser-Buildnachweis. Ein erneuter Vollbuild verlangt wieder eine gepruefte frische Ausgangslage.
Fortgeschrittenes Resume/Branchentwicklung erfolgt bewusst ausserhalb der automatischen
Erstbuild-Strecke nach der Upstream-Anleitung.

## Abnahmestand

Offline-Fixtures pruefen Auswahl, Pin-/Menuezuordnung, Ressourcen-/Freigabegrenzen und den nicht
veroeffentlichenden Buildaufruf. **Kein kompletter Chromium-Build wurde hier ausgefuehrt.** Keine
Produktionsfreigabe, kein Ersatz fuer Lizenz- und Sicherheitspruefung. Details zur allgemeinen
Browser-Isolation: [Comet / Browser / Perplexity](comet-and-browser-research.md).

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py show browseros_study
```

### SSH-Aktionen: `browseros_study`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`BrowserOS_Study` (ID `browseros_study`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
