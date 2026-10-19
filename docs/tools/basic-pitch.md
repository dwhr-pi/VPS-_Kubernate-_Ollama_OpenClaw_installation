# Basic Pitch aus GitHub, ohne Docker

[Basic Pitch von Spotify](https://github.com/spotify/basic-pitch/tree/v0.4.0)
wandelt Musik-Audio in MIDI-Noten mit Pitch-Bends um. Es funktioniert am
besten mit einem Instrument pro Aufnahme; keine perfekte Trennung eines
kompletten Arrangements, kein TTS oder neuer Gesangsgenerator.

Version **0.4.0**, Commit `9991303bba609a3b93089d13ec80d1d495083596`.
Status **experimental** fuer diesen Installer: keine reale Linux-/ARM-
Installation oder Inferenz bei der Entwicklung ausgefuehrt. Apache-2.0;
Abhaengigkeitslizenzen und Rechte an den Aufnahmen separat pruefen.

## Installation und Voraussetzungen

Der Menuepunkt Basic_Pitch verwendet eigene Lifecycle-Skripte statt des
Medien-Platzhalters. Zur bewussten Ausfuehrung durch den Benutzer:

```bash
bash scripts/tools/basic_pitch_install.sh --dry-run
bash scripts/tools/basic_pitch_install.sh
bash scripts/tools/basic_pitch_status.sh
bash scripts/tools/basic_pitch_doctor.sh
```

Das Paket wird aus dem gepinnten GitHub-Checkout mit `pip --no-deps` in
eine private venv installiert, nicht aus Docker und nicht als Basic-Pitch-
Paket von PyPI. Build-Abhaengigkeiten (setuptools/wheel/Cython) kommen aus
PyPI; der Git-Pin sperrt nicht deren Versionen. Der Checkout enthaelt die
kleinen vortrainierten TensorFlow-/TFLite-/ONNX-/CoreML-Modelle von Upstream.
Keine weiteren Modellpacks oder Trainingsdaten werden heruntergeladen.
Quell-/Build-Code ist Fremdcode und muss vor Ausfuehrung geprueft werden.

Normaler Linux-Benutzer, Bash, Git, Python 3.10-3.12, venv/ensurepip/SSL,
flock, realpath und uebliche GNU-Werkzeuge werden benoetigt.
Keine Docker-Installation oder Ersetzung des System-Python durch den Helper.
Die Basisinstallation ist noch **nicht fuer Inferenz betriebsbereit**.

### Fehlendes venv/ensurepip reparieren

Seit 19.10.2026 bietet der Installer das versionspassende Ubuntu-Paket an,
beispielsweise `python3.12-venv`. Abfrage: `[(j)a/(N)ein]`, Standard Nein.
Ohne Terminal keine Installation; ausdrueckliches nichtinteraktives Opt-in:

```bash
BASIC_PITCH_INSTALL_VENV_DEPS=1 bash scripts/tools/basic_pitch_install.sh --repair
```

`BASIC_PITCH_INSTALL_VENV_DEPS=0` deaktiviert die Paketinstallation.
Nur das zum gewaehlten System-Python unter `/usr/bin/python3.X` passende
Paket wird angeboten. Private Interpreter, aktive venvs und SSL-/Versionsfehler
erfordern separate Pruefung; kein System-Python wird ersetzt.
Speicherpruefung, Sperre und aktuelles Tool-Log kommen vor der Reparatur.
APT wartet begrenzt auf Paketverwaltungssperren, ohne Sperrdateien zu loeschen.
Nach Paketinstallation wird venv/ensurepip erneut geprueft; bei Fehlern
kein Clone/Build. Basic Pitch bleibt aus GitHub, ohne Docker. Die Zustimmung
gibt keine TensorFlow-Laufzeit oder Audioverarbeitung frei. Die Runtime lehnt
Python 3.12 weiterhin vor Downloads ab.
Vorhandene fremde/beschaedigte venvs werden nicht automatisch geloescht.
Die Workspace-Rollback-Logik bleibt unveraendert; gemeinsam genutzte
venv-Systempakete werden darueber nicht automatisch entfernt.

## Optionale Runtime fuer lokale Transkription

```bash
INSTALL_HEAVY_TOOLS=1 BASIC_PITCH_INSTALL_RUNTIME=1 \
  BASIC_PITCH_PYTHON_BIN=python3.11 \
  bash scripts/tools/basic_pitch_install.sh
```

Python 3.10 oder 3.11 muss bereits vorhanden sein. Mit
`BASIC_PITCH_PYTHON_BIN` laesst sich auch eine bereits vorhandene isolierte
CPython-Installation auswaehlen. Python 3.12 wird fuer diese Runtime vor
dem Download abgelehnt: der Upstream-Pin verwendet TensorFlow <2.15.1.
Kein automatischer Python-/Treiber-/CUDA-Umbau.

Die Upstream-Marker waehlen unter Linux/Python 3.10 TFLite Runtime und unter
Python 3.11 TensorFlow. Weitere Laufzeitpakete kommen explizit aus PyPI.
NumPy 1.26.4 und librosa 0.10.2.post1 sind als Kompatibilitaetsgrenzen
gepinnt. Native grosse Pakete (NumPy/SciPy/Numba/llvmlite/TF/TFLite) sind auf
Wheels beschraenkt: fehlen passende Wheels, Abbruch statt schwerem Source-Build.
Andere, teils reine Python-Pakete koennen per Build-Isolation gebaut werden.
Dies ist kein vollstaendiges Hash-Lockfile; transitive Versionen sind nicht
vollstaendig reproduzierbar. Abhaengigkeitskonflikte bleiben echte Fehler.

`pip check` prueft Abhaengigkeitsmetadaten, nicht Bibliotheksladbarkeit oder
Audioqualitaet. Modelle, CLI und TensorFlow werden dabei nicht importiert
oder ausgefuehrt. Keine Audioverarbeitung und kein Service-/Browserstart.

## Spaetere Nutzung

Erst nach erfolgreicher Runtime-Installation, bewusst durch den Benutzer:

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
"$ROOT/tools/basic_pitch/venv/bin/basic-pitch" ./midi-ausgabe ./eigene-aufnahme.wav
```

Der Aufruf fuehrt echte lokale Inferenz aus und schreibt MIDI in den
Ausgabeordner. Keine fremden/vertraulichen Aufnahmen ohne Berechtigung
verarbeiten. MIDI enthaelt Notenereignisse, keine Stimme oder Samples.
Fuer das Abspielen z. B. einen separaten [Sfizz-Sampler](sfizz.md) mit
eigenen lizenzierten SFZ-Instrumenten verwenden.

## Ressourcen und Hosts

| Modus/Host | Schutzgrenze oder Einschraenkung, kein Benchmark |
|---|---|
| Basispaket | 1 GiB Gesamt-RAM, 512 MiB verfuegbar; 2 GiB freie Ziel-Disk und messbares Windows-C: |
| Runtime | 4 GiB Gesamt-RAM, 2 GiB verfuegbar; 8 GiB freie Ziel-Disk und messbares Windows-C: |
| MiniPC/WSL2 | Linux x86_64, CPU-Pfad; Windows-C: kann trotz grosser Linux-Freianzeige der Engpass sein |
| Oracle VPS/Kubernetes | CPU-Transkription vorgesehen, kein automatisches Deployment/Netzwerkfreigabe |
| Raspberry Pi ARM64 | Basispaketpfad vorgesehen; TF-/TFLite-/sonstige Wheel-Verfuegbarkeit separat pruefen, ungetestet |
| GPU-Workstation | Keine GPU erforderlich, keine automatische GPU-/CUDA-Einrichtung |
| Windows/macOS | Upstream unterstuetzt eigene Umgebungen; dieser Helper ist fuer Linux, kein nativer Desktop-Installer |

Reserven sind Installer-Policy, keine Aussage ueber maximale Dateigroesse
oder Laufzeit. Lange Audiojobs separat seriell ueber die Setup-Queue planen.

## Status, Update und Entfernen

Dateien liegen unter
`${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/basic_pitch/`:
`source/`, `venv/`, `source-built` und `operation.lock`.
Logs unter dem privaten User-Workspace in `install_logs/`; Diskmessung
vor/nach Installation. Keine Schluessel oder Nutzdaten im Setup-Repository.

```bash
bash scripts/tools/basic_pitch_update.sh
bash scripts/tools/basic_pitch_install.sh --repair
bash scripts/tools/basic_pitch_uninstall.sh
```

Update/Repair bleibt auf demselben Quell-Pin. Fuer Runtime auch dort die
Opt-in-Variablen setzen; ohne diese wird nur das Basispaket registriert.
`installed` bezeichnet die gepruefte Paketinstallation;
`runtime_dependencies` nur Runtime plus erfolgreiches `pip check`.
`inference_tested` bleibt `false`. Doctor kann bei konsistentem Basispaket
Erfolg melden, ohne dass die CLI bereits verwendbar ist.

Fremde/geaenderte Quellordner werden nicht geloescht/zurueckgesetzt.
Eine Sperre verhindert parallele Operationen; Symlink-/Repo-interne und
nicht normalisierte Datenpfade werden abgelehnt. Deinstallation deaktiviert
nur den Setup-Marker und bewahrt Quellen, venv, Modelle, Nutzdaten und Logs.
Die Anwendung wird dadurch nicht physisch entfernt. Der Installer wurde
mit synthetischen Offline-Tests, nicht an der Benutzer-WSL, geprueft.
