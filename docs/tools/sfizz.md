# Sfizz aus GitHub, ohne Docker

Sfizz ist eine native SFZ-Sampler-Engine: MIDI steuert Instrumentdefinitionen und deren Samples. Es
erzeugt keine neuen Stimmen oder Instrumente per KI. Quelle:
[sfztools/sfizz, Release 1.2.3](https://github.com/sfztools/sfizz/releases/tag/1.2.3), fest auf
Commit `4e70dc0bef53b41f2853ed46e26f5911114c92d0`. Das
[Repository](https://github.com/sfztools/sfizz) ist archiviert. Status **experimental**, nicht als
sicherer/gewarteter Produktivstack eingestuft. Die DAW-Plugins gehoeren zum separaten
[sfizz-ui](https://github.com/sfztools/sfizz-ui) und werden hier nicht installiert.

## Installation im Setup

Der Menuepunkt Sfizz verwendet nun eigene Skripte statt des Medien-Guards. Diese Kommandos sind zur
bewussten Ausfuehrung durch den Benutzer gedacht:

```bash
bash scripts/tools/sfizz_install.sh --dry-run
bash scripts/tools/sfizz_install.sh
bash scripts/tools/sfizz_status.sh
bash scripts/tools/sfizz_doctor.sh
```

Standard: echte GitHub-Quellinstallation, noch keine ausfuehrbare Anwendung. Sechs Unterprojekte
sind separat auf Git-Commits festgelegt: Abseil, filesystem, SIMDe, dr_libs, libaiff und WavPack.
Siehe [Manifest](../../scripts/tools/helpers/sfizz_common.sh). Keine beweglichen Branches oder
rekursive Downloads unbekannter Unterprojekte. Verschachtelte Test-Abhaengigkeiten von SIMDe/dr_libs
werden nicht benoetigt und nicht geladen. Quellen koennen Upstream-Testressourcen enthalten; keine
zusaetzlichen Instrument-/Samplebibliotheken, keine Modelle und kein Docker. Pins sind keine
Signaturpruefung oder Sicherheitsaudit des Upstream-Codes.

## Optionaler nativer Offline-Renderer

```bash
SFIZZ_BUILD=1 SFIZZ_BUILD_JOBS=1 bash scripts/tools/sfizz_install.sh
```

Das CMake-Ziel `sfizz_render` wird in Release-Konfiguration privat gebaut. JACK, Shared-Library,
Tests, Benchmarks, Demos, Devtools, libsndfile und LTO sind abgeschaltet. Kein
Audiogeraet/JACK-Daemon erforderlich fuer diesen Buildpfad. Kein `cmake --install`, kein globaler
Plugin-/PATH-Eintrag, kein Audio-, Mikrofon-, Service- oder Browserstart. CMake-FetchContent ist
disconnected; dies ist keine Betriebssystem-Netzwerksandbox. Build-Skripte des Upstream sind
ausfuehrbarer Fremdcode, vor Opt-in pruefen.

Voraussetzungen: normaler Linux-Benutzer, Bash, Git, Python 3.10+, flock, realpath und uebliche
GNU-Werkzeuge. Fuer den Build: CMake >=3.19 und <4, make und C/C++-Compiler (mindestens C++14).
Unter Ubuntu z. B. `build-essential` und passende CMake-Version separat einrichten. Keine
automatische Systempaketinstallation oder System-Python-Aenderung.

Ziel: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/sfizz/`. Quellen in
`source/`, Build in `build/`, Renderer nach erfolgreichem Build: `build/library/bin/sfizz_render`.
Kein automatischer Test mit echten Samples. Fuer die spaetere Nutzung eigene lizenzierte
SFZ-/Sample-Dateien sowie MIDI bereitstellen und die CLI-Optionen aus der Upstream-Dokumentation
pruefen.

## Ressourcen und Zielhost

| Pfad/Host             | Reserve bzw. Einschraenkung, keine gemessene Laufzeitzusage                        |
| --------------------- | ---------------------------------------------------------------------------------- |
| Nur Quellen           | 1 GiB freie Ziel-Disk; bei messbarem WSL-Host 2 GiB Windows-C:                     |
| Build                 | 4 GiB Gesamt-RAM, 2 GiB aktuell verfuegbar; 4 GiB freie Ziel-Disk und Windows-C:   |
| MiniPC/WSL2/Intel/AMD | Linux x86_64; standardmaessig ein Build-Job, maximal zwei                          |
| Raspberry Pi          | ARM64-Pfad vorgesehen, realer Build/SIMD ungetestet; kein ARM32-Pfad               |
| Oracle VPS/Kubernetes | Offline-Renderer vorgesehen, keine Cluster-/Audioeinrichtung                       |
| GPU-Workstation       | CPU-Renderer, keine CUDA-/VRAM-Anforderung; Samplegroesse bestimmt Laufzeitbedarf  |
| Windows/macOS         | Dieser Installer installiert dort nicht nativ; separate Upstream-Anleitung pruefen |

Diese Werte sind Installer-Schutzgrenzen, keine Upstream-Benchmarks.

## Status, Update und Deinstallation

`source_ready` prueft feste Repo-/Unterprojekt-Pins und unveraenderte Quellen. `native_built` prueft
ELF64-Header/Hostarchitektur sowie registrierte SHA-256, ohne die Datei auszufuehren. `audio_tested`
bleibt `false`; ein ELF-Artefakt beweist keine aufloesbaren Bibliotheken oder korrektes Rendering.
Doctor gibt bei gueltigen Quellen Erfolg zurueck, auch ohne Renderer; die JSON-Felder unterscheiden
dies explizit. Kein allgemeiner Menue-Eintrag fuer getesteten Audio-Betrieb wird hinzugefuegt.

```bash
bash scripts/tools/sfizz_update.sh
bash scripts/tools/sfizz_install.sh --repair
bash scripts/tools/sfizz_uninstall.sh
```

Update bleibt auf demselben Pin; --repair setzt fremde/geaenderte Quellen nicht zurueck. Eine Sperre
verhindert parallele Operationen. Symlinkpfade, Repo-interne User-Daten und fremde Build-Ordner
werden abgelehnt. Logs unter dem privaten User-Workspace in `install_logs/`; Disk vorher/nachher.
Deinstallation deaktiviert nur Quell-/Buildregistrierung: Quellen, Binary, Instrumente und Logs
bleiben erhalten, keine rekursive Datenloeschung.

BSD-2-Clause gilt fuer die Engine, nicht pauschal fuer alle Unterprojekte, Instrumente oder Samples.
Nur berechtigte Inhalte verwenden. Der lokale Installer wurde mit synthetischen Offline-Tests
geprueft, nicht durch einen realen Linux-/ARM-/Audiobuild in der Benutzer-WSL.
