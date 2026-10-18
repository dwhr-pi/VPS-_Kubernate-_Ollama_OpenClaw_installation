# AIDA-X aus GitHub, ohne Docker

AIDA-X ist ein nativer Amp-Modell-/Cabinet-IR-Player, kein TTS- oder
Musikgenerator und kein eigener Capture-/Trainingserver. Quelle:
[AidaDSP/AIDA-X, Tag 1.1.0](https://github.com/AidaDSP/AIDA-X/tree/1.1.0),
auf Commit `1027cdd1756505fd2ab1a4adb91a394a3af9df57` festgelegt.
Status **experimental**: kein realer Audio-/Buildtest im Benutzer-System.

## GitHub-Quellen installieren

```bash
bash scripts/tools/aida_x_install.sh --dry-run
bash scripts/tools/aida_x_install.sh
bash scripts/tools/aida_x_status.sh
bash scripts/tools/aida_x_doctor.sh
bash scripts/tools/aida_x_update.sh
bash scripts/tools/aida_x_install.sh --repair
```

Standardmaessig werden Quellen und acht fest gepinnte GitHub-Unterprojekte
bereitgestellt: DPF, DPF-Widgets, RTNeural, FFTConvolver, dr_libs, r8brain
sowie DPF/pugl und RTNeural/xsimd. URLs und Commits sind im
[Installer-Manifest](../../scripts/tools/helpers/aida_x_common.sh) aufgefuehrt.
Kein ungeprueftes rekursives `submodule --remote`, kein Docker, keine
Systempakete und kein Audio-/Mikrofon-/DAW-Start. Git-Objekte stammen aus
GitHub; Pins sind keine unabhaengige Signatur-/Sicherheitspruefung.

Die Quellen enthalten die von Upstream eingebauten Amp-/IR-Ressourcen,
die auch fuer den CMake-Build benoetigt werden. Keine zusaetzlichen
Modellpacks aus Google Drive oder anderen Diensten werden heruntergeladen.

## Optional: nativen Standalone bauen

Erst nach Pruefung vorhandener Build-Werkzeuge/Entwicklungspakete:

```bash
AIDA_X_BUILD=1 bash scripts/tools/aida_x_install.sh
# Alternativ nach erfolgter Quellinstallation:
AIDA_X_BUILD=1 AIDA_X_BUILD_JOBS=1 bash scripts/tools/aida_x_update.sh
```

Der Build verwendet CMake, Release-Modus und ausschliesslich Ziel
`AIDA-X-Standalone-jack`. Standardparallelitaet **1**, maximal 2 Jobs.
JUCE-Extras sind abgeschaltet, CMake-FetchContent wird auf disconnected
gesetzt. Kein `cmake --install`, kein Kopieren in globale Plugin-Ordner,
keine Autostart-/Audio-/Gruppen-/Socket-Aenderung. Der Build fuehrt
Upstream-Buildwerkzeuge wie den Ressourcen-Konverter aus, nicht die Audio-App.
Disconnected ist keine Betriebssystem-Netzwerksandbox.

Ziel ist `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/aida_x/`:
`source/`, `build/`, `source-ready`, `native.json`, `operation.lock`.
Die Binaerdatei liegt nach erfolgreichem Build unter `build/bin/AIDA-X`.
Sie wird nicht automatisch gestartet, auch nicht mit `--help` als Test.

Voraussetzungen fuer die Quellen: normaler Linux-Benutzer, Bash, Git,
Python 3.10+ fuer Status-/Artefaktpruefung, flock und realpath.
Build zusaetzlich: CMake >=3.15, make, C/C++-Compiler (C++17), pkg-config
und Entwicklungspakete fuer X11, Xcursor, Xrandr, Xinerama, OpenGL, ALSA,
JACK. Auf Ubuntu entsprechen diese typischerweise `build-essential`,
`cmake`, `pkg-config`, `libx11-dev`, `libxcursor-dev`, `libxrandr-dev`,
`libxinerama-dev`, `libgl1-mesa-dev`, `libasound2-dev`, `libjack-jackd2-dev`.
Der Installer prueft Werkzeuge/pkg-config, installiert sie aber nicht.
Fehlende oder inkompatible CMake-/Bibliotheksversionen bleiben Buildfehler;
keine automatische Distribution-/Audio-Stack-Reparatur.

## Ressourcen und Hostklassen

| Pfad | Installer-Reserve, kein Echtzeit-Benchmark |
|---|---|
| Nur Quellen | 1 GiB freie Ziel-Disk, bei messbarem WSL-Host 2 GiB Windows-C: |
| Standalone-Build | 4 GiB Gesamt-RAM, davon 2 GiB aktuell verfuegbar; 4 GiB freie Ziel-Disk und Windows-C:, 1 Build-Job |
| MiniPC/WSL2 | CPU-Build moeglich; GUI/WSLg und Audio-Weiterleitung separat testen, keine WSL-Aenderungen durch den Installer |
| Oracle VPS/Kubernetes | Quellen/Buildvorbereitung; ohne lokale Audiogeraete kein getesteter Amp-Betrieb |
| Raspberry Pi/ARM64 | ARM64-Quell-/Buildpfad vorgesehen, konkrete SIMD-/GUI-/Audio-Kompatibilitaet ungetestet |
| Intel/AMD/GPU-Workstation | Linux x86_64 vorgesehen; kein CUDA/PyTorch oder GPU-Modelltraining erforderlich |

Fuer macOS/Windows stellt Upstream eigene [Release-Downloads](https://github.com/AidaDSP/AIDA-X/releases/tag/1.1.0)
bereit. Dieser Linux-Installer fuehrt keine Windows-/macOS-Installation aus.

## Status, Updates und Deinstallation

`source_ready` prueft Repo- und acht Unterprojekt-Pins sowie unveraenderte
Quellen. `native_built` prueft den ELF-Header/Hostarchitektur und SHA-256
der registrierten Standalone-Datei, ohne sie auszufuehren.
`audio_tested` bleibt immer `false`; ein ELF-Artefakt beweist keine
aufloesbaren Systembibliotheken, funktionierende GUI oder Audioqualitaet.
Doctor ist eine Quell-/Artefaktpruefung, kein DAW-/Latenztest.
Das Setup setzt keinen allgemeinen Eintrag fuer getesteten Audio-Betrieb.

Logs liegen unter dem privaten User-Workspace in `install_logs/`, mit
vorher/nachher gemessenem Dateisystemplatz. Eine Sperre verhindert parallele
Operationen. Symlink-/nicht normalisierte Datenpfade, Repo-interne User-Daten,
fremde/geaenderte Quellen oder fremde Build-Ordner werden nicht ueberschrieben.
Updates verwenden denselben Pin. Nach Sicherung/Pruefung --repair erneut
aufrufen; keine automatische Loeschung unvollstaendiger fremder Ordner.

```bash
bash scripts/tools/aida_x_uninstall.sh
```

Deaktiviert nur Quell-/Buildregistrierung. Quellen, Binaerdatei, eigene
Amp-Modelle/IRs und Logs bleiben erhalten; keine vollstaendige Dateiloeschung.

## Audio und Lizenz

Erster manueller Start nur in einer kontrollierten Audioumgebung mit
passendem Interface/Host. Eingangsfreigabe und Pegel bewusst pruefen;
Rueckkopplung, Lautstaerkespruenge und knacksende zu kleine Puffer vermeiden.
DAW-Plugins, weitere Formate, Modelltraining und Capture sind eigene Schritte.
Die separate Embedded-/Headless-Variante aidadsp-lv2 wird nicht mitinstalliert.

[GPL-3.0-or-later](https://github.com/AidaDSP/AIDA-X/blob/1.1.0/LICENSE),
Drittbestandteile sowie Amp-Modell-/IR-Rechte separat beachten.
Keine automatische Modell-/Trainingsdaten-Lizenzfreigabe.

Offline-Tests simulieren CMake/Fetch-Operationen und pruefen Artefakt-Hashes
an synthetischen ELF-Bytes. Kein echter GitHub-Clone, CMake-/Audio-Build,
App-Start oder Zugriff auf die WSL des Benutzers wurde dafuer ausgefuehrt.
Siehe [Medienkatalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md).
