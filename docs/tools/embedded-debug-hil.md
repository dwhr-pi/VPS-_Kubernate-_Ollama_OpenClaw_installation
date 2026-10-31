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
