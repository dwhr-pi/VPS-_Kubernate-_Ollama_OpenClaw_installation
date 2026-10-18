# Kiwi Edit aus GitHub, ohne Docker

Kiwi Edit bearbeitet Videos anhand von Textanweisungen und optionalen
Referenzbildern. Quelle: [showlab/Kiwi-Edit](https://github.com/showlab/Kiwi-Edit/tree/178f3f4f8221d7598fcc21875c847d6cf6323c4e),
Commit `178f3f4f8221d7598fcc21875c847d6cf6323c4e`, Status **experimental**.
Der Root baut das Python-Paket **`diffsynth` Version 2.0.4**, keine
gleichnamige Kiwi-PyPI-Anwendung. Diese Versionsangabe gilt fuer das Paket,
nicht fuer die separat veroeffentlichten Modellgewichte.

## Basisinstallation

```bash
bash scripts/tools/kiwi_edit_install.sh --dry-run
bash scripts/tools/kiwi_edit_install.sh
bash scripts/tools/kiwi_edit_status.sh
bash scripts/tools/kiwi_edit_doctor.sh
bash scripts/tools/kiwi_edit_update.sh
bash scripts/tools/kiwi_edit_install.sh --repair
```

Voraussetzungen: normaler Linux-Benutzer, Bash, Git, flock, realpath,
Python 3.10.1-3.12 mit venv, ensurepip und SSL. `KIWI_EDIT_PYTHON_BIN`
waehlt einen vorhandenen Interpreter. Python 3.12 ist fuer das Basispaket
zugelassen, nicht als Zusage fuer die gesamten Upstream-GPU-Wheels.
Keine System-Python-/apt-/Conda-Installation oder globalen Python-Pakete.

Die Anwendung wird aus GitHub bezogen und mit `--no-deps` in einer
privaten venv installiert. **Nur Basispaket, nicht betriebsbereit fuer
Videobearbeitung.** Keine Docker-Nutzung, GPU-/Modellpakete, Modelldownloads,
Demos, Training, Cloud-/Gemini-Aufrufe oder offenen Ports.
`install_full_env.sh` und `install_diffusers_env.sh` werden nicht gestartet.
Pip kann isolierte Build-Werkzeuge aus PyPI beziehen; ein vollstaendig
gehashter Offline-Build ist noch offen.

## Pfade und Schutz

Ziel: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/kiwi_edit/`
mit `source/`, `venv/`, Lock und Marker. Logs liegen im zugehoerigen
`install_logs/`. Sparse-Checkout umfasst das Python-Paket, Demo-/Training-
Quelltexte, scripts/utils sowie README/Lizenz/Paketmetadaten/.gitignore.
Medien, Gewichte, .env-Dateien, Notebooks, Demo-Daten und Webseite werden
nicht ausgecheckt. Partial-Fetch reduziert Git-Bilddatenbedarf, ist aber
keine absolute Netz-/Speichermengen-Garantie.

Repo-interne User-Daten und Symlink-Verzeichnisse werden abgelehnt;
fremde, unvollstaendige oder geaenderte Quellordner bleiben erhalten.
Kein Reset/Loeschen und kein automatisches main/latest-Upgrade: Update
baut denselben Pin. Bestehende DiffSynth-/ComfyUI-Umgebungen werden nicht
mitbenutzt oder veraendert. Nach manueller Sicherung/Pruefung --repair.

Reserve fuer das Basispaket: 1 GiB Gesamt-RAM, 512 MiB aktuell frei,
2 GiB freie Ziel-Disk und bei messbarem WSL-Host 2 GiB Windows-C:.
Freier Dateisystemplatz wird vorher/nachher protokolliert. Kein ausreichendes
Budget fuer Modellgewichte/GPU-Inferenz: RAM, VRAM und Cache-Disk separat
planen. MiniPC/RPi/Oracle-VPS sind nur fuer Basisvorbereitung vorgesehen;
GPU-Workstation/Kubernetes brauchen einen eigenen Laufzeittest.
Keine gemessene RTX-5080-/ARM- oder Geschwindigkeitszusage.

Status `installed` beschreibt nur das konsistente Basispaket;
`runtime_dependencies`, `models_checked`, `inference_tested` bleiben `false`.
Doctor prueft Quell-Pin und Paketmetadaten ohne DiffSynth-/Torch-Import.
Das Menue setzt keinen allgemeinen Inferenz-Bereitschaftseintrag.

```bash
bash scripts/tools/kiwi_edit_uninstall.sh
```

Deaktiviert nur den Setup-Marker. Quellen, venv, eigene Videos/Bilder,
Modelle, Cache und Logs bleiben erhalten; keine vollstaendige Dateiloeschung.

## Laufzeit und Remote-Code-Grenze

Der [Upstream-Vollinstaller](https://github.com/showlab/Kiwi-Edit/blob/178f3f4f8221d7598fcc21875c847d6cf6323c4e/install_full_env.sh)
verwendet Python 3.10, Torch 2.7.0/CUDA 12.8, zusaetzliche Trainingsteile,
einen konkreten FlashAttention-Wheel und einen Modell-Download.
`KIWI_EDIT_INSTALL_RUNTIME=1` wird deshalb mit Hinweis abgelehnt,
statt diesen gesamten Pfad ungeprueft zu uebernehmen. Noch zu testen:
separate Inferenz-Abhaengigkeiten, CUDA-/Wheel-/FFmpeg-Pfad, konkrete
Modellrevisionen und Speicherbudget sowie ein freigegebenes Testvideo.

Die [Diffusers-Demo](https://github.com/showlab/Kiwi-Edit/blob/178f3f4f8221d7598fcc21875c847d6cf6323c4e/diffusers_demo.py)
verwendet **`trust_remote_code=True`**. Ein spaeterer Start kann Modell-
Repository-Code laden/ausfuehren; Modellrevision und diesen Code separat
pruefen, nicht nur das GitHub-Paket. Keine automatische Freigabe durch
diesen Installer. Gemini-Evaluationsskripte bleiben ebenfalls ungestartet.
HF-/Gemini-/Google-/WandB-Schluessel werden im Installer-Subprozess entfernt,
Hub-/Transformers-Offline-Flags gesetzt. Das ist keine Netzwerksandbox.

## Lizenz und Tests

Der [Root-Lizenztext](https://github.com/showlab/Kiwi-Edit/blob/178f3f4f8221d7598fcc21875c847d6cf6323c4e/LICENSE)
ist MIT, waehrend die [diffsynth-Paketmetadaten](https://github.com/showlab/Kiwi-Edit/blob/178f3f4f8221d7598fcc21875c847d6cf6323c4e/pyproject.toml)
Apache-2.0 angeben. Herkunft/Abgrenzung der Bestandteile vor Weitergabe
klaeren; Modell-/Wan-/Referenzdatenbedingungen separat pruefen. Keine
pauschale kommerzielle Freigabe. Nur eigene/freigegebene Videos und Bilder
nutzen, Personenrechte beachten und synthetische Bearbeitung kennzeichnen.

Offline-Tests simulieren den Paketbau und pruefen Registry, Menue, Pfade
und lokale Sparse-Ausschluesse. Kein echter Upstream-Clone/Paketbau,
GPU-/Modelltest, Remote-Code-/Gemini-Aufruf oder WSL-Zugriff ausgefuehrt.
Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
