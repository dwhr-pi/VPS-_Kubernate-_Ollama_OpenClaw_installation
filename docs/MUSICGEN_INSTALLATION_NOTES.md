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
