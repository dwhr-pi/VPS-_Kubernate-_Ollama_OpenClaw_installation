# YuE aus GitHub, ohne Docker

YuE erzeugt Musik mit Gesang aus Text-/Stilvorgaben. Dieses Setup installiert die Quellen des
**urspruenglichen YuE-v1**, nicht ungefragt YuE2. Quelle:
[YuE-v1, fester Commit](https://github.com/multimodal-art-projection/YuE/tree/6d4f0b1f8ce6a55fb2392e959394c46e07ee334d),
`6d4f0b1f8ce6a55fb2392e959394c46e07ee334d`. Das
[aktuelle main](https://github.com/multimodal-art-projection/YuE) enthaelt inzwischen YuE2 mit
anderem Paketlayout und anderen Anforderungen. Eine Migration benoetigt einen eigenen geprueften
Installationspfad.

## GitHub-Quellen installieren

Der Menuepunkt YuE verwendet nun eigene Skripte statt des Medien-Guards. Zur bewussten Ausfuehrung
durch den Benutzer:

```bash
bash scripts/tools/yue_install.sh --dry-run
bash scripts/tools/yue_install.sh
bash scripts/tools/yue_status.sh
bash scripts/tools/yue_doctor.sh
```

Ein gepinnter Sparse-Checkout stellt Inferenzcode, Prompt-Beispiele, README, Lizenz und Requirements
bereit. Medien, Gewichte, Notebooks, Tokenizer-Binaerdateien und echte `.env`-Dateien werden
ausgeschlossen. Git-LFS-Smudge und rekursive Submodul-Downloads werden nicht ausgefuehrt. Keine
Docker-/Systempaketinstallation, kein Git-LFS-Globalsetup. Der Pin ist keine Signaturpruefung oder
Sicherheitsaudit des Fremdcodes.

Status **experimental/gpu-heavy**. Dies ist eine **Quellinstallation**, noch keine betriebsbereite
Musik-Anwendung. YuE-v1 hat hier kein regulaeres Python-Paketprojekt: kein vorgetaeuschtes
`pip install -e` im Repository-Root. Die Syntaxpruefung verwendet AST-Parsing ohne
SDK-/Torch-/Inferenz-Imports.

Voraussetzungen fuer diesen Quellinstaller: normaler Linux-Benutzer, Bash, Git, Python 3.10+ fuer
die Pruefung, flock, realpath und GNU-Werkzeuge. Reserve: 1 GiB Gesamt-RAM, 512 MiB aktuell
verfuegbar, 1 GiB freie Ziel-Disk und bei messbarem WSL-Host 2 GiB Windows-C:. Keine Aussage ueber
den deutlich groesseren Runtime-/Modellbedarf.

## Was fuer die Runtime separat fehlt

Die ungepinnten Python-Requirements enthalten Torch, torchaudio, Transformers, Audio-Codecs und
weitere Pakete. Eine passende private Python-/Torch-/CUDA-Umgebung muss separat geprueft werden.
Python 3.10+ fuer den Installer ist keine Zusage, dass jede dieser Python-Versionen mit jeder
YuE-Abhaengigkeit funktioniert. Kein automatischer Treiberumbau.

Zusaetzlich benoetigt die Inferenz den **xcodec**-Tokenizer mit seinen Dateien/Checkpoints sowie
Stage-1-/Stage-2-Modelle. Der upstream referenzierte xcodec-Gitlink verweist auf eine separate
Modellquelle; dieser Installer initialisiert ihn nicht. Ein leerer Gitlink-Ordner ist kein
installierter Tokenizer. Kein HF-Login, keine Token-Anforderung und keine automatische
Lizenzannahme, Modell- oder Trainingsdaten-Downloads.

`YUE_INSTALL_RUNTIME=1` wird mit Begruendung abgelehnt: Es gibt noch keinen getesteten, gepinnten
Runtime-Installer. Zur spaeteren bewussten Einrichtung die
[Quickstart-Anleitung dieses Pins](https://github.com/multimodal-art-projection/YuE/blob/6d4f0b1f8ce6a55fb2392e959394c46e07ee334d/README.md)
lesen, passende Pakete und externe Modelle einzeln pruefen und Speicher vorher budgetieren. Ein
Inferenzstart kann weitere Modelle automatisch nachladen. Der Quellinstaller startet weder diese
Inferenz noch Training. Flash-Attention ist in diesem Pin optional; kein ungefragter nativer Build.

## Zielhosts und Sicherheit

| Host                    | Einschraenkung                                                                         |
| ----------------------- | -------------------------------------------------------------------------------------- |
| MiniPC/WSL2             | Quellvorbereitung moeglich; Windows-C: kann trotz grosser Linux-Freianzeige knapp sein |
| Raspberry Pi/Oracle VPS | Quellen moeglich; keine CPU-/ARM-Musik-Runtime versprochen                             |
| GPU-Workstation         | GPU-, RAM-, VRAM- und Checkpointbedarf nach Modell/Segmentzahl separat pruefen         |
| Kubernetes              | Kein automatisches Deployment, GPU-Scheduling oder Serverstart                         |

Kein Server-Port und keine neuen oeffentlichen Freigaben. Spaetere lange Jobs seriell ueber die
Queue planen, keine pauschalen Laufzeit-/VRAM-Zusagen. Hauptlizenz Apache-2.0; Tokenizer, Modelle
und Drittanbieter separat pruefen. Eigene/rechtmaessig lizenzierte Texte, Musik und Referenzstimmen
verwenden; Einwilligung fuer fremde Stimmen einholen und KI-Inhalte kennzeichnen.

## Lifecycle und Status

```bash
bash scripts/tools/yue_update.sh
bash scripts/tools/yue_install.sh --repair
bash scripts/tools/yue_uninstall.sh
```

Update/Repair bleibt auf demselben YuE-v1-Pin, kein latest/main-Wechsel. Fremde/geaenderte Quellen
werden nicht geloescht oder zurueckgesetzt. Die Daten liegen unter
`${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/yue/`. Logs unter dem privaten
User-Workspace in `install_logs/`, Diskmessung vor/nach Installation. Sperre und
Symlink-/Pfadpruefung verhindern parallele Operationen und User-Daten innerhalb des
Setup-Repositories.

`source_ready` bedeutet gueltiger Pin/Origin/Sparse-Checkout; `runtime_ready` bleibt `false`. Doctor
prueft zusaetzlich die Syntax, nicht Musikqualitaet, GPU oder Tokenizer. Deinstallation deaktiviert
nur die Quellregistrierung und bewahrt Quellen, Daten/Modelle und Logs. Keine echte Installation,
Inferenz oder Benutzer-WSL fuer die Entwicklung verwendet; Tests laufen mit synthetischen lokalen
Daten ohne Modelldownloads.
