# pyannote.audio aus GitHub, ohne Docker

## Zuerst: Zweck und Installationsumfang

pyannote.audio ist eine Bibliothek fuer Sprecher-Diarisierung, etwa Zeitbereiche
und Sprecherwechsel. Anonyme Labels sind kein Nachweis einer realen Identitaet
und **keine Deepfake-/Echtheitsbewertung**. Originalaufnahmen behalten; nur
berechtigte Audios verarbeiten und Ergebnisse manuell pruefen.

Der eigene optionale Setup-Installer ersetzt den bisherigen Audio-Review-
Platzhalter. Quelle: [pyannote/pyannote-audio](https://github.com/pyannote/pyannote-audio),
MIT-Code, Release **4.0.4**, gepruefter Commit
`78c0d16a5f558adb1024d112e6857b3204b450b3`.
Der Release-Tag und sein Commit werden beim GitHub-Fetch verglichen.
Ein bewegliches `main` wird nicht automatisch installiert.

Standard ist die **Quellinstallation**. Optional gibt es eine schwere,
private **CPU-Paketinstallation**. Modellgewichte, Hugging-Face-Zugang,
Audioverarbeitung und etwaige Cloud-Dienste sind jeweils separate Schritte.
Keine Docker-, Treiber-, ComfyUI- oder globale Python-Installation.

## Voraussetzungen und Ressourcen

| Pfad | Konservative Setup-Reserve | Weitere Voraussetzungen |
|---|---|---|
| Nur Quellen | 1 GiB Ziel-Disk, unter WSL 2 GiB freie Windows-C:-Reserve | Linux, normaler Benutzer, Git, Bash, Python 3, flock |
| CPU-Pakete | 8 GiB Gesamt-RAM, 10 GiB freie Ziel-Disk und unter WSL 10 GiB frei auf C: | Linux x86_64, vorhandenes Python 3.10-3.13 mit venv, FFmpeg |
| Modelle/Inferenz | zusaetzlich modell-/aufnahmelaengenabhaengiger Speicher und RAM | getrennte Freigabe/Downloads, Decoder-/Modelltest |

Die Werte sind Setup-Leitplanken, keine gemessenen universellen Mindestwerte.
Ubuntu 24.04/Python 3.12 passt zum Paketpfad; System-Python wird nicht ersetzt.
MiniPC und Oracle-VPS koennen CPU-Pakete nutzen, lange Aufnahmen koennen dort
langsam sein. RPi/ARM erhalten hier nur den Quellpfad. Eine GPU-Workstation
gewinnt durch **CPU-only**-Wheels keine CUDA-Unterstuetzung. Automatisches
GPU-/K3s-/Windows-Portable-Deployment ist nicht Teil dieser Integration.

Fehlende Basiswerkzeuge/FFmpeg bewusst separat einrichten. FFmpeg im PATH
allein garantiert noch nicht, dass TorchCodec passende FFmpeg-Shared-Libraries
laden kann. Doctor prueft keinen Decoder und keine Medien.

## Schritt 1: GitHub-Quellen installieren

Im aktuellen Ultimate-Setup-Checkout, ohne sudo:

```bash
bash scripts/tools/pyannote_audio_install.sh --dry-run
bash scripts/tools/pyannote_audio_install.sh
bash scripts/tools/pyannote_audio_status.sh
bash scripts/tools/pyannote_audio_doctor.sh
```

Oder im Tools-Menue **Pyannote_Audio** bewusst auswaehlen. Ziel:
`~/.openclaw_ultimate_user_data/tools/pyannote_audio/source/`.
Der Installer prueft Ursprung, Pin, saubere Quellen und AST-Syntax, importiert
aber weder pyannote noch torch und laedt keine Audios oder Modelle.
`source-ready` ist kein Nachweis einer lauffertigen Diarisierung. Die generische
Toolliste erkennt diesen Quellmarker; fuer den Paketstand Doctor verwenden.

## Schritt 2: Optionale private CPU-Laufzeit

Nach Pruefung der groesseren Speicherreserve:

```bash
PYANNOTE_AUDIO_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/pyannote_audio_install.sh --dry-run

PYANNOTE_AUDIO_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/pyannote_audio_install.sh
```

Dry-Run beschreibt nur den Plan, ohne Pakete/Ressourcen aktiv zu testen.
Der reale Install-Aufruf prueft Voraussetzungen und Ressourcen vor Downloads.
`PYANNOTE_AUDIO_PYTHON_BIN=/absoluter/pfad/python3` waehlt vorhandenes Python.
Die private Umgebung liegt in `tools/pyannote_audio/venv/` des User-Workspace.
Keine vorhandene ComfyUI-, RIFE- oder System-Umgebung wird wiederverwendet.

PyTorch 2.10.0 und torchaudio 2.10.0 kommen als CPU-Wheels aus dem offiziellen
PyTorch-Index, dazu TorchCodec 0.10.0. Die
[TorchCodec-Tabelle](https://github.com/pytorch/torchcodec#compatibility-with-torch-versions)
ordnet 0.10 der PyTorch-2.10-Linie zu. Weitere Python-/Build-Abhaengigkeiten
kommen aus PyPI; pyannote selbst wird aus dem gepinnten GitHub-Checkout mit
dessen `pyproject.toml`/Hatch gebaut, **nicht** mit dem alten `setup.py`.

Die drei Audio-/Torch-Kernversionen sind per Constraints festgelegt. Weitere
Upstream-Abhaengigkeiten bleiben Versionsbereiche, kein vollstaendig mit
Hashes verriegelter Lockfile. Ein echter Build-/Decoder-/Modelltest und ein
vollstaendiger Supply-Chain-Audit stehen noch aus. Buildcode ist Fremdcode:
nicht mit sudo ausfuehren. Weder Training noch Modellpipeline werden gestartet.

Nach `pip check` und reiner Paket-Metadatenpruefung wird `runtime-ready`
geschrieben. Das beweist weder funktionierendes Audio-Decoding noch passende
Modellgewichte. Bei Fehlern bleibt ein neuer Runtime-Erfolgsmarker aus.

## Schritt 3: Modelle und Datenschutz bewusst konfigurieren

Die [Upstream-Anleitung](https://github.com/pyannote/pyannote-audio/tree/4.0.4)
unterscheidet lokale Community-Pipelines und einen externen Premium-Dienst.
Community-1 kann nach bewusster Modellbereitstellung lokal arbeiten;
Precision-2 ist nicht einfach derselbe lokale Betrieb. Keine Cloud-API
ungeprueft mit vertraulichen Audios verwenden.

Fuer ein passendes Community-Modell Modellbedingungen/Gating selbst pruefen,
gegebenenfalls persoenlich akzeptieren und einen eng begrenzten Hugging-Face-
Token separat im privaten Workspace verwalten. Kein automatischer Login,
Tokenimport aus einem Tresor, Lizenz-Akzeptieren oder Modelldownload durch den
Installer. Tokens nicht in Shell-History, Git, Prompts oder Logs schreiben.

Vor spaeteren manuellen Pipeline-Imports die Telemetrie-Einstellungen setzen:

```bash
export PYANNOTE_METRICS_ENABLED=0
export HF_HUB_DISABLE_TELEMETRY=1
export DO_NOT_TRACK=1
export OTEL_SDK_DISABLED=true
# Fuer bereits bewusst heruntergeladene, lokal vorhandene Modelle:
export HF_HUB_OFFLINE=1
```

Der [gepruefte Telemetriecode](https://github.com/pyannote/pyannote-audio/blob/4.0.4/src/pyannote/audio/telemetry/metrics.py)
wertet `PYANNOTE_METRICS_ENABLED` aus. Die weiteren Schalter sind zusaetzliche
Prozess-Leitplanken, kein systemweiter Netzwerkfilter. Die Exports im Installer
gelten nur fuer dessen Prozess, nicht automatisch fuer spaetere Shells oder
andere Programme. Fuer streng offline arbeitende Systeme ausgehenden Verkehr
zusaetzlich kontrollieren. Modellbereitstellung mit Netzwerk und anschliessende
Offline-Inferenz als getrennte freigegebene Phasen behandeln.

Zuerst mit einer kurzen synthetischen/eigenen Testaufnahme arbeiten, ein Job
gleichzeitig, feste Laufzeit- und Dateigroessenlimits. OpenClaw/n8n-Adapter
duerfen spaeter nur validierte private Dateipfade und Parameter uebergeben.
Ein solcher Diarisierungs-/Queue-Adapter ist hier noch nicht implementiert.
Keine automatische Bearbeitung, Publikation oder Echtheitsentscheidung.

## Update, Diagnose und Deaktivierung

```bash
bash scripts/tools/pyannote_audio_update.sh
bash scripts/tools/pyannote_audio_install.sh --repair
bash scripts/tools/pyannote_audio_uninstall.sh
```

Update bleibt auf demselben Release-Pin. Fuer einen erneuten CPU-Paketaufbau
die zwei Opt-in-Variablen erneut setzen. Normale Installation verwendet
konsistente Pakete erneut. Kein automatischer Wechsel auf CUDA-Wheels.
Fremde, veraenderte oder unvollstaendige Quellen werden nicht ersetzt oder
zurueckgesetzt: erst manuell sichern/umbenennen und erneut installieren.

Ein Lock verhindert parallele Aktionen. Logs:
`~/.openclaw_ultimate_user_data/install_logs/pyannote_audio_*.log`.
`OPENCLAW_USER_DATA_DIR` kann den absoluten privaten Workspace ausserhalb von
Git aendern; Symlink-Umleitungen werden abgelehnt. Doctor/Status laden nichts
herunter und erzeugen keinen Workspace. Kein Pipeline-/GPU-/Modellimport.
Doctor prueft einen vorhandenen Runtime-Marker mit `pip check`/Metadaten.

Uninstall deaktiviert nur die Setup-Marker. Quellcode, venv, Modelle,
Audios, eigene Ergebnisse und Logs bleiben erhalten; keine Prozesse werden
beendet. Kein transaktionaler venv-Rollback und keine automatische Bereinigung
persoenlicher Daten. Manuell verwendete Umgebungen werden dadurch nicht gesperrt.

Hier wurden nur Offline-/Mocktests ausgefuehrt. Keine echte Paket-/Modell-
installation, kein Audiozugriff und keine Aenderung deiner vorhandenen WSL.
