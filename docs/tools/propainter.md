# ProPainter aus GitHub, ohne Docker

Maskenbasiertes Video-Inpainting aus [sczhou/ProPainter](https://github.com/sczhou/ProPainter/tree/e870e79321c31b733e2031af5aa2fb1fe3ac7eec).
Der Installer pinnt Commit `e870e79321c31b733e2031af5aa2fb1fe3ac7eec`;
Status **experimental**. Der Root hat keinen Python-Paketinstaller:
kein erfundenes `pip install .` und keine erfundene Paketversion.

## Lizenz zuerst pruefen

Die [S-Lab License 1.0](https://github.com/sczhou/ProPainter/blob/e870e79321c31b733e2031af5aa2fb1fe3ac7eec/LICENSE)
erlaubt standardmaessig nur **nichtkommerziell** zu nutzen und weiterzugeben.
Kommerzielle Nutzung muss mit den Rechteinhabern gesondert geklaert werden.
GitHub-Verfuegbarkeit bedeutet keine pauschale Open-Source-/kommerzielle
Freigabe. Auch Gewichte und Drittbestandteile separat pruefen.

```bash
bash scripts/tools/propainter_install.sh --dry-run
# Erst nach eigener Pruefung der Lizenzbedingungen:
PROPAINTER_ACCEPT_LICENSE=1 bash scripts/tools/propainter_install.sh
bash scripts/tools/propainter_status.sh
bash scripts/tools/propainter_doctor.sh
PROPAINTER_ACCEPT_LICENSE=1 bash scripts/tools/propainter_update.sh
PROPAINTER_ACCEPT_LICENSE=1 bash scripts/tools/propainter_install.sh --repair
```

Der Lizenzschalter bestaetigt nur die bewusste Betreiberentscheidung;
das Setup erteilt keine kommerzielle Erlaubnis und fuehrt keine Rechtspruefung durch.

## Was installiert wird

Gepinnte GitHub-Quellen per Sparse-Checkout: README, LICENSE, Requirements,
`inference_propainter.py`, `model/`, `core/`, `RAFT/`, `utils/`, `configs/`.
**Nur Quellinstallation, keine betriebsbereite Video-Laufzeit.** Keine
Python-/GPU-Pakete, venv, Conda, Modelle, Demos, Training, Dienste oder Docker.
Medien, Gewichte, .env-Dateien und Notebooks bleiben ausserhalb des
Arbeitsbaums; Git-LFS-/Submodule werden nicht initialisiert.
Partial-Fetch mit `--filter=blob:none` reduziert benoetigte Git-Blobs,
garantiert aber keine feste Netzwerk-/Speichermenge.

Voraussetzungen: normaler Linux-Benutzer, Bash, Git, Python 3.10+ fuer die
AST-Pruefung, flock und realpath. Das ist keine Python-/GPU-Laufzeitfreigabe
fuer die Modellinferenz. Kein System-Python-Ersatz oder apt-Aufruf.
Der historische Upstream-Pfad verwendet Python 3.8 und weitgehend ungepinnte
Requirements; er wird nicht blind auf Ubuntu-Python 3.12 uebertragen.

## Pfade und Schutz

Ziel: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/propainter/`
mit `source/`, Lock und Quellmarker. Logs unter dem zugehoerigen
`install_logs/`. Symlink-/nicht normalisierte Datenpfade und User-Daten
im Setup-Repo werden abgelehnt. Fremde, geaenderte oder unvollstaendige
Quellordner bleiben erhalten; kein Reset oder automatisches Loeschen.
Nach manueller Pruefung/Sicherung --repair erneut aufrufen. Update nutzt
denselben Pin, kein ungeprueftes main/latest-Upgrade.

Reserve nur fuer Quellcode: 1 GiB freie Ziel-Disk, bei messbarem WSL-Host
2 GiB Windows-C:. Freier Dateisystemplatz wird vorher/nachher protokolliert.
Modelle, Inferenz-Cache, RAM und VRAM muessen getrennt geplant werden.
MiniPC/RPi/Oracle-VPS sind hier nur Quellvorbereitung; GPU-Workstation und
Kubernetes benoetigen eigene Wheel-/CUDA-/Hardwaretests. Keine gemessene
RTX-5080-/ARM-/Echtzeitzusage. Videoauflosung und Sequenzlaenge beeinflussen
den Speicherbedarf stark; Upstream nennt Reduktionsoptionen wie FP16 und
kleinere Teilsequenzen, die der Installer nicht automatisch einstellt.

Status `source_ready` beschreibt nur konsistente GitHub-Quellen;
`runtime_ready` bleibt `false`. Doctor prueft Pin, Sparse-Regeln und
ausgewaehlte Python-Syntax mit `ast.parse`, ohne Inferenz-/Torch-Import.
Das Menue meldet keine fertige Video-Anwendung.

```bash
bash scripts/tools/propainter_uninstall.sh
```

Deaktiviert nur den Quellmarker. Quellen, eigene Videos/Masken, Modelle,
Caches und Logs bleiben erhalten; keine vollstaendige Dateiloeschung.

## Noch offene Laufzeit und Gewichtsdownloads

`PROPAINTER_INSTALL_RUNTIME=1` wird mit Hinweis abgelehnt. Vor einem
Vollausbau fehlen getestete private Python-/Torch-/torchvision-/FFmpeg-
Abhaengigkeiten, passende CUDA-Wheels, Modellrevisionen/Hashes und ein
begrenzter GPU-/Speichertest. Upstream-Requirements sind keine vollstaendige
reproduzierbare Versionssperre. Python 3.8 wird hier nicht nachinstalliert.

Der [Upstream-Inferenzpfad](https://github.com/sczhou/ProPainter/blob/e870e79321c31b733e2031af5aa2fb1fe3ac7eec/inference_propainter.py)
kann fehlende **Gewichte beim ersten Inferenzstart nachladen**. Deshalb
kein Demo-/`--help`-Aufruf als Installationstest, keine automatische
Video-/Maskenverarbeitung. Offline-Flags ersetzen keine Netzwerksandbox
und verhindern nicht jeden Downloadhelfer. Erst Modell-/Lizenz-/Hashpruefung,
explizite Downloadfreigabe und isolierten Test planen.

Nur eigene oder freigegebene Videos/Masken verwenden. Bearbeitung
kennzeichnen; Ergebnisse rekonstruieren keine beweissichere Originalszene.
Der Installer startet keine Web-Demo und nimmt keine Originalmedien entgegen.

Offline-Tests pruefen Registry, Menue, Lizenz-Gate, Pfade, AST ohne Import
und Sparse-Ausschluesse mit synthetischen Git-Dateien. Kein echter
Upstream-Clone, Paket-/Modell-/GPU-Test, WSL-Zugriff oder Video-Job ausgefuehrt.
Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
