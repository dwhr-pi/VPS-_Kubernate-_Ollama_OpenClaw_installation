# ACE-Step 1.5 aus GitHub, ohne Docker

ACE-Step 1.5 ist ein Musikgenerierungsprojekt, kein einfacher CPU-TTS-Dienst. Quelle:
[ace-step/ACE-Step-1.5, Git-Tag v0.1.8](https://github.com/ace-step/ACE-Step-1.5/tree/v0.1.8),
Commit `dce621408bee8c31b4fcf4811682eb9359e1bc94`. Das Python-Paket heisst **ace-step**, Version
**1.5.0**. Git-Tag und Python-Paketversion sind upstream unterschiedlich benannt. Status
**experimental/gpu-heavy**, kein echter GPU-/Musiktest ausgefuehrt.

## Installation im Setup

Der Menuepunkt ACE_Step_15 nutzt eigene Skripte statt des Medien-Guards. Zur bewussten Ausfuehrung
durch den Benutzer:

```bash
bash scripts/tools/ace_step_15_install.sh --dry-run
bash scripts/tools/ace_step_15_install.sh
bash scripts/tools/ace_step_15_status.sh
bash scripts/tools/ace_step_15_doctor.sh
```

Das echte Basispaket wird aus dem gepinnten GitHub-Checkout mit `pip --no-deps` in einer privaten
venv installiert. Keine Docker-Nutzung. Hatchling als Build-Abhaengigkeit kommt von PyPI; der
Quell-Pin sperrt dessen Version nicht. Der Sparse-Checkout behaelt `acestep/`, `openrouter/`, die
benoetigten UI-JavaScript-Dateien und Paketmetadaten, schliesst jedoch Modelle, Medien und echte
`.env`-Dateien aus. Eine Build-Isolation ist keine Netzwerksandbox; Upstream-Buildcode vor
Ausfuehrung pruefen.

Voraussetzungen: normaler Linux-Benutzer, Bash, Git, Python **3.11 oder 3.12**, venv/ensurepip/SSL,
flock, realpath und uebliche GNU-Werkzeuge. `ACE_STEP_15_PYTHON_BIN` kann auf ein vorhandenes
passendes Python zeigen. Kein System-Python-Austausch, Treiber-, CUDA- oder WSL-Umbau.

### Fehlendes venv/ensurepip reparieren

Seit 19.10.2026 bietet der Installer das versionspassende Ubuntu-Paket an, beispielsweise
`python3.12-venv`. Abfrage: `[(j)a/(N)ein]`, Standard Nein. Ohne Terminal keine Installation;
ausdrueckliches nichtinteraktives Opt-in:

```bash
ACE_STEP_15_INSTALL_VENV_DEPS=1 bash scripts/tools/ace_step_15_install.sh --repair
```

`ACE_STEP_15_INSTALL_VENV_DEPS=0` deaktiviert die Paketinstallation. Nur das zum gewaehlten
System-Python unter `/usr/bin/python3.X` passende Paket wird angeboten. Python 3.10/3.13, private
Interpreter, aktive venvs und SSL-Fehler werden nicht durch Installation eines fremden venv-Pakets
repariert. Speicherpruefung, Sperre und aktuelles Tool-Log kommen vorher. APT wartet begrenzt auf
Paketverwaltungssperren, ohne Sperrdateien zu loeschen. Nach Paketinstallation wird venv/ensurepip
erneut geprueft; bei Fehlern kein Clone/Build. ACE-Step bleibt aus GitHub, ohne Docker. Die
Zustimmung gibt keine GPU-Runtime oder Modelle frei und ersetzt kein System-Python. Vorhandene
fremde/beschaedigte venvs werden nicht automatisch geloescht. Die vorhandene
Workspace-Rollback-Logik bleibt unveraendert; gemeinsam genutzte Systempakete werden dadurch nicht
automatisch entfernt.

## Was danach noch fehlt

Das Basispaket ist **keine betriebsbereite Musik-Runtime**. Keine Torch-, Training-, nano-vllm-,
Checkpoint- oder Modellinstallation, kein Gradio-/API-/OpenRouter-Start, kein HF-Login und keine
Generierung. `ACE_STEP_15_INSTALL_RUNTIME=1` wird mit einer Erklaerung abgelehnt statt blind
PyPI-Abhaengigkeiten oder einen anderen Runtime-Pfad zu installieren.

Der gepruefte Tag verlangt Python >=3.11,<3.13 und unter anderem:

| Plattform    | Upstream-Torch-Pins, keine automatisch installierte Runtime  |
| ------------ | ------------------------------------------------------------ |
| Linux x86_64 | Torch/torchaudio 2.10.0+cu128, torchvision 0.25.0+cu128      |
| Linux ARM64  | Torch/torchaudio 2.10.0+cu130, torchvision 0.25.0+cu130      |
| Windows      | Torch/torchaudio 2.7.1+cu128, torchvision 0.22.1+cu128       |
| macOS ARM64  | eigener MPS-/MLX-Pfad im Upstream, nicht durch diesen Helper |

Ausserdem verwendet das Projekt Gradio 6.2.0, Transformers >=4.51,<4.58, Diffusers >=0.37,
Training-Abhaengigkeiten sowie einen lokalen nano-vllm- Fork unter `acestep/third_parts/nano-vllm`.
Die uv-Quellenkonfiguration verweist auf diesen lokalen Fork und passende PyTorch-Indizes. Ein
beliebiges gleichnamiges PyPI-Paket ist kein gleichwertiger Ersatz. Pip uebernimmt
`tool.uv.sources`/Indizes nicht automatisch.

Fuer die vollstaendige Laufzeit ist eine eigene, hardwarebezogene Integrationspruefung erforderlich:
Treiber/Runtime/Wheels und Modelllizenzen auswaehlen, Speicherbudget pruefen, den enthaltenen Fork
und seine nativen Erweiterungen auditieren und erst dann gezielt Abhaengigkeiten einrichten. Keine
pauschalen Aussagen, dass jeder Intel-/AMD-/CPU-/ARM-Host den festgelegten CUDA-Pfad ausfuehren
kann. Der sparse Basispaket-Checkout ist kein vollstaendiger Upstream-Quickstart-Checkout fuer
`uv sync`.

Ein spaeterer Gradio-/API-Dienst darf nur auf `127.0.0.1` gebunden werden; keine Share-Tunnel oder
oeffentlichen Admin-Ports. OpenRouter ist optional, nicht lokal-kostenfrei und hier nicht
konfiguriert oder aufgerufen. Echte `.env`/Keys ausschliesslich im privaten User-Workspace
verwalten.

## Ressourcen und Zielhosts

| Modus/Host            | Installer-Reserve bzw. Einschraenkung                                                          |
| --------------------- | ---------------------------------------------------------------------------------------------- |
| Basispaket            | 1 GiB Gesamt-RAM, 512 MiB aktuell verfuegbar; 2 GiB freie Ziel-Disk und messbares Windows-C:   |
| MiniPC/WSL2           | Basispaket moeglich, Windows-C: beachten; keine zugesagte Musik-Runtime                        |
| Oracle VPS/Kubernetes | Quell-/Paketvorbereitung, kein automatisches GPU-Deployment oder Dienst                        |
| Raspberry Pi ARM64    | Nur Basispaketpfad vorgesehen; ARM64 ist nicht gleichbedeutend mit NVIDIA/cu130-Unterstuetzung |
| GPU-Workstation       | Vollstaendige Runtime, VRAM, Checkpoints und Audiolaenge separat budgetieren/testen            |
| Windows/macOS         | Separate Upstream-Pfade; dieser Helper installiert dort nicht nativ                            |

Die Reserven gelten nur fuer das Basispaket, nicht fuer Modelle, Training oder Inferenz. Keine
gemessenen Geschwindigkeits-/VRAM-Versprechen. Spaetere lange Jobs seriell ueber die Queue planen
und harte Limits gesondert konfigurieren. Kein Modell-Download im Hintergrund.

## Status und Lifecycle

```bash
bash scripts/tools/ace_step_15_update.sh
bash scripts/tools/ace_step_15_install.sh --repair
bash scripts/tools/ace_step_15_uninstall.sh
```

Dateien unter `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/ace_step_15/`:
`source/`, `venv/`, `source-built`, Sperrdatei. Logs im privaten User-Workspace unter
`install_logs/`, Disk vorher/nachher. Update/Repair bleibt auf demselben Pin; fremde/geaenderte
Quellen werden nicht geloescht oder zurueckgesetzt. Symlink-/nicht normalisierte Pfade und
User-Daten innerhalb des Setup-Repos werden abgelehnt.

`installed` bezeichnet nur gepruefte Paketmetadaten, Herkunft und unveraenderte Sparse-Quellen;
`runtime_dependencies`, `models_checked` und `inference_tested` bleiben `false`. Doctor ist kein
GPU-/Musiktest. Deinstallation deaktiviert nur den Marker, bewahrt Quelle, venv, Nutzdaten, Caches
und Logs und entfernt das Paket nicht physisch.

Hauptcode MIT; lokale Drittanbieter, Modelle und Trainingsdaten haben eigene Lizenzen. Keine
ungepruefte kommerzielle Freigabe, keine Garantie fuer Rechte an generierter Musik. Nur berechtigte
Referenzaufnahmen und Stimmen verwenden. Tests synthetisch/offline; keine echte Installation,
Modelle, Musikproduktion oder Benutzer-WSL bei der Entwicklung gestartet.
