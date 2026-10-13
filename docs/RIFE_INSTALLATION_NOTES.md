# RIFE: NumPy-Build scheitert unter Python 3.12

RIFE verlangt laut [Upstream-requirements.txt](https://github.com/hzwer/ECCV2022-RIFE/blob/main/requirements.txt)
NumPy <=1.23.5. Im Log wurde dieses alte NumPy unter Python 3.12 aus Quellen
gebaut; der isolierte Build endet mit dem entfernten `pkgutil.ImpImporter`.
Ein erneutes Upgrade von pip/setuptools in der venv behebt diese Kombination
nicht verlaesslich.

Der Installer waehlt jetzt Python 3.10/3.11 und verlangt ein NumPy-Wheel.
Ohne passenden Interpreter stoppt er vor Clone und Paketinstallation.
Vorhandene isolierte Python-3.11-Installationen unter `/opt/openclaw-python`
werden ebenfalls gesucht. System-Python bleibt unveraendert.

```bash
bash scripts/tools/rife_install.sh --check
RIFE_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/rife_install.sh
```

`--dry-run` prueft Python und zeigt den Plan. Eine inkompatible oder kaputte
`.venv` wird in `venv-backup.*` gesichert und neu erstellt. Modellgewichte
werden nicht geloescht oder heruntergeladen.

Standard ist CPU-PyTorch, um ungewollte CUDA-Paketdownloads zu vermeiden.
Fuer GPU-Betrieb kann `RIFE_TORCH_INDEX_URL` explizit auf einen passenden
offiziellen PyTorch-Wheel-Index gesetzt werden. CUDA/Treiber-Kompatibilitaet
muss am Zielhost geprueft werden. Der Importtest ist kein Interpolationstest.
Der Installer prueft 40 GB Linux-Speicher; unter WSL auch den Windows-Platz
fuer VHDX-Wachstum beachten. Bestehende kompatible venvs werden wiederverwendet;
ein Wechsel CPU/GPU in einer bestehenden Umgebung braucht einen bewussten
Neuaufbau, da bereits installierte torch-Pakete nicht automatisch ersetzt werden.
