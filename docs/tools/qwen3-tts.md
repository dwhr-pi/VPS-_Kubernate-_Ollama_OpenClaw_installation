# Qwen3-TTS aus GitHub ohne Docker

Stand 16.10.2026. [Quelle](https://github.com/QwenLM/Qwen3-TTS),
Pin `022e286b98fbec7e1e916cb940cdf532cd9f488e`, Python-Paket
**qwen-tts 0.1.1**. Code Apache-2.0; Modell- und Stimmenrechte separat pruefen.

## 1. Basispaket installieren

Unter Tools Qwen3_TTS auswaehlen oder im Setup-Verzeichnis:

```bash
bash scripts/tools/qwen3_tts_install.sh --dry-run
bash scripts/tools/qwen3_tts_install.sh
bash scripts/tools/qwen3_tts_status.sh
bash scripts/tools/qwen3_tts_doctor.sh
```

**Standard ist die Paketinstallation mit --no-deps, keine betriebsbereite
Sprachgenerierung.** Das GitHub-Paket wird gebaut und in einer privaten venv
installiert, ohne automatisch Torch, torchaudio oder die weiteren schweren
Laufzeitabhaengigkeiten nachzuladen. Build-Abhaengigkeiten kommen von PyPI.
Keine CLI/Demo, kein Paket-/Torch-Import und kein Modell-/Trainingsstart.

```text
~/.openclaw_ultimate_user_data/tools/qwen3_tts/source/
~/.openclaw_ultimate_user_data/tools/qwen3_tts/venv/
~/.openclaw_ultimate_user_data/tools/qwen3_tts/source-built
~/.openclaw_ultimate_user_data/install_logs/qwen3_tts_*.log
```

Linux x86_64/ARM64, Git, flock und vorhandenes Python 3.10-3.12 mit
SSL/venv/ensurepip werden vorausgesetzt. Upstream unterstuetzt weitere
Python-Versionen; unser automatischer Pfad ist bewusst enger. Ubuntu 3.12 passt.
Alternativ `QWEN3_TTS_PYTHON_BIN=python3.11` vor den Installer setzen.
Fehlendes venv-Paket separat passend zur Python-Version einrichten;
kein System-Python-, Treiber- oder apt-Umbau durch diesen Installer.

Basispaket-Reserve: 1 GiB RAM gesamt, mindestens 512 MiB verfuegbar und
2 GiB freie Linux-Disk sowie unter WSL soweit messbare Windows-C:-Reserve.
Das reicht nicht automatisch fuer spaetere Modelle, Audios oder Training.

## 2. Optional die Laufzeitabhaengigkeiten ergaenzen

1. Zuerst das Basispaket installieren.
2. In **genau dieser venv** passende Torch-/torchaudio-Wheels fuer deinen
   CPU-/CUDA-/ROCm-Pfad bewusst einrichten. Nicht die Systeminstallation verwenden.
   Den passenden Befehl mit der [offiziellen PyTorch-Auswahl](https://pytorch.org/get-started/locally/)
   bestimmen und dabei den Python-Pfad unserer venv statt globalem pip verwenden.
   Keine pauschale CUDA-Version fuer jede GPU uebernehmen.
3. Erst dann die restlichen Abhaengigkeiten explizit freigeben:

```bash
QWEN3_TTS_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/qwen3_tts_install.sh --dry-run

QWEN3_TTS_INSTALL_RUNTIME=1 INSTALL_HEAVY_TOOLS=1 \
  bash scripts/tools/qwen3_tts_install.sh
```

Dieser zweite Schritt verlangt mindestens 8 GiB RAM gesamt, 4 GiB aktuell
verfuegbar und 20 GiB freie Disk/messbare Windows-C:-Reserve. Er kann viele
Pakete herunterladen, aber keine Modellgewichte. Nur einen schweren Job
gleichzeitig starten; kein automatischer Queue-Start durch diese Erweiterung.

Vorhandene Torch-/torchaudio-Versionen werden **nur aus Metadaten** gelesen.
Ihre Release-Version muss zusammenpassen; beide exakten Builds werden als
pip-Constraints festgehalten. Pip darf sie nicht stillschweigend ersetzen.
Torch, torchaudio, ONNX Runtime, NumPy und SciPy muessen als passende Wheels
verfuegbar sein; andere Abhaengigkeiten koennen kleine Source-Builds benoetigen.
Fehlende Systemwerkzeuge/-bibliotheken separat einrichten. Keine automatische
Flash-Attention-, Treiber-, CUDA- oder SoX-Systempaketinstallation.

Ein Metadatencheck beweist weder ABI-/CUDA-Kompatibilitaet noch funktionierende
Sprachgenerierung. Runtime-Abhaengigkeiten und Modellfreigabe sind getrennt.
SDK-/Quell-Pin fest; die gesamte Abhaengigkeitskette ist noch kein Hash-Lock.

## 3. Modelle und spaetere Nutzung

Qwen3-TTS unterscheidet unter anderem Base fuer Voice Cloning,
CustomVoice fuer vorgegebene Stimmen und VoiceDesign fuer beschriebene Stimmen.
Nicht jedes Modell unterstuetzt jede Funktion. Die Variante und ihre aktuelle
Modellkarte vor Download lesen. Laut Upstream kann das Laden einer Modell-ID
automatisch Gewichte nachladen.

Unser Installer setzt im eigenen Unterprozess Hub/Transformers auf offline
und entfernt Hub-Tokenvariablen. Das veraendert nicht deine aufrufende Shell
und ist keine Betriebssystem-Netzwerksandbox.
Es wird keine Modell-ID an from_pretrained uebergeben, kein Demo-/Help-Aufruf
gestartet und keine Audiodatei verarbeitet. Kein API-Key erforderlich.

Fuer spaetere manuelle Nutzung nur eigene oder autorisierte Referenzstimmen
und lizenzierte Texte verwenden, KI-Ausgabe kennzeichnen und Originaldaten
privat sichern. Keine Stimmenklone ohne Einwilligung. API-/Cloud-Alternativen
sind keine Voraussetzung fuer den lokalen Modellpfad.

Eine Demo wuerde einen eigenen Port benoetigen; dann ausschliesslich
Loopback und keine Share-/oeffentlichen Links verwenden. Der Installer
oeffnet keinen Port; die Registry-Portliste bleibt leer.

## 4. Einordnung in unser Setup

| Zielhost | Empfehlung |
|---|---|
| MiniPC / WSL2 | Basispaket leicht; Runtime/Modelle separat budgetieren, CPU langsam |
| RPi5 / Oracle ARM | Basispaket moeglich, Wheels/GPU-Inferenz nicht hier bestaetigt |
| Oracle VPS | eher Queue/Steuerung statt oeffentlicher Sprachdienst |
| Gaming-PC / RTX 5080 | passender CUDA/Torch-Pfad und Modell-VRAM pruefen |
| Dual Xeon | viele Kerne ersetzen keine passende GPU/VRAM |
| Kubernetes | kein Deployment durch diesen nativen Installer |

VRAM/RAM und Geschwindigkeit haengen von Modellgroesse, Precision,
Textlaenge, Batch und Attention-Backend ab; kein pauschaler VRAM-Erfolg versprochen.
Windows/macOS nativ sind in dieser Integration nicht getestet.

Die [Alexandria-Vorbereitung](alexandria-audiobook.md) hat eine eigene venv.
Diese Qwen-Installation fuellt sie nicht automatisch aus und macht Alexandria
nicht ohne Weiteres betriebsbereit. Kein Kopieren fremder venvs.

## 5. Update, Doctor und Deaktivierung

```bash
bash scripts/tools/qwen3_tts_update.sh --dry-run
bash scripts/tools/qwen3_tts_update.sh
bash scripts/tools/qwen3_tts_install.sh --repair
bash scripts/tools/qwen3_tts_uninstall.sh
```

Fuer Runtime-Update/Repair beide Freigabevariablen wie oben setzen.
Updates bleiben am selben Commit, kein latest. Fremde/veraenderte Checkouts
werden nicht resettet; kein rekursives Loeschen von Benutzerdaten.
Lock/Logs und Vorher-/Nachher-Diskmessung sind integriert.

Doctor im Modus package prueft nur Version, Quellursprung, venv und
Demo-Entry-Point-Metadaten. Fehlende Runtime-Abhaengigkeiten sind dort erwartet:
kein irrefuehrendes volles pip check. Modus runtime prueft zusaetzlich
Torch-/torchaudio-Metadaten und pip check. Status trennt installed,
runtime_dependencies, models_checked und inference_tested.

Uninstall entfernt nur den Marker; Quelle, venv, Modelle, eigene Audios
und gegebenenfalls vorhandene Zugangsdaten bleiben erhalten.

Offen: reale CPU/GPU-Inferenzmatrix, Modellrevisionen/Hashes, Dependency-Lock,
sicherer Demo-/Servicepfad und Queue-/Backup-/Restore-Test. Repository-Tests
verwenden Mocks, keine echten Paketinstallationen, Modelle oder GPU-Auftraege.

Quellen: [Paketmetadaten am Pin](https://github.com/QwenLM/Qwen3-TTS/blob/022e286b98fbec7e1e916cb940cdf532cd9f488e/pyproject.toml),
[offizielle Modell-/Nutzungsanleitung](https://github.com/QwenLM/Qwen3-TTS/blob/022e286b98fbec7e1e916cb940cdf532cd9f488e/README.md).
