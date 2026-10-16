# AudioGen aus GitHub (ohne Docker)

AudioGen erzeugt beschriebene Geraeusche und Klanglandschaften, nicht allgemein
Hoerbuecher oder Gesang. Es ist Teil von [Meta AudioCraft](https://github.com/facebookresearch/audiocraft/tree/v1.3.0),
kein eigenstaendiges Python-Paket. Der Installer baut das Paket `audiocraft`
aus Tag `v1.3.0`, festem Commit `72cb16f9fb239e9cf03f7bd997198c7d7a67a01c`.
Status: **experimental**, ausschliesslich nach manueller Auswahl.

## Installation und Umfang

```bash
bash scripts/tools/audiogen_install.sh --dry-run
bash scripts/tools/audiogen_install.sh
bash scripts/tools/audiogen_status.sh
bash scripts/tools/audiogen_doctor.sh
bash scripts/tools/audiogen_install.sh --repair
bash scripts/tools/audiogen_update.sh
```

Der normale Installationspfad klont GitHub und installiert das lokale Paket
mit `--no-deps` in einer privaten venv. **Das Basispaket ist noch keine
betriebsbereite AudioGen-Laufzeit.** Keine Docker-Nutzung, keine Modelle,
Generierung, Demo, Dienste oder offenen Ports. Das Menue meldet diese Grenze
ausdruecklich und setzt keinen allgemeinen Bereitschaftseintrag.
Status `installed` beschreibt nur das Basispaket; `runtime_dependencies` und
`inference_tested` bleiben `false`. Doctor prueft Pin, Quellzustand und
Paketmetadaten ohne AudioCraft-/Torch-Import oder Modellzugriff.

Ziel ist `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/audiogen/`
mit `source/`, `venv/`, Lock und Marker. Logs liegen im zugehoerigen
`install_logs/`. Bestehende MusicGen-Installationen unter `/opt/musicgen`
werden weder verwendet noch veraendert. Persoenliche Daten bleiben ausserhalb
des Setup-Repositories; System-Python und globale Pakete bleiben unveraendert.

Voraussetzungen: normaler Linux-Benutzer, Bash, Git, flock, realpath, Python
3.10 bis 3.12 mit venv, ensurepip und SSL. `AUDIOGEN_PYTHON_BIN` waehlt einen
vorhandenen Interpreter. Python 3.12 gilt hier nur fuer das Basispaket.
Basisreserve: 1 GiB Gesamt-RAM, 512 MiB aktuell frei, 2 GiB freie Disk und
bei messbarem WSL-Host ebenfalls 2 GiB Windows-C:-Reserve. Das sind keine
ausreichenden Ressourcen fuer spaetere GPU-Inferenz. Vorher/nachher wird
der Dateisystemplatz protokolliert. Keine automatische Basis-/GPU-Installation.

## Laufzeit bleibt ein offener Integrationsschritt

Die [gepinnten Anforderungen](https://github.com/facebookresearch/audiocraft/blob/v1.3.0/requirements.txt)
verlangen unter anderem `torch==2.1.0`, `torchvision==0.16.0`, `av==11.0.0`
und `xformers<0.0.23`. Diese alte Kombination ist nicht pauschal fuer Python
3.12, ARM oder neuere NVIDIA-Karten geeignet. Deshalb lehnt
`AUDIOGEN_INSTALL_RUNTIME=1` den ungeprueften Vollausbau klar ab.
Noch zu testen: separate Python-3.10/3.11-Runtime, kompatible CUDA-/GPU-
Pakete, FFmpeg/PyAV, Lizenzannahme, kontrollierter Modelldownload und
ein echter Generierungstest. Keine Behauptung, dass die RTX 5080 mit
diesem historischen PyTorch-Pin funktioniert. MiniPC, Raspberry Pi und
Oracle-VPS sind fuer diese Basisvorbereitung, nicht als getestete
AudioGen-Produktionshardware eingeordnet.

GitHub ist die Quelle der Anwendung; pip kann Build-Werkzeuge aus PyPI
beziehen. `--no-deps` verhindert Runtime-Abhaengigkeiten, nicht isolierte
Build-Abhaengigkeiten. Es gibt noch keine vollstaendig gehashte/offline
Build-Umgebung. HF-Token werden im Installer-Subprozess entfernt und
Hub-/Transformers-Offline-Flags gesetzt; das ist keine Netzwerksandbox.

Updates installieren denselben Pin, nicht ungefragt `main`/`latest`.
Fremde, abgebrochene oder geaenderte Quellordner werden nicht ueberschrieben.
Nach manueller Sicherung/Pruefung kann `--repair` erneut aufgerufen werden.

```bash
bash scripts/tools/audiogen_uninstall.sh
```

Dies deaktiviert nur den Setup-Marker, nicht die Paketdateien. Quellen,
venv, eigene Audios, Modelle, Caches und Logs bleiben bewusst erhalten.
Eine vollstaendige Loeschung erfordert eine separate bewusste Entscheidung.

## Rechte und Validierung

[Code: MIT](https://github.com/facebookresearch/audiocraft/blob/v1.3.0/LICENSE),
[Modellgewichte: CC-BY-NC 4.0](https://github.com/facebookresearch/audiocraft/blob/v1.3.0/LICENSE_weights).
Die Code-Lizenz erlaubt nicht automatisch kommerzielle Modellnutzung.
Nur rechtmaessige Audiodaten verwenden; keine fremden Stimmen imitieren
oder Ergebnisse als authentische Beweisaufnahme ausgeben.

Offline-Tests pruefen Registry, Menue, Pfadschutz, Ressourcen-Grenzen,
simulierte Paketinstallation und Fehlerbehandlung. Kein echter Download,
Build, WSL-Zugriff oder Inferenztest wurde dabei ausgefuehrt.

Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
