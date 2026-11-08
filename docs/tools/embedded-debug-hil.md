# Embedded Debug HIL: GitHub-Basis ohne Docker

## Installierter Umfang

Embedded_Debug_HIL ist ein Setup-Integrationsprofil, kein einzelnes Upstream-Programm. Der
Menuepunkt installiert jetzt die MIT-lizenzierte Python-Bibliothek
[cs01/pygdbmi](https://github.com/cs01/pygdbmi/tree/52a17f1d8651e941b8551a44a03d181d605e1e56) aus
GitHub: Release `v0.11.0.0`, Commit `52a17f1d8651e941b8551a44a03d181d605e1e56`. Status
**experimental**, nur Basisbibliothek, kein fertiges HIL-System.

Die bisherige pauschale documentation-first-Sperre gilt nicht mehr fuer diese explizit ausgewaehlte
Basisinstallation. Live-Adapter bleiben planned. OpenOCD/pyOCD/GDB werden weder installiert noch
gestartet. Keine USB-/JTAG-/ SWD-Verbindung, udev-Regel, Gruppen-/Socket-Aenderung, MCU-Halt/Reset,
Flashen, eFuse-Aktion, Netzwerkverbindung zum Board oder MCP-Server. Port 3333 ist nur in der
zentralen Planung reserviert; kein Listener startet.

## Installation und Status

```bash
bash scripts/tools/embedded_debug_hil_install.sh --dry-run
bash scripts/tools/embedded_debug_hil_install.sh
bash scripts/tools/embedded_debug_hil_status.sh
bash scripts/tools/embedded_debug_hil_doctor.sh
bash scripts/tools/embedded_debug_hil_install.sh --repair
bash scripts/tools/embedded_debug_hil_update.sh
bash scripts/tools/embedded_debug_hil_uninstall.sh
```

Normaler Linux-Benutzer, Bash, Git, flock, realpath, Python 3.10-3.12 mit venv/ensurepip/SSL.
Interpreterwahl: `EMBEDDED_DEBUG_HIL_PYTHON_BIN`. Kein Austausch des System-Python und keine
ungefragte apt-Einrichtung. Konservative Basisreserve: 512 MiB Gesamt-RAM und freie Disk, unter WSL
zusaetzlich 1024 MiB freier Windows-Host-Speicher. Kein GPU-Bedarf fuer diese Bibliothek; Werte sind
keine Hardware-/Firmware-Buildzusage.

### Fehlendes venv/ensurepip reparieren

Seit 19.10.2026 bietet der Installer das versionspassende Ubuntu-Paket an, beispielsweise
`python3.12-venv`. Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal keine Installation;
ausdrueckliches nichtinteraktives Opt-in:

```bash
EMBEDDED_DEBUG_HIL_INSTALL_VENV_DEPS=1 bash scripts/tools/embedded_debug_hil_install.sh --repair
```

`EMBEDDED_DEBUG_HIL_INSTALL_VENV_DEPS=0` deaktiviert die Paketinstallation. Nur das zum gewaehlten
System-Python unter `/usr/bin/python3.X` passende Paket wird angeboten. Private Interpreter, aktive
venvs und SSL-/Versionsfehler erfordern separate Pruefung; kein System-Python wird ersetzt.
Speicherpruefung, Sperre und aktuelles Tool-Log kommen vor der Reparatur. APT wartet begrenzt auf
Paketverwaltungssperren, ohne Sperrdateien zu loeschen. Nach Paketinstallation wird venv/ensurepip
erneut geprueft; bei Fehlern kein Clone/Build. pygdbmi bleibt am GitHub-Pin, ohne Docker. Die
Zustimmung gibt keine Debugger, Hardwarezugriffe oder Dienste frei. Vorhandene fremde/beschaedigte
venvs werden nicht automatisch geloescht.

Ziel: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/embedded_debug_hil/` mit
`source/`, `venv/`, `operation.lock`, `source-built`. Logs: `install_logs/embedded_debug_hil_*.log`
im User-Workspace. Quellcode kommt aus GitHub, pip baut nur diesen lokalen Checkout mit `--no-deps`;
isolierte Build-Werkzeuge koennen aus PyPI kommen. GitHub-Installation bedeutet nicht, dass alle
Build-Abhaengigkeiten dort liegen.

Status/Doctor pruefen Git-Pin und Paketmetadaten/Installationsherkunft, ohne pygdbmi zu importieren
oder einen Debugger zu starten. `installed=true` heisst **nur Basisbibliothek**;
`hardware_ready=false`. Der Erfolgsmarker steuert die Menue-Registrierung. Deaktivierung entfernt
Marker und Statuszeilen; Source, venv, Snapshots und Logs bleiben erhalten. Kein globales
`embedded-debug-hil`-Kommando wird vorgetaeuscht. Geaenderte/fremde Verzeichnisse bleiben erhalten;
kein Reset/Loeschen. Updates verwenden denselben Pin. Live-GDB-Steuerung ist nicht freigeschaltet.

## Offline-Snapshot-Bericht

Der eigene JSON-Reporter liegt weiterhin im GitHub-Setup-Checkout und wird nicht als
Drittanbieterpaket ausgegeben. Er benoetigt pygdbmi nicht:

```bash
python3 tools/embedded_debug_hil/hil.py report tools/embedded_debug_hil/snapshot.example.json
```

Nur synthetische oder manuell autorisierte Snapshots einlesen. Der Reporter liest keine Hardware und
startet weder Shell noch Netzwerk. Registerwerte sind unbestaetigte Daten; Ursachen sind Hypothesen,
keine automatischen Fixes.

## Sicherheitsgrenze und naechste Schritte

Auch Lesen/Attach/Halt kann einen Echtzeitregler beeinflussen. Fuer spaetere Live-Integration
benoetigt jede Sitzung eine ausdrueckliche Board-/Probe-/ Firmware-Freigabe und sichere Abschaltung
von Aktoren. Keine autonomen Reset-, Flash-, Speicher-Schreib-, Schutzbit- oder eFuse-Aktionen.
GDB-Port hoechstens localhost und nur manuell freigegeben, nie oeffentlich. Kein
Produktions-/Fahrzeug-/Medizingeraet fuer autonome Versuche.

WSL/USB-Passthrough, ARM-Host, Board-GDB, Debug-Symbole und Probe muessen separat getestet werden.
MiniPC/VPS/Cluster koennen Offline-Berichte nutzen, erhalten dadurch aber keine Berechtigung fuer
entfernte Hardware. Weitere Kandidaten: [OpenOCD](https://github.com/openocd-org/openocd),
[pyOCD](https://github.com/pyocd/pyOCD), jeweils mit eigener Lizenz/Installation.

Hier nur Offline-Tests mit temporaeren Dateien und simulierten Installern; kein echter
Linux-Paketbau, Hardwaretest oder WSL-Zugriff.

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
python3 -I -B scripts/tool_commands.py show embedded_debug_hil
```

### SSH-Aktionen: `embedded_debug_hil`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Embedded_Debug_HIL` (ID `embedded_debug_hil`) waehlen und die Einzelfreigaben lesen.
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
