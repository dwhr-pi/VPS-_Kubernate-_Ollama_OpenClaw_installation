# MuseTalk: GitHub-Quelle und private Python-Runtime

MuseTalk erzeugt audio-gesteuerte Lippenbewegungen fuer vorhandene Gesichter/
Videos. Der Setup-Eintrag bereitet Quellen und eine isolierte Python-Umgebung
vor, nicht automatisch ein fertiges Video oder einen laufenden Webdienst.
Nur eigene beziehungsweise freigegebene Stimmen, Gesichter und Medien verwenden.

## Umfang und Grenzen

Stand: 23.10.2026. Offizielle Quelle:
[TMElyralab/MuseTalk](https://github.com/TMElyralab/MuseTalk/tree/0a89dec45a0192b824e3cf4daf96c239440c5ed8).
Pin: `0a89dec45a0192b824e3cf4daf96c239440c5ed8`.
Der [Upstream-Installationsabschnitt](https://github.com/TMElyralab/MuseTalk/blob/0a89dec45a0192b824e3cf4daf96c239440c5ed8/README.md#installation)
empfiehlt Python 3.10, Torch 2.0.1/cu118 und MMCV 2.0.1.
Hauptanwendung aus GitHub, ohne Docker. Python-Paketabhaengigkeiten kommen
aus PyPI sowie den offiziellen PyTorch-/OpenMMLab-Wheel-Indizes. Das ist kein
Source-Build saemtlicher Abhaengigkeiten und keine signierte Supply-Chain-Abnahme.

**RTX 5080 / Blackwell:** Dieser alte Upstream-Stack ist dafuer nicht freigegeben.
PyTorch beschreibt Blackwell-Unterstuetzung ab
[PyTorch 2.7/CUDA 12.8](https://pytorch.org/blog/pytorch-2-7/).
Das ist noch kein Beleg, dass das alte MMCV/MMPose damit funktioniert. Der
Installer bricht bei erkannter Compute Capability >= 10 vor Paketdownloads ab;
kein heimlicher CPU-Fallback, keine Treiber-/CUDA-/System-Python-Aenderung.
Ein moderner Blackwell-Pfad braucht eine eigene Integrations-/GPU-Abnahme und
ist mit diesem Patch **nicht implementiert**. Auch eine andere NVIDIA-GPU ist
erst nach bestandenem Torch-/MMCV-CUDA-Smoke-Test als Paketumgebung nachgewiesen.

## Voraussetzungen und Speicher

- Ubuntu/WSL Linux x86_64; Windows nativ und andere Architekturen nicht abgenommen.
- Vorhandene Werkzeuge: Git, uv, FFmpeg, FFprobe und NVIDIA-Treiber/nvidia-smi.
- Vorhandenes Python 3.10 mit SSL: optional `MUSETALK_PYTHON_BIN=/absoluter/pfad/python3.10`.
- Fehlt Python 3.10, ist ein privater GitHub-python-build-standalone-Download
  via vorhandenem uv nach Rueckfrage moeglich. Nichtinteraktiv ohne Freigabe
  wird abgebrochen; bewusste Freigabe: `MUSETALK_INSTALL_PYTHON=1`.
- Mindestens **20 GiB = 20480 MiB** freier Zielspeicher; unter WSL auch auf C:.
  Konservative Startreserve, keine garantierte Endgroesse. Bei 8,5 GiB auf C:
  wird vor Download abgebrochen. Nichts automatisch loeschen oder die Reserve
  senken. Der Platzmangel steht im aktuellen Operationslog.

## Installation und bestehender Quellcheckout

```bash
bash scripts/tools/musetalk_install.sh --dry-run
bash scripts/tools/musetalk_install.sh
bash scripts/tools/musetalk_status.sh
bash scripts/tools/musetalk_doctor.sh
```

Der Dry-run macht keine Hardwareabfrage und keinen Download. Installation/
Update pruefen lokal zuerst den Speicher und die GPU-Kompatibilitaet. Nur danach
werden Pakete geladen. Es erfolgt kein Aufruf von `download_weights.sh`,
`app.py`, Inferenz, Training oder eines ComfyUI-Installers. Die abschliessende
Pruefung importiert Bibliotheken und testet kleine Torch-/MMCV-CUDA-Operationen;
MuseTalk-Module mit modellladenden Import-Nebenwirkungen werden nicht importiert.

Ziele unter `~/.openclaw_ultimate_user_data/tools/musetalk/`:

| Pfad | Bedeutung |
|---|---|
| `runtime/`, `ready.json` | Bisheriger gepinnter Quellcheckout und Quellenbesitznachweis |
| `python-runtime/.venv/` | Getrennte Python-Paketumgebung |
| `python-runtime/.python/` | Optionales privates Python, nur nach Freigabe |
| `python-runtime/resolved-requirements.txt` | Tatsaechlich aufgeloeste Paketversionen |
| `runtime-ready.json` | Nachweis der geprueften Abhaengigkeiten, **kein Inferenznachweis** |

Ein unveraenderter alter Quellcheckout wird weiterverwendet, nicht geloescht.
Bei fehlgeschlagenem Upgrade werden nur neue Runtime-Dateien entfernt; alte
Quellen und ausserhalb liegende Daten bleiben. Neue Erstinstallationsquellen
werden beim Fehler nur entfernt, sofern ihr Besitznachweis unveraendert passt.
Partielle oder fremde Python-Ordner ohne Nachweis werden nicht ueberschrieben.
Repair/Update wechseln nicht automatisch auf main/latest und loeschen keine
bestehende Umgebung, um einen erneuten Versuch zu erzwingen.

Die alten Quellenwege bleiben ausdruecklich nutzbar:

```bash
bash scripts/tools/musetalk_install.sh --source-only
bash scripts/tools/musetalk_status.sh --source-only
# Auch ein alter Quellenbestand ohne Python-Runtime ist ueber die CLI entfernbar:
bash scripts/tools/musetalk_uninstall.sh
```

Im Menue gilt der alte Quellenmarker allein nicht mehr als installierte Runtime.
`status` meldet `sources_present`, `dependencies_ready` und `runtime_tested`.
Ohne Gewichte/Inference bleibt `runtime_tested=false`, auch nach Paketpruefung.
Doctor vergleicht die vollstaendige Paketdatei-Inventur; das kann wegen grosser
Torch-Dateien dauern. Status fuehrt keine Downloads, GPU-Probe oder Paketcode aus.

## Modelle, Start und Daten erhalten

Modelldownload, Lizenzpruefung und Start sind **separate manuelle Freigaben**,
keine automatisch aktivierten Setup-Aktionen. Es gibt hierfuer keinen neuen
Download-/Start-Schalter. Gewichte nur aus den im gepinnten Upstream genannten
Quellen beziehen und Herkunft/Lizenzen pruefen; alte Torch-Serialisierung nur
mit vertrauenswuerdigen Dateien nutzen. Keine fremden Pickle-/Checkpoint-Dateien.
Noch kein Video-/Audio-Smoke-Test, keine RTX-5080-Funktionsgarantie.

Vor Deinstallation Quellen und Python-Dateien vollstaendig pruefen:

```bash
bash scripts/tools/musetalk_uninstall.sh --dry-run
bash scripts/tools/musetalk_uninstall.sh
```

Veraenderte/ergaenzte Dateien blockieren die Entfernung statt still geloescht zu
werden. Modelle/Ergebnisse im Quellordner deshalb zuvor bewusst sichern; Daten
ausserhalb der beiden verwalteten Ordner und Installationslogs bleiben erhalten.
Geteilte Basiswerkzeuge werden nicht deinstalliert. Abhaengigkeiten werden nach
erfolgreicher Installation inventarisiert, aber nicht mit einem vollstaendigen
Hash-Lock aus dem Repo installiert: transitive Paketaufloesung kann sich aendern.

## Pruefnachweis

[Offline-Fixtures](../../tests/test_musetalk_runtime.py) pruefen Upgrade,
Rollback, Status, Speichermangel-Logging, Blackwell-Sperre und Freigabegrenzen.
Keine echten Pakete/Modelle installiert und keine GPU-Inferenz ausgefuehrt.
Eine reale Ubuntu-/GPU-Installation bleibt zur Abnahme offen.

Lokaler Nachweis vom 23.10.2026 unter Windows: 15 MuseTalk-Fixtures,
21 bestehende Gap-Tool-Fixtures und 8 native Status-/Build-Dependency-Fixtures
bestanden (44 gesamt). Bash-Syntax fuer Menue/Statushelper, JSON-Konfigurationen,
lokale Dokumentationslinks und `git diff --check` bestanden. Der echte
Installer-Dry-run wurde mit dem normalen Wrapper-Python-Aufruf (`-B`, nicht
`-I`, da dieser Alt-Helper lokale Geschwistermodule importiert) erfolgreich
ausgefuehrt. Kein vollstaendiger Repo-CI- oder Linux-/GPU-Abnahmenachweis.
