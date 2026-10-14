# RIFE: NumPy-Build scheitert unter Python 3.12

RIFE verlangt laut [Upstream-requirements.txt](https://github.com/hzwer/ECCV2022-RIFE/blob/main/requirements.txt)
NumPy <=1.23.5. Im Log wurde dieses alte NumPy unter Python 3.12 aus Quellen
gebaut; der isolierte Build endet mit dem entfernten `pkgutil.ImpImporter`.
Ein erneutes Upgrade von pip/setuptools in der venv behebt diese Kombination
nicht verlaesslich.

Der Installer waehlt jetzt Python 3.10/3.11 und verlangt ein NumPy-Wheel.
Ohne passenden Interpreter kann der echte Installationslauf jetzt nach
Heavy-Opt-in und Speicherpruefung ein isoliertes CPython 3.11.17 aus
`python/cpython`, Tag `v3.11.17`, bauen. Die Version stammt aus der
[Python-3.11-Releasereihe](https://www.python.org/downloads/source/).
Ziel ist `/opt/openclaw-python/python-3.11.17`. Es wird `make altinstall`
verwendet, kein Austausch von `/usr/bin/python3` und kein globaler PATH-Umbau.
Vorhandene isolierte Python-3.11-Installationen unter `/opt/openclaw-python`
werden ebenfalls gesucht. System-Python bleibt unveraendert.

```bash
bash scripts/tools/rife_install.sh --check
RIFE_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/rife_install.sh
```

`--check` bleibt ohne kompatibles Python erfolglos. `--dry-run` zeigt dagegen
auch den fehlenden Interpreter als geplanten Build, ohne sudo/Download/Build.
Ein explizit gesetztes, ungeeignetes `RIFE_PYTHON_BIN` wird nie automatisch
ersetzt. Eine inkompatible oder kaputte
`.venv` wird in `venv-backup.*` gesichert und neu erstellt. Modellgewichte
werden nicht geloescht oder heruntergeladen.

Standard ist CPU-PyTorch, um ungewollte CUDA-Paketdownloads zu vermeiden.
Fuer GPU-Betrieb kann `RIFE_TORCH_INDEX_URL` explizit auf einen passenden
offiziellen PyTorch-Wheel-Index gesetzt werden. CUDA/Treiber-Kompatibilitaet
muss am Zielhost geprueft werden. Der Importtest ist kein Interpolationstest.
Der Installer prueft 40 GiB Linux-Speicher und bei erkennbarer WSL mindestens
20 GiB Windows-C:-Reserve vor dem Python-Build. Andere Cache-Laufwerke und
RAM/Swap zusaetzlich pruefen. Bestehende kompatible venvs werden wiederverwendet;
ein Wechsel CPU/GPU in einer bestehenden Umgebung braucht einen bewussten
Neuaufbau, da bereits installierte torch-Pakete nicht automatisch ersetzt werden.

## Isolierter Python-Build

Standard: zwei Build-Jobs. Fuer schwache Rechner `CPYTHON_BUILD_JOBS=1` setzen.
sudo wird vor dem langen Build geprueft; `make altinstall` arbeitet anschliessend
im benutzereigenen Versionsordner ohne spaetes sudo. Build-Ausgaben gehen ins
Installationslog, nicht in den zurueckgegebenen Interpreterpfad. Ein Lock
verhindert parallele Builds desselben Interpreters durch denselben Benutzer.
Build-Verzeichnisse unter `~/.openclaw_ultimate_user_data/builds` bleiben zur
Diagnose erhalten und belegen zusaetzlichen Speicher. Der Interpreter wird bei
RIFE-Deinstallation nicht entfernt, da andere Tools ihn verwenden koennen.

TODO: echter CPython-/RIFE-Build unter Ubuntu/WSL und auf ARM sowie GPU-Test.
Die Regressionstests verwenden Mocks; Codex installiert nichts in der WSL.
