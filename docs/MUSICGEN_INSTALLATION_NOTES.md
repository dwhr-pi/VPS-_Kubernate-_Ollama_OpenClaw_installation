# MusicGen: Python, PyAV und Speicher

Das Protokoll scheitert an PyAV 11: `pkg-config` findet keine FFmpeg- Entwicklungsbibliotheken. Der
Installer ergaenzt `pkg-config`, `ffmpeg` und die sieben `libav*-dev`/`libsw*-dev`-Pakete und prueft
deren Metadaten. FFmpeg allein ersetzt die Entwicklungspakete nicht.

[AudioCraft v1.3.0](https://github.com/facebookresearch/audiocraft/blob/v1.3.0/requirements.txt)
pinnt PyAV 11 und PyTorch 2.1.0. Python 3.12 ist fuer diese alte PyTorch-Linie ungeeignet. Unser
experimenteller Pfad verwendet Python 3.10/3.11; die
[Upstream-README](https://github.com/facebookresearch/audiocraft#installation) nennt Python 3.9. Die
abweichende Auswahl braucht noch echte Linux-/GPU-Tests. System-Python wird weder ersetzt noch
automatisch gebaut.

## Vorbereitung

```bash
bash scripts/tools/musicgen_install.sh --check
bash scripts/tools/musicgen_install.sh --dry-run
MUSICGEN_PYTHON_BIN=/path/to/python3.11 bash scripts/tools/musicgen_install.sh
```

Check/Dry-Run pruefen Python und Disk ohne Installation. Der echte Lauf fordert Heavy-Opt-in.
Inkompatible `venv` wird gesichert, nicht geloescht. Kompatible venv wird wiederverwendet; Pakete
koennen aktualisiert werden. Vorher sichern. AudioCraft kommt per pip-VCS aus GitHub-Tag v1.3.0;
Abhaengigkeiten kommen weiterhin aus Paketindizes. pip/setuptools/wheel und PyTorch sind gepinnt,
NumPy bleibt unter Version 2. Kein vollstaendiges transitive Lockfile.

## Ressourcen und Grenzen

Setup-Reserve: 40 GiB frei auf `/opt`, bei erkennbarer WSL 20 GiB auf Windows-C:. Die gemeldeten 9
GB reichen dafuer nicht. Schutzwerte, keine offiziellen Minima. Andere Cache-/Docker-Laufwerke
zusaetzlich pruefen. Es wird nichts zur Speicherfreigabe automatisch geloescht. Als Planungswert
mindestens 16 GiB RAM; VRAM je Modell anhand der
[MusicGen-Doku](https://github.com/facebookresearch/audiocraft/blob/main/docs/MUSICGEN.md) pruefen.
RAM/GPU sind noch keine automatische Sperre in diesem Installer.

Import-Test laedt keine Modelle und erzeugt keine Musik. GPU/CUDA, Modellgewichte und Generierung
bleiben separat zu testen. Keine Ports werden geoeffnet. Code-Lizenz MIT und Gewichte CC-BY-NC 4.0
getrennt beachten.

## TODO

- Registry bleibt planned bis zum echten Zielsystemtest.
- FFmpeg/PyAV unter Ubuntu 24.04, ARM-Wheels und native Builds validieren.
- Alte PyTorch-Pakete auf Schwachstellen pruefen; Lockfile und CUDA-Auswahl ergaenzen.
- RAM-/GPU-Preflight ergaenzen; venv-Backup nach erfolgreichem Test bewusst aufraeumen.

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
python3 -I -B scripts/tool_commands.py show musicgen
```

### SSH-Aktionen: `musicgen`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`MusicGen` (ID `musicgen`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
