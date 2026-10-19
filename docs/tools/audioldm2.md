# AudioLDM2 aus GitHub ohne Docker

Stand 16.10.2026. [Quelle](https://github.com/haoheliu/AudioLDM2),
Pin `b5786c5dc0ae8f766337fdc1b67ab6046586d14d`.
Paketversion laut setup.py: **0.1.0**, kein automatisch aktuelles latest.

**Nur Basispaket ohne Laufzeitabhaengigkeiten. Noch keine betriebsbereite
Audio-/Musikgenerierung.** AudioLDM2 ist ein Text-to-Audio-Projekt,
kein automatisch fertiges Hoerbuch- oder Voice-Cloning-Studio.

## 1. Installation

Unter Tools AudioLDM2 auswaehlen oder im Setup-Verzeichnis:

```bash
bash scripts/tools/audioldm2_install.sh --dry-run
bash scripts/tools/audioldm2_install.sh
bash scripts/tools/audioldm2_status.sh
bash scripts/tools/audioldm2_doctor.sh
```

Der Installer laedt den festen GitHub-Commit und baut das lokale Paket
mit `--no-deps` in einer privaten venv. Keine schwere Legacy-Aufloesung,
keine Torch-/CUDA-/Treiberinstallation, keine Checkpoints oder Demo.
Build-Werkzeuge wie setuptools kommen von PyPI; AudioLDM2 selbst aus GitHub.
Docker ist nicht erforderlich.

```text
~/.openclaw_ultimate_user_data/tools/audioldm2/source/
~/.openclaw_ultimate_user_data/tools/audioldm2/venv/
~/.openclaw_ultimate_user_data/tools/audioldm2/source-built
~/.openclaw_ultimate_user_data/install_logs/audioldm2_*.log
```

Voraussetzungen: normaler Linux-Benutzer, x86_64/ARM64, Git, flock und
Python 3.10-3.12 mit SSL/venv/ensurepip. Ubuntu 3.12 eignet sich hier
**nur fuer das abhaengigkeitsfreie Paket**, nicht fuer die alte NumPy-Vorgabe.
Fuer ein anderes vorhandenes Python:

```bash
AUDIOLDM2_PYTHON_BIN=python3.11 bash scripts/tools/audioldm2_install.sh
```

Bei fehlendem venv/ensurepip bietet der Installer seit 19.10.2026 das
versionspassende Ubuntu-Paket an, beispielsweise `python3.12-venv`.
Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal keine Installation.
Ausdrueckliches nichtinteraktives Opt-in:

```bash
AUDIOLDM2_INSTALL_VENV_DEPS=1 bash scripts/tools/audioldm2_install.sh --repair
```

`AUDIOLDM2_INSTALL_VENV_DEPS=0` deaktiviert die Paketinstallation.
Nur das zum gewaehlten System-Python unter `/usr/bin/python3.X` passende
Paket wird angeboten. Private Interpreter, aktive venvs und SSL-/Versionsfehler
erfordern separate Pruefung; kein System-Python wird ersetzt.
Speicherpruefung, Sperre und aktuelles Tool-Log kommen vor der Reparatur.
APT wartet begrenzt auf Paketverwaltungssperren, ohne Sperrdateien zu loeschen.
Nach Paketinstallation wird venv/ensurepip erneut geprueft; bei Fehlern
kein Clone/Build. AudioLDM2 bleibt aus GitHub, ohne Docker. Die Zustimmung
hebt die Sperre der Legacy-Runtime nicht auf und startet keine Modelle.

Reserve: 1 GiB RAM gesamt, 512 MiB aktuell verfuegbar, 2 GiB freie Disk
und unter WSL soweit messbare Windows-C:-Reserve. Das ist kein Modellbudget.
Lock/Logs und Vorher-/Nachher-Diskmessung sind integriert. Dry-Run ohne
Dateierstellung oder Downloads. Fremde Checkouts/venvs bleiben unangetastet.

## 2. Warum keine automatische Vollinstallation?

Die gepinnte setup.py verlangt unter anderem:

- numpy<=1.23.5: kein geeigneter Python-3.12-Wheel-Pfad.
- librosa==0.9.2, transformers==4.30.2 und gradio<4: aeltere Laufzeit.
- Torch, torchaudio und torchvision: hardware- und versionsabhaengig.

Die separate requirements.txt nennt ausserdem einen **ungepinnten
Diffusers-Git-Branch** und einen alten CUDA-11.3-Zusatzindex. Blindes
Installieren kann einen heutigen GPU-/Python-Stack unbrauchbar machen.
Der Installer ersetzt deshalb auch mit `AUDIOLDM2_INSTALL_RUNTIME=1`
nicht heimlich diese Grenzen, sondern bricht mit Erklaerung ab.

Naechster separat zu pruefender Schritt: eine dedizierte Python-3.10/3.11-
Runtime mit kompatiblen NumPy-/Torch-/torchaudio-/torchvision- und Diffusers-
Pins, aktuellen Sicherheitschecks und eigenem Inferenztest. Kein globales
pip install und kein ungeprueftes Absenken von Systembibliotheken.
Ein moderner Diffusers-Pfad waere eine eigene Integration, nicht einfach
derselbe getestete Upstream-Installer.

## 3. Modell- und WebUI-Warnungen

Modellaufbau kann Checkpoints und weitere Modellkomponenten nachladen.
Der Installer importiert AudioLDM2 oder Torch nicht, startet nicht einmal
CLI --help und verarbeitet keine Audiodatei. Hub-/Transformers-Offlineflags
und entfernte Hub-Tokenvariablen gelten nur im Installer-Unterprozess,
nicht als globale Betriebssystem-Netzwerksandbox.

**Upstreams app.py startet am Pin mit share=True. Nicht ungeprueft aufrufen!**
Fuer einen spaeteren sicheren Start muessen Share deaktiviert, Loopback-
Bindung erzwungen, Portkonflikte/Auth geprueft und Runtime/Modelle bewusst
freigegeben werden. Kein sofort ausfuehrbarer WebUI-Startbefehl in dieser
Anleitung. Unser Installer oeffnet keinen Port; Registry-Portliste leer.

## 4. Lizenzangaben widersprechen sich

Die [LICENSE am Pin](https://github.com/haoheliu/AudioLDM2/blob/b5786c5dc0ae8f766337fdc1b67ab6046586d14d/LICENSE)
enthaelt **CC BY-NC-SA 4.0**, waehrend
[setup.py](https://github.com/haoheliu/AudioLDM2/blob/b5786c5dc0ae8f766337fdc1b67ab6046586d14d/setup.py)
MIT nennt. Diese Integration loest diesen Widerspruch nicht auf.
Nicht aufgrund der Paketmetadaten kommerzielle Nutzung freigeben.
Code-/Checkpoint-/Datensatzbedingungen vor Nutzung einzeln klaeren.
Eigene/lizenzierte Texte und autorisierte Aufnahmen verwenden,
KI-Ausgaben kennzeichnen und private Audiodaten nicht ins Repo legen.

## 5. Zielhosts und Wartung

| Zielhost | Einordnung |
|---|---|
| MiniPC / WSL2 | Basispaket leicht; keine Zusage fuer Legacy-Runtime |
| RPi5 / Oracle ARM | Paketbau moeglich, alte Wheels/GPU-Inferenz offen |
| Oracle VPS | Steuerung/Queue statt oeffentlicher Audio-WebUI |
| Gaming-PC / RTX 5080 | alten Stack nicht blind auf Blackwell uebertragen |
| Dual Xeon | viele Kerne ersetzen nicht GPU/VRAM und kompatible Pakete |
| Kubernetes | kein Deployment durch diesen Installer |

Runtime-RAM/VRAM/Disk haengen von Checkpoint, Batch, Precision und Cliplaenge
ab. Keine pauschale Echtzeit-/VRAM-Zusage oder beliebige Audiolaenge.
Nur einen schweren Job gleichzeitig vorsehen. Windows/macOS nativ sind hier
nicht getestet. Modelle, Outputs und Caches benoetigen zusaetzliche Reserve.

```bash
bash scripts/tools/audioldm2_update.sh --dry-run
bash scripts/tools/audioldm2_update.sh
bash scripts/tools/audioldm2_install.sh --repair
bash scripts/tools/audioldm2_uninstall.sh
```

Update behaelt denselben Pin; kein Reset/Clean/Loeschen lokaler Aenderungen.
Doctor prueft nur Version, venv, Quellursprung und Pin. Ein volles pip check
waere fuer das absichtlich abhaengigkeitsfreie Paket irrefuehrend.
Status meldet Runtime-Abhaengigkeiten/Modelle/Inferenz weiterhin false.
Uninstall entfernt nur den Marker, nicht Quelle, venv, Modelle oder Audios.

Offen: Lizenzklaerung, Legacy-Python-/Dependency-Lock, sicherer Start ohne
Sharing, Modellrevisionen/Hashes, Inferenz-/Backup-/Restore-/Queue-Test.
Repository-Tests sind synthetisch, ohne reale Installation oder Gewichte.

Weitere Quellen:
[requirements.txt](https://github.com/haoheliu/AudioLDM2/blob/b5786c5dc0ae8f766337fdc1b67ab6046586d14d/requirements.txt),
[app.py](https://github.com/haoheliu/AudioLDM2/blob/b5786c5dc0ae8f766337fdc1b67ab6046586d14d/app.py).
