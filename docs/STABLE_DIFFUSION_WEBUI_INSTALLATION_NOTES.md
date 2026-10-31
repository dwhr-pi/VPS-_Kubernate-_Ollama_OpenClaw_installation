# Stable Diffusion WebUI: Pillow/tokenizers scheitern

Das Log zeigt einen `tokenizers`-Source-Build unter Python 3.12 ohne Rust-Compiler. Auch Pillow
scheitert; dessen konkrete Fehlermeldung ist im Ausschnitt nicht enthalten. Rust nachzuinstallieren
allein belegt deshalb keinen erfolgreichen Fix.

Der Installer waehlt jetzt Python 3.10/3.11 passend zum
[Upstream-Launcher](https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/modules/launch_utils.py).
Er bereitet mit `launch.py --exit` die Umgebung vor. Fehlgeschlagene Installation oder fehlende
Imports von torch, torchvision, Pillow oder tokenizers brechen ab; das bisherige
`pip install ... || true` entfaellt.

```bash
bash scripts/tools/stable_diffusion_webui_install.sh --check
SD_WEBUI_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/stable_diffusion_webui_install.sh
```

Vorhandenes isoliertes Python unter `/opt/openclaw-python` kann ebenfalls genutzt werden. Ohne
kompatiblen Interpreter stoppt der Installer vor Paketinstallation und Clone. Er installiert kein
Fremd-Python und ersetzt das System-Python nicht.

Eine inkompatible oder unvollstaendige `venv` wird in einen eindeutigen `venv-backup.*`-Ordner
verschoben und neu erstellt. Modelle, Outputs und alte Umgebungsdateien werden nicht geloescht. Zur
Rueckkehr die neue Umgebung zuerst sichern und die gesicherte alte `venv` manuell an ihren alten
Platz verschieben.

Mindestens 40 GB Linux-Speicher werden geprueft; unter WSL muss auch der Windows- Datentraeger genug
Platz fuer die VHDX haben. Abhaengigkeiten wie PyTorch koennen mehrere GB herunterladen.
Vorbereitung startet weder Server noch SD-Modell- Download. Der CUDA-Test wird dabei uebersprungen:
GPU und Bildgenerierung sind erst nach einem manuellen Start mit eigenem Modell getestet.

```bash
cd /opt/stable-diffusion-webui
venv/bin/python launch.py --server-name 127.0.0.1 --no-download-sd-model
```
