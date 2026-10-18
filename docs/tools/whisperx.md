# WhisperX aus GitHub, ohne Docker

WhisperX erzeugt Transkripte, Wort-Zeitstempel durch Alignment und optional
Sprechersegmente (Diarisierung). Sprecherlabels sind keine sichere Identifikation
realer Personen. Gesang, Dialekte und ueberlappende Stimmen brauchen Nachkontrolle.

Quelle: [m-bain/whisperX v3.8.6](https://github.com/m-bain/whisperX/tree/v3.8.6),
Commit `3ccc17b8de34f305300f8a3fd3c9f76ba820c0d0`.
Status **experimental/heavy** fuer diesen Installer, keine echte Runtime-/GPU-
Installation oder Inferenz in der Benutzer-WSL bei der Entwicklung getestet.
Code BSD-2-Clause; Abhaengigkeits- und Modelllizenzen separat beachten.

## GitHub-Basispaket installieren

Der Menuepunkt WhisperX nutzt nun eigene Skripte statt des Medien-Guards.
Zur bewussten Ausfuehrung durch den Benutzer:

```bash
bash scripts/tools/whisperx_install.sh --dry-run
bash scripts/tools/whisperx_install.sh
bash scripts/tools/whisperx_status.sh
bash scripts/tools/whisperx_doctor.sh
```

Das Paket wird aus dem gepinnten GitHub-Checkout in eine private venv
installiert, nicht aus Docker oder als WhisperX-Paket von PyPI.
Standard `--no-deps`: noch keine betriebsbereite ASR-Laufzeit.
Build-Abhaengigkeiten (setuptools) kommen aus PyPI. Das Quellrepo enthaelt
bereits `whisperx/assets/pytorch_model.bin` (rund 17 MiB VAD-Gewicht).
Der Installer laedt keine weiteren ASR-/Alignment-/Diarisierungsmodelle.
Keine CLI, kein HF-Login, Upload oder Audio-/Modelltest wird ausgefuehrt.
Pins sind keine Signaturpruefung oder Sicherheitsgarantie fuer Fremdcode.

Voraussetzungen: normaler Linux-Benutzer, Bash, Git, Python **3.10-3.13**,
venv/ensurepip/SSL, flock, realpath und uebliche GNU-Werkzeuge.
Ubuntu-Python **3.12** passt zum Basispaket. Bei Bedarf
`WHISPERX_PYTHON_BIN` auf ein vorhandenes passendes Python setzen.
Bei fehlendem ensurepip das passende venv-Systempaket separat einrichten;
kein System-Python-/WSL-/Swap-Umbau oder automatischer apt-Aufruf.

## Optionale Runtime

Zuerst das Basispaket installieren. Dann **bewusst** zusammenpassende
PyTorch-/torchaudio-/torchvision-Wheels in genau dessen venv einrichten.
Fuer diesen Pin: Torch/torchaudio 2.8.x mit identischer Patch-Version,
torchvision 0.23.x und einheitlicher CPU-/CUDA-Variante. Beispiel einer
Versionskombination: 2.8.0 / 2.8.0 / 0.23.0. Zur Auswahl offizieller Wheels:
[PyTorch-Versionsmatrix](https://pytorch.org/get-started/previous-versions/).
CPU/CUDA-Wahl ist kein automatischer Installer-Schritt.

```bash
INSTALL_HEAVY_TOOLS=1 WHISPERX_INSTALL_RUNTIME=1 \
  bash scripts/tools/whisperx_install.sh
```

Runtime braucht Linux **x86_64**, ffmpeg und den vorhandenen Torch-Stack.
Der Installer liest nur Paketmetadaten, importiert Torch nicht und haelt
die ausgewaehlten Torch-/Audio-/Vision-Versionen durch Constraints fest.
Kein automatischer Austausch CPU gegen CUDA oder Treiberumbau.
Weitere Laufzeitpakete werden aus PyPI aufgeloest. NumPy >=2.1,<3 und
Transformers <5 begrenzen die Aufloesung zusammen mit den Upstream-Vorgaben.
Grosse native Pakete sind auf Wheels beschraenkt; fehlende Wheels fuehren
zum Fehler statt zu einem unkontrollierten Source-Build. Andere Python-
Pakete koennen Build-Isolation verwenden. Kein vollstaendiges Hash-Lockfile;
transitive Versionen und Build-Abhaengigkeiten sind nicht komplett gepinnt.

WhisperX definiert uv-spezifische Index-/Dependency-Overrides; pip uebernimmt
diese **nicht**. Insbesondere Linux ARM64/torchcodec braucht gesonderte
Pruefung, daher hier kein automatischer ARM64-Runtime-Pfad. Ein passendes
FFmpeg-Programm garantiert noch keine ladbaren torchcodec-/CUDA-Bibliotheken.
`pip check` prueft Metadaten, nicht native Bibliotheken oder Audioqualitaet.

## Spaetere Transkription

Erst nach Runtime-Einrichtung und Rechtepruefung, manuell durch den Benutzer:

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
"$ROOT/tools/whisperx/venv/bin/whisperx" ./eigene-aufnahme.wav \
  --device cpu --compute_type int8 --batch_size 1 --model small \
  --output_dir ./transkripte
```

Dieser Aufruf verarbeitet echte Audiodaten und kann beim ersten Mal
ASR-/Alignment-Modelle aus externen Modellquellen nachladen. Er ist **kein**
Installer-Schritt. Vorher Modelllizenzen, freien Speicher und Dateirechte
pruefen. Fuer rein offline Nutzung Modelle separat autorisiert vorbereiten
und die benoetigten Cache-/Modellpfade nach Upstream konfigurieren.
Grosse Dateien seriell ueber die Setup-Queue verarbeiten; ein kleiner
Batch ist keine harte CPU-/RAM-/GPU-Quota.

Der Beispielaufruf aktiviert keine Diarisierung. Diese kann gesonderte
Hugging-Face-Modellfreigaben und einen Read-Token verlangen. Zustimmung
erteilt nur der Benutzer; keine automatische Lizenzannahme. Keine Tokens
in Befehlsbeispielen, Shell-History, Logs oder Repo-Dateien hinterlegen.
Tokens fuer eine spaetere Integration ausschliesslich ueber die private
Secret-Verwaltung und die dokumentierte API der gewaehlten Version laden.
Auch das mitgelieferte VAD-Gewicht ist separat lizenzrechtlich zu pruefen.

## Ressourcen und Hosts

| Modus/Host | Installer-Reserve, keine Laufzeitgarantie |
|---|---|
| Basispaket | 1 GiB Gesamt-RAM, 512 MiB verfuegbar; 2 GiB freie Ziel-Disk und messbares Windows-C: |
| Runtime | 8 GiB Gesamt-RAM, 4 GiB aktuell verfuegbar; 20 GiB freie Ziel-Disk und Windows-C: |
| MiniPC/WSL2 | Basispaket lokal; CPU-int8 fuer bewusst gestartete kleine Jobs, Windows-Host-Disk beachten |
| Oracle VPS/Kubernetes | CPU-Jobs moeglich, keine automatischen Deployments oder Portfreigaben |
| Raspberry Pi ARM64 | Nur Basispaketpfad vorgesehen; keine automatische Runtime wegen Wheel-/Override-Grenzen |
| GPU-Workstation | CUDA/FFmpeg/Torch/CTranslate2 separat kompatibel einrichten, keine fixe VRAM-Zusage |

Modellgroesse, Audio-Laenge, Alignment, Diarisierung und Batchgroesse
bestimmen den tatsaechlichen Ressourcenbedarf. Keine Modelle im Basisbudget
versprochen. Dieser Helper installiert nicht nativ unter Windows/macOS.

## Status und Lifecycle

Dateien liegen unter
`${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/whisperx/`:
`source/`, `venv/`, `source-built`, `operation.lock`.
Logs im privaten User-Workspace unter `install_logs/`, Diskmessung vor/nach
Installation. Der Installer entfernt HF-Tokens aus seiner Prozessumgebung
und setzt HF-/Transformers-Offlinevariablen; das ist keine Netzwerksandbox.

```bash
bash scripts/tools/whisperx_update.sh
bash scripts/tools/whisperx_install.sh --repair
bash scripts/tools/whisperx_uninstall.sh
```

Update/Repair bleibt auf demselben Commit. Fuer die Runtime auch dabei
die beiden Opt-ins setzen, sonst wird nur das Basispaket registriert.
`installed` bezeichnet nur das gepruefte GitHub-Paket;
`runtime_dependencies` erfordert Runtime-Marker, passende Torch-Metadaten
und `pip check`. `inference_tested` bleibt `false`. Doctor kann bei einem
konsistenten Basispaket Erfolg melden, obwohl noch keine Inferenz moeglich ist.

Fremde/geaenderte Quellen werden nicht geloescht oder zurueckgesetzt.
Sperre und Symlink-/Pfadpruefung schuetzen vor parallelen Operationen und
Repo-internen User-Daten. Deinstallation deaktiviert nur die Registrierung;
Quelle, venv, Modelle, Nutzdaten, Caches und Logs bleiben erhalten.
Die Anwendung wird nicht physisch entfernt. Nur synthetische Offline-Tests,
keine Benutzer-WSL oder echten Aufnahmen fuer die Entwicklung verwendet.
