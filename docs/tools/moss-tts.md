# MOSS-TTS aus GitHub, ohne Docker

## Umfang und Quelle

Der vorhandene Installer ist jetzt mit Registry und Tools-Menue verbunden,
statt den gemeinsamen documentation-first-Guard aufzurufen.
[OpenMOSS/MOSS-TTS](https://github.com/OpenMOSS/MOSS-TTS/tree/934d6826b084c46a0d033402174d5f8ac4ed2519),
Commit `934d6826b084c46a0d033402174d5f8ac4ed2519`, Paketversion `0.1.0`.
Status: experimental, Installation nur nach bewusster Auswahl, ohne Docker.

**Installiert werden Checkout und ein privates Basis-Metadatenpaket mit
`--no-deps`, nicht eine fertige TTS-Laufzeit.** Upstream setzt `py-modules=[]`;
der Checkout bleibt daher fuer die eigentlichen Pipeline-Quellen erforderlich.
Keine Submodule, Gewichte, Modelle, Cloud-Aufrufe, Anmeldung, Gradio-WebUI,
Server, Audiodateien, Inferenz oder Training werden automatisch gestartet.

## Installation

```bash
bash scripts/tools/moss_tts_install.sh --dry-run
bash scripts/tools/moss_tts_install.sh
bash scripts/tools/moss_tts_status.sh
bash scripts/tools/moss_tts_doctor.sh
bash scripts/tools/moss_tts_install.sh --repair
bash scripts/tools/moss_tts_update.sh
bash scripts/tools/moss_tts_uninstall.sh
```

Im Tools-Menue kann MOSS_TTS ausgewaehlt werden. Python 3.10-3.12 mit
venv/ensurepip/SSL wird fuer diesen Basisweg akzeptiert; Ubuntu 24.04 mit
Python 3.12 passt. Bei Bedarf `MOSS_TTS_PYTHON_BIN=/pfad/zum/python` setzen.
Keine Umgehung von Python-Anforderungen, kein System-Python-Austausch.

Voraussetzungen: Linux x86_64/ARM64, normaler Benutzer, Git, Bash, flock,
realpath. Konservative Basisreserve: 1 GiB Gesamt-RAM, 512 MiB aktuell frei,
2 GiB freie Disk und unter messbarem WSL-Host 2 GiB Windows-Host-Reserve.
Diese Werte sind **keine Inferenz-/VRAM-Anforderungen**. MiniPC/RPi/VPS eignen
sich hier nur zur Vorbereitung; eine Audio-Laufzeit braucht separate Planung.

## Pfade und Status

`${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/moss_tts/`
enthaelt `source/`, `venv/`, `operation.lock` und `source-built`.
Logs liegen unter `install_logs/moss_tts_*.log` im User-Workspace.
Symlinks, fremde oder veraenderte Quellen werden nicht zurueckgesetzt oder
geloescht. Update bleibt beim geprueften Pin; keine main/latest-Migration.

Status/Doctor pruefen Pin, Paketmetadaten und venv-Pfad ohne MOSS-/Torch-Import
oder Audiozugriff. `installed` bedeutet nur Basisvorbereitung; Runtime,
Modelle und Inferenz sind weiterhin nicht bestaetigt. Der Marker steuert den
Menueeintrag. Deaktivierung entfernt Marker und beide Setup-Statuszeilen;
Checkout, venv, eigene Daten und Logs bleiben bewusst erhalten.

## Laufzeit und Sicherheit

Der [gepruefte Paket-Pin](https://github.com/OpenMOSS/MOSS-TTS/blob/934d6826b084c46a0d033402174d5f8ac4ed2519/pyproject.toml)
bietet unterschiedliche Torch-/llama.cpp-/ONNX-/TensorRT-Extras. Ein einheitlicher
GPU-Pfad ist damit nicht automatisch sichergestellt. `MOSS_TTS_INSTALL_RUNTIME=1`
wird derzeit ausdruecklich abgelehnt. Naechster Schritt: separat getestete
Runtime, Audio-Tokenizer, Modellvariante, Lizenzannahme und Ressourcenbudget.
Kein pauschales VRAM-Versprechen oder automatischer CUDA-/Treiberumbau.

Die Anwendung kommt aus GitHub; pip kann isolierte Build-Werkzeuge aus PyPI
beziehen. Nicht alle Abhaengigkeiten stammen dadurch aus GitHub. Keine
Netzwerksandbox oder vollstaendig gehashte Offline-Lieferkette wird behauptet.
HF-Token werden im Installer-Subprozess entfernt; Offline-/Telemetrieflags
verhindern nicht grundsaetzlich alle Netzwerkanfragen beliebiger Build-Skripte.

Code: [Apache-2.0](https://github.com/OpenMOSS/MOSS-TTS/blob/934d6826b084c46a0d033402174d5f8ac4ed2519/LICENSE).
Modellkarten und Datenrechte getrennt pruefen. Nur eigene Stimmen oder Stimmen
mit ausdruecklicher Einwilligung verwenden; synthetische Inhalte kennzeichnen.
Keine Stimmen-/Personendaten im Repo oder in Logs ablegen.

Pruefung hier: Offline-Tests mit temporaeren Dateien und simulierten
Installationsschritten. Kein echter Linux-/GPU-Build, Modelltest oder
WSL-Zugriff. Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
