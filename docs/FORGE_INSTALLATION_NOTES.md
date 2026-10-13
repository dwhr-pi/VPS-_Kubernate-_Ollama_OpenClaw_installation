# Forge: Multiple top-level packages

Der generische Installer versuchte `pip install -e` auf dem Forge-Root.
Forge ist eine Webanwendung mit vielen Verzeichnissen; dieser Root ist fuer
diesen Installationsweg ungeeignet. Der setuptools-Fehler ist deshalb ein
Installerfehler. Ubuntu 24.04 verwendet zudem Python 3.12.

Der neue Installer waehlt Python 3.10/3.11 und verwendet Forge's
[Upstream-Vorbereitung](https://github.com/lllyasviel/stable-diffusion-webui-forge/blob/main/modules/launch_utils.py)
mit `launch.py --exit`. Er prueft Abhaengigkeiten, startet keinen Webserver
und fordert keinen SD-Modell-Download an. PyTorch und andere Abhaengigkeiten
werden von Upstream heruntergeladen; das kann mehrere GB beanspruchen.

```bash
bash scripts/tools/stable_diffusion_webui_forge_install.sh --check
# Wenn ein passendes Python bereits vorhanden ist:
FORGE_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/stable_diffusion_webui_forge_install.sh
```

Der Installer sucht auch vorhandene isolierte Python-3.11-Installationen unter
`/opt/openclaw-python`. Er baut in diesem Schritt kein weiteres Python und
ersetzt das System-Python nicht. Ohne kompatiblen Interpreter stoppt er frueh.
`--dry-run` prueft Python und zeigt den Plan ohne Installation.

Die neue Umgebung liegt unter `/opt/stable_diffusion_webui_forge/venv`.
Die `.venv` aus dem fehlgeschlagenen Versuch bleibt erhalten; vorhandene Modelle
und Outputs werden nicht geloescht. Eine inkompatible vorhandene `venv` wird
nicht automatisch ersetzt.

Mindestens 40 GB freier Linux-Speicher werden geprueft; unter WSL zusaetzlich
den Windows-Datentraeger mit der VHDX beachten. Die Installationsvorbereitung
ueberspringt den CUDA-Test und ist daher kein Nachweis fuer GPU-/Bildgenerierung.
Fuer den manuellen Start sind passende GPU-Treiber und ein Modell erforderlich:

```bash
cd /opt/stable_diffusion_webui_forge
venv/bin/python launch.py --server-name 127.0.0.1 --no-download-sd-model
```
