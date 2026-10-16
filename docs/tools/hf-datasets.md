# Hugging Face Datasets aus GitHub, ohne Docker

## Zuerst: Was wird eingerichtet?

**HF_Datasets** installiert die Datenbibliothek `datasets` **5.1.0** aus dem
offiziellen [GitHub-Quellstand](https://github.com/huggingface/datasets/tree/efe6ea4f88260b1a5066f28a9c90d82365a29f42),
Commit `efe6ea4f88260b1a5066f28a9c90d82365a29f42` (Release-Tag `5.1.0`).
Optional/experimental im Setup; keine automatische Profilinstallation.
Bibliothekscode Apache-2.0, Datensatz-/Medienlizenzen getrennt pruefen.

Das ist **kein Datensatz, Modell oder Trainer**. Installation und Doctor
laden keine Trainingsdaten oder Gewichte, melden sich nicht an und starten
keine Trainingsjobs, Decoder oder Server. Keine Docker-/GPU-Pflicht.
Das Basispaket beinhaltet nicht automatisch eine funktionierende Video-Pipeline.

| Voraussetzung / Ziel | Setup-Regel |
|---|---|
| Linux / WSL2 / MiniPC / Oracle VPS | normaler Benutzer, Git, flock, Python 3.10-3.13; Ubuntu 24.04/Python 3.12 vorgesehen |
| RAM | mindestens 2 GiB gesamt und 1 GiB aktuell verfuegbar fuer die Paketinstallation |
| Freier Speicher | mindestens 4 GiB am Installationsziel; unter WSL zusaetzlich 4 GiB Windows C: |
| RPi5 / Oracle ARM | nur 64-Bit ARM64 vorgesehen; passende PyPI-Wheels erforderlich, echter ARM-Test offen |
| Gaming-PC / RTX 5080 / Dual Xeon | keine GPU/VRAM erforderlich; keine schweren Extras oder parallelen Trainings |
| Kubernetes | kein Deployment enthalten; spaeter eigener privater Queue-Worker mit Limits |

Dies sind konservative Setup-Reserven, keine gemessenen Upstream-Minima.
**Datensaetze koennen spaeter Hunderte GB/TB benoetigen.** Diese Reserven sind
kein Daten-Downloadbudget. Kein automatischer Swap-/WSL-/System-Python-Umbau.

## Schritt fuer Schritt

Im aktuellen Setup-Verzeichnis:

```bash
# Nur Plan, kein Netzwerk und keine Installation:
bash scripts/tools/hf_datasets_install.sh --dry-run

# Bewusst installieren, alternativ HF_Datasets im Tools-Menue auswaehlen:
bash scripts/tools/hf_datasets_install.sh
bash scripts/tools/hf_datasets_doctor.sh
bash scripts/tools/hf_datasets_status.sh
```

Nicht mit `sudo` bauen. Basiswerkzeuge unter Ubuntu bei Bedarf separat:

```bash
sudo apt-get update
sudo apt-get install git util-linux python3 python3-venv
```

Fehlendes `venv`/`ensurepip` erkennt der Installer vor dem GitHub-Download.
Er verwendet die vorhandene eng begrenzte Reparatur fuer paketverwaltetes
Ubuntu-/Debian-Python unter `/usr/bin`: passendes `pythonX.Y-venv`, sudo-Freigabe,
APT-Sperrenschutz. Custom-Python wird nicht durch apt umgebaut.

```bash
# Automatische venv-Basisreparatur bei Bedarf abschalten:
HF_DATASETS_AUTO_VENV=0 bash scripts/tools/hf_datasets_install.sh

# Optional einen vorhandenen eigenen Interpreter waehlen:
HF_DATASETS_PYTHON_BIN=/pfad/python3 bash scripts/tools/hf_datasets_install.sh
```

## Quelle, Abhaengigkeiten und Ablage

```text
~/.openclaw_ultimate_user_data/tools/hf_datasets/
  source/           gepinnter GitHub-Checkout
  venv/             private Python-Umgebung
  source-built      Commit und Basispaket-Erfolgsmarkierung
  operation.lock
~/.openclaw_ultimate_user_data/install_logs/hf_datasets_*.log
```

`OPENCLAW_USER_DATA_DIR` kann ein anderes absolutes normalisiertes Ziel
ausserhalb des Repos festlegen; Verzeichnis-Symlinks werden abgelehnt.
System-Python und andere Tool-venvs bleiben unberuehrt.

Datasets wird aus diesem Checkout installiert, **nicht** durch einen beliebigen
`pip install datasets`-Release ersetzt. Abhaengigkeiten/Buildwerkzeuge kommen
aus PyPI: u. a. NumPy, pandas, PyArrow und `huggingface-hub`.
Diese Abhaengigkeiten sind noch nicht vollstaendig gehasht/gepinnt; ein kompletter
Lock/SBOM bleibt offen. Der Source-Build fuehrt fremden Paket-Buildcode aus.

Fuer PyArrow, NumPy und pandas werden ausschliesslich fertige Wheels akzeptiert.
Fehlt ein passendes Wheel, stoppt pip statt eines schweren C/C++-Source-Builds.
Kein Fallback auf Docker, CUDA oder Systempakete fuer Arrow.
Andere kleinere Abhaengigkeiten koennen Buildcode ausfuehren.

Es werden **keine Extras** wie Audio/Torch/Tests/Dev installiert. [HF_Hub](hf-hub.md)
hat inzwischen einen eigenen optionalen GitHub-Client-/CLI-Installer in separater
venv; das hier benoetigte Python-Paket
`huggingface-hub` wird jedoch als Bibliotheksabhaengigkeit in dieser venv installiert.
Das ist keine Login-/Token-/Downloadfreigabe fuer dessen CLI. Der separate
Hub-Installer veraendert diese Datasets-venv nicht.

Vor Downloads: RAM-/Disk-Pruefung. Pro Tool nur eine Operation via Lock,
private Logs, Diskmessung vor/nach Paketaufbau. Konsistente Installation wird
wiederverwendet. Doctor prueft Git-Pin, Metadaten und `pip check`, ohne `datasets`
zu importieren oder Hugging Face zu kontaktieren. Kein Dataset-/Decoder-Test.

## Erster Offline-Check und spaeterer Datenzugriff

Die Bibliotheksversion ohne Import oder Netzwerk lesen:

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
"$ROOT/tools/hf_datasets/venv/bin/python" -I -B -c \
  'from importlib.metadata import version; print(version("datasets"))'
```

Vor bewusstem spaeterem Gebrauch den privaten Cache in **derselben Shell**
festlegen, beispielsweise:

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
export HF_HOME="$ROOT/huggingface"
export HF_DATASETS_CACHE="$HF_HOME/datasets"
export HF_HUB_DISABLE_TELEMETRY=1
export HF_HUB_OFFLINE=1
export HF_DATASETS_OFFLINE=1
```

Diese Einstellungen sind keine Firewall oder harte Byte-Quota. Der Installer
schreibt keine Shellprofile um und setzt keine dauerhaft globalen Variablen.
Echte Token nur privat speichern, nie in Git, Logs, Beispielcode oder Prompts.
Datensatz-Daten/Cache/Personendaten bleiben ausserhalb des Setup-Repos.

Noch keinen `load_dataset`-/Streaming-Aufruf als Installationstest verwenden:
bereits der erste Eintrag kann grosse Shards herunterladen. Fuer spaetere
Netzwerkaktionen Offline-Flags nur bewusst aendern und vorher Rechte, Dataset-ID,
Revision, Dateigroessen und harte Zeit-/Byte-/Cachegrenzen freigeben.
Streaming ist **kein** hartes Downloadlimit. Keine fremden Dataset-Skripte,
Pickle-Dateien oder ungeprueften Decoder aus Agentenprompts ausfuehren.

Weiterfuehrend: [Video-Datensaetze und Lizenz-/Streaming-Grenzen](../media_studio/VIDEO_TRAINING_DATASETS.md).
Ein [Queue-Worker](../JOB_QUEUE_AGENT_WORKER.md) fuer OpenClaw/n8n benoetigt spaeter
eine gesondert getestete Anwendung: validierte Auftragsdaten, nur ein Job,
Timeout/Quotas und manuelle Datenfreigabe, keine beliebigen Shellbefehle.

## Update, Reparatur und Deaktivieren

```bash
bash scripts/tools/hf_datasets_install.sh --repair
bash scripts/tools/hf_datasets_update.sh
bash scripts/tools/hf_datasets_uninstall.sh
```

Update/Repair verwenden denselben Commit, kein automatisches `main`/`latest`.
Fremde, geaenderte oder unvollstaendige Quellen und fremde venv-Ordner werden
nicht geloescht/zurueckgesetzt. Manuell sichern/pruefen. Eine angefangene echte
venv wird ohne Loeschung vervollstaendigt; kein transaktionaler Paket-Rollback.
Bei Fehler entsteht kein neuer Erfolgsmarker.

Deinstallation deaktiviert nur den Setup-Marker. Quellen, venv, Daten, Cache,
Token und Logs bleiben erhalten. Manuelle Python-Nutzung bleibt technisch
moeglich; das ist keine Token-Widerrufung oder Zugriffssperre.

Offen: echte Linux-/ARM-Paketinstallation, Import-/Wheel-Smoke-Test,
vollstaendiger Dependency-Lock, Decoderprofil und budgetierter Datenworker.
Hier wurden nur Offline-Tests mit Mocks ausgefuehrt, keine WSL-/Dataset-Aktionen.
