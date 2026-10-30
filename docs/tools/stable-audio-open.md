# Stable Audio Open: GitHub statt Docker

Das Setup installiert den Quellcode von
[stable-audio-tools](https://github.com/Stability-AI/stable-audio-tools/tree/3241adba4fc2a85cf5b29d9eb68d42f40a28e820).
Das ist die Trainings-/Inferenzbibliothek fuer unter anderem Stable Audio Open, nicht bereits das
Modell. Paketversion: `0.0.20`, Commit: `3241adba4fc2a85cf5b29d9eb68d42f40a28e820`. Status:
**experimental**. Keine automatische Installation beim Start des Setups.

## Bewusst installieren

```bash
bash scripts/tools/stable_audio_open_install.sh --dry-run
# Automatische Auswahl; fehlendes Python wird zum privaten Build angeboten:
bash scripts/tools/stable_audio_open_install.sh
# Alternativ vorhandenen Interpreter explizit festlegen:
STABLE_AUDIO_OPEN_PYTHON_BIN=python3.10 bash scripts/tools/stable_audio_open_install.sh
bash scripts/tools/stable_audio_open_status.sh
bash scripts/tools/stable_audio_open_doctor.sh
bash scripts/tools/stable_audio_open_install.sh --repair
bash scripts/tools/stable_audio_open_update.sh
```

Ohne Variable werden das private CPython, `python3.10` und ein kompatibles `python3` geprueft,
einschliesslich venv/ensurepip/SSL. Der gepinnte
[pyproject.toml](https://github.com/Stability-AI/stable-audio-tools/blob/3241adba4fc2a85cf5b29d9eb68d42f40a28e820/pyproject.toml)
verlangt **Python >=3.10,<3.11**. Python 3.11 und Ubuntu-24.04-Python 3.12 werden deshalb abgelehnt,
auch bei der Basisinstallation. Kein `--ignore-requires-python`, kein Austausch des System-Python,
keine ungefragte Fremd-Python-/apt-Installation. Ein explizit gesetzter unpassender Interpreter wird
nicht still ersetzt.

### Fehlendes Python automatisch vorbereiten

Der Installer bietet bei fehlendem Python einen bestaetigten Quellbuild von
[CPython 3.10.22](https://github.com/python/cpython/releases/tag/v3.10.22) an, fest gepinnt auf
`acb4dc12b6df8615af7b43120ef601e04072f7d2`. `STABLE_AUDIO_OPEN_BUILD_PYTHON=1` gibt diesen Build
bewusst auch ohne Rueckfrage frei; `0` sperrt ihn. Ohne Terminal und ohne Freigabe wird nichts
gebaut. Dry-Run, Status, Doctor und Deaktivierung bauen niemals Python.

Ziel: `tools/stable_audio_open/runtime/python-3.10.22/` innerhalb des privaten User-Workspace. Keine
/usr/bin-Aenderung, kein globaler PATH, kein Docker. `make altinstall` laeuft ohne sudo; sudo wird
nur fuer eventuell fehlende Ubuntu-/Debian-Buildbibliotheken benoetigt und vor dem langen Build
geprueft. Andere Distributionen muessen fehlende Bibliotheken selbst bereitstellen.

Buildreserve: 4 GiB Gesamt-RAM, 2 GiB aktuell frei, 8 GiB Disk und unter WSL 8 GiB
Windows-Host-Reserve. Ein Buildjob, optional `CPYTHON_BUILD_JOBS=2`. Ressourcenchecks und Tool-Lock
laufen vor Download/Build. Diagnosequellen und Logs bleiben bei Fehlern erhalten. Unvollstaendige
vorhandene Python-Ziele werden nicht ueberschrieben; nach manueller Pruefung erneut versuchen. Ein
passender bereits installierter Interpreter wird ohne Neubau verwendet.

Python 3.10 ist eine alte Kompatibilitaetslinie; dieser Pin ist keine Zusage zukuenftiger
Sicherheitswartung. Eine Migration des Audio-Pakets auf neuere Python-Versionen bleibt separat zu
testen.

Anwendung aus GitHub, lokale Paketinstallation mit `--no-deps` in privater venv. **Nur Basispaket,
noch keine funktionsfaehige Audiogenerierung.** Keine Docker-Installation, Gewichte, HF-Anmeldung,
Demo, WebUI, Dienste, Training oder offenen Ports. Pip kann isolierte Build-Werkzeuge aus PyPI
laden; GitHub-Quelle bedeutet nicht, dass alle Build-Abhaengigkeiten ebenfalls aus GitHub stammen.
Ein vollstaendig gehashter Offline-Build ist noch offen.

## Pfade und Schutz

Basis: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/stable_audio_open/`.
Darin liegen `source/`, `venv/`, Lock und Setup-Marker. Logs liegen im zugehoerigen `install_logs/`.
Root/Symlink-/Repo-interne Datenpfade werden abgelehnt. Bestehende fremde oder geaenderte Quellen
werden nicht geloescht, zurueckgesetzt oder ungefragt ueberschrieben. Updates bauen denselben Pin.

Voraussetzungen: Linux x86_64/ARM64, normaler Benutzer, Bash, Git, flock, realpath und Python 3.10.
Mindestreserve nur fuer das Basispaket: 1 GiB Gesamt-RAM, 512 MiB aktuell frei, 2 GiB freie Disk und
bei messbarem WSL-Host 2 GiB Windows-C:-Reserve. Vorher/nachher wird freier Dateisystemplatz
protokolliert. Das ist keine Hardwarezusage fuer Inferenz: MiniPC/RPi5/Oracle-VPS sind hier nur
Basisvorbereitung; GPU-Workstation und Kubernetes benoetigen eine gesonderte
Runtime-/Speicherplanung.

## Noch offene GPU-Laufzeit

Der Pin verlangt unter anderem `torch==2.7.1`, `torchaudio==2.7.1`, `PyWavelets==1.4.1` und
`sentencepiece==0.1.99`. Der Upstream-uv-Pfad waehlt auf Linux x86_64 einen CUDA-12.6-Index. Der
Basisinstaller fuehrt weder `uv sync` noch die Runtime-Aufloesung aus und verspricht keine
GPU-/RTX-5080-Kompatibilitaet. `STABLE_AUDIO_OPEN_INSTALL_RUNTIME=1` wird mit einer klaren
Fehlermeldung abgelehnt, nicht still ignoriert.

Naechste Integrationsarbeit: getestete GPU-/Treiber-/Wheel-Kombination, explizites Ressourcenbudget,
erlaubte Modellvariante, kontrollierter Modell-Download und ein echter Audiotest. Training/UI sind
separate Extras; insbesondere keine ungefragte Weights-&-Biases-Anmeldung oder oeffentliche
Gradio-`--share`-Freigabe. HF-Token werden im Installer- Subprozess entfernt und
Hub-/Transformers-Offline-Flags gesetzt. Das ersetzt keine Netzwerksandbox.

Status `installed` bedeutet nur konsistentes GitHub-Basispaket. `runtime_dependencies`,
`models_checked`, `inference_tested` bleiben `false`. Doctor prueft Quell-Pin und Paketmetadaten
ohne SDK-/Torch-Import. Das Setup fuegt keinen allgemeinen Bereitschaftseintrag fuer Inferenz hinzu.

```bash
bash scripts/tools/stable_audio_open_uninstall.sh
```

Deaktiviert nur den Setup-Marker. Quellen, venv, eigene Audios, Modelle/Caches und Logs bleiben
erhalten; keine vollstaendige Loeschung.

## Lizenz und Tests

Bibliothekscode:
[MIT](https://github.com/Stability-AI/stable-audio-tools/blob/3241adba4fc2a85cf5b29d9eb68d42f40a28e820/LICENSE).
Die **Modelllizenz** ist davon getrennt: Bedingungen und etwaige Zugangs- oder kommerzielle
Beschraenkungen fuer die konkrete Variante auf ihrer
[offiziellen Modellkarte](https://huggingface.co/stabilityai/stable-audio-open-1.0) pruefen und
selbst akzeptieren. Keine pauschale kommerzielle Freigabe. Nur berechtigte Audiodaten verwenden und
synthetische Inhalte kennzeichnen.

Offline-Tests simulieren Paketinstallation und pruefen Registry, Menue, Pfade, Fehler- und
Ressourcenbehandlung. Kein echter Build, Modelltest oder Zugriff auf die WSL des Benutzers wurde
dafuer ausgefuehrt. Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
