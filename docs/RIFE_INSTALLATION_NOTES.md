# RIFE: NumPy-Build scheitert unter Python 3.12

RIFE verlangt laut
[Upstream-requirements.txt](https://github.com/hzwer/ECCV2022-RIFE/blob/main/requirements.txt) NumPy
<=1.23.5. Im Log wurde dieses alte NumPy unter Python 3.12 aus Quellen gebaut; der isolierte Build
endet mit dem entfernten `pkgutil.ImpImporter`. Ein erneutes Upgrade von pip/setuptools in der venv
behebt diese Kombination nicht verlaesslich.

Der Installer waehlt jetzt Python 3.10/3.11 und verlangt ein NumPy-Wheel. Ohne passenden Interpreter
kann der echte Installationslauf jetzt nach Heavy-Opt-in und Speicherpruefung ein isoliertes CPython
3.11.17 aus `python/cpython`, Tag `v3.11.17`, bauen. Die Version stammt aus der
[Python-3.11-Releasereihe](https://www.python.org/downloads/source/). Ziel ist
`/opt/openclaw-python/python-3.11.17`. Es wird `make altinstall` verwendet, kein Austausch von
`/usr/bin/python3` und kein globaler PATH-Umbau. Vorhandene isolierte Python-3.11-Installationen
unter `/opt/openclaw-python` werden ebenfalls gesucht. System-Python bleibt unveraendert.

```bash
bash scripts/tools/rife_install.sh --check
RIFE_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/rife_install.sh
```

`--check` bleibt ohne kompatibles Python erfolglos. `--dry-run` zeigt dagegen auch den fehlenden
Interpreter als geplanten Build, ohne sudo/Download/Build. Ein explizit gesetztes, ungeeignetes
`RIFE_PYTHON_BIN` wird nie automatisch ersetzt. Eine inkompatible oder kaputte `.venv` wird in
`venv-backup.*` gesichert und neu erstellt. Modellgewichte werden nicht geloescht oder
heruntergeladen.

Standard ist CPU-PyTorch, um ungewollte CUDA-Paketdownloads zu vermeiden. Fuer GPU-Betrieb kann
`RIFE_TORCH_INDEX_URL` explizit auf einen passenden offiziellen PyTorch-Wheel-Index gesetzt werden.
CUDA/Treiber-Kompatibilitaet muss am Zielhost geprueft werden. Der Importtest ist kein
Interpolationstest. Der Installer prueft 40 GiB Linux-Speicher und bei erkennbarer WSL mindestens 20
GiB Windows-C:-Reserve vor dem Python-Build. Andere Cache-Laufwerke und RAM/Swap zusaetzlich
pruefen. Bestehende kompatible venvs werden wiederverwendet; ein Wechsel CPU/GPU in einer
bestehenden Umgebung braucht einen bewussten Neuaufbau, da bereits installierte torch-Pakete nicht
automatisch ersetzt werden.

## Isolierter Python-Build

Standard: zwei Build-Jobs. Fuer schwache Rechner `CPYTHON_BUILD_JOBS=1` setzen. sudo wird vor dem
langen Build geprueft; `make altinstall` arbeitet anschliessend im benutzereigenen Versionsordner
ohne spaetes sudo. Build-Ausgaben gehen ins Installationslog, nicht in den zurueckgegebenen
Interpreterpfad. Ein Lock verhindert parallele Builds desselben Interpreters durch denselben
Benutzer. Build-Verzeichnisse unter `~/.openclaw_ultimate_user_data/builds` bleiben zur Diagnose
erhalten und belegen zusaetzlichen Speicher. Der Interpreter wird bei RIFE-Deinstallation nicht
entfernt, da andere Tools ihn verwenden koennen.

TODO: echter CPython-/RIFE-Build unter Ubuntu/WSL und auf ARM sowie GPU-Test. Die Regressionstests
verwenden Mocks; Codex installiert nichts in der WSL.

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
python3 -I -B scripts/tool_commands.py show rife
```

### SSH-Aktionen: `rife`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`RIFE` (ID `rife`) waehlen und die Einzelfreigaben lesen.
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
