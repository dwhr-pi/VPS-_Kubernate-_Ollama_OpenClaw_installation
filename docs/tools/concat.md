# Concat: lokaler Videoschnitt nach Wan oder LTX

Stand: **22.10.2026**. [GitHub](https://github.com/jub0t/Concat),
[README](https://github.com/jub0t/Concat/blob/main/README.md),
[Release 0.2.8](https://github.com/jub0t/Concat/releases/tag/v0.2.8).

**Zweck:** Clips in einer Timeline schneiden, Ton und Untertitel bearbeiten
und Videos zusammenstellen. Concat beschreibt lokale KI-Funktionen und
JSON-RPC/MCP. Es ist kein austauschbares Wan-/LTX-Generierungsmodell und
kein bereits konfigurierter OpenClaw-MCP-Server.

## Installation aus GitHub, ohne Docker

Der eigene Tools-Menueeintrag **Concat** installiert das offizielle
**0.2.8-AppImage** fuer Linux x86_64 oder aarch64. Feste Groesse und SHA256
werden vor Freigabe geprueft. Kein Rust-Build, apt-/Systempaket oder GUI-Start.
Pruefsummen aus den offiziellen GitHub-Release-Metadaten:

| Architektur | SHA256 |
|---|---|
| x86_64 | `4e64a3826cdb86be43fc82beeb087ecb82141ea5c557f156d855fd21ff87ccb1` |
| aarch64 | `93058c09134bea4f274ea6c9578b7cda638ab81ebe4db2841b03a71f47d9e785` |

```bash
bash scripts/tools/concat_install.sh --dry-run
bash scripts/tools/concat_install.sh
bash scripts/tools/concat_status.sh
bash scripts/tools/concat_doctor.sh
bash scripts/tools/concat_update.sh
bash scripts/tools/concat_uninstall.sh
```

Bewusster manueller Start nach der Installation:

```bash
"$HOME/.openclaw_ultimate_user_data/tools/concat/runtime/Concat.AppImage"
```

Bei `OPENCLAW_USER_DATA_DIR` den anderen Datenpfad verwenden. Unter WSL
braucht die Desktop-App eine funktionierende GUI, etwa WSLg; AppImage/FUSE,
Grafiktreiber und Codecs gesondert pruefen. Ein Download beweist keinen
GUI-/GPU-Betrieb: `installed=true`, aber `runtime_ready=false`, bis Import,
Wiedergabe und Export mit eigenen Testdaten funktionieren.

Vor Download werden **2 GiB Reserve** am Linux-Ziel und bei erkannter WSL-
Umgebung auch auf C: verlangt. Modelle/Videoarchive brauchen weiteren Platz.
Bei anderer VHDX-Ablage deren echtes Hostlaufwerk ebenfalls pruefen.

## Windows und andere Plattformen

Dieser Setup-Installer ist fuer Linux/Ubuntu/WSL. Native Windows-/macOS-
Pakete und mobile Assets bietet die
[offizielle Release-Seite](https://github.com/jub0t/Concat/releases/tag/v0.2.8).
Windows-Paket bewusst manuell waehlen, nicht das AppImage. Kein automatischer
EXE-/MSI-/APK-Start; mobile Signatur-/Installationsgrenzen separat pruefen.

## Zusammenspiel mit deinem KI-Setup

```text
ComfyUI + vorhandenes Wan-/LTX-Modell -> freigegebene Clips
  -> Concat: Schnitt, eigene Tonspur, Untertitel
  -> Sicht-/Hoerpruefung -> manueller Export
```

Erster Test: eigenen kurzen Clip importieren, trimmen, eigene Tonspur
hinzufuegen und exportieren. Bildrate, Tonversatz und Schrift pruefen.
[Editierbare Rezepte](../media_studio/EDITABLE_VIDEO_WORKFLOWS.md) bleiben
eine getrennte Planungsebene ohne fertigen Concat-Adapter.

JSON-RPC/MCP erst danach mit begrenzten Dateirechten evaluieren; keine
Agentenaktivierung, offenen Ports, Mikrofon-/Modell-/Stimmendownloads durch
diesen Installer. Medien-/Modellrechte und Einwilligungen sind unabhaengig
von der [AGPL-3.0-or-later-Code-Lizenz](https://github.com/jub0t/Concat/blob/main/LICENSE).

## Status, Rollback und Deinstallation

Marker erst nach geprueftem Download. Status verlangt Marker **und**
unveraendertes AppImage; Doctor/Deinstallation pruefen das ganze Inventar.
Aenderungen oder Zusatzdateien fuehren zum Abbruch statt Datenverlust.
Eigene Projekte ausserhalb des verwalteten `runtime`-Ordners speichern.

Update bleibt bei 0.2.8. Fehler entfernen nur neue Stage-/Runtime-Dateien
dieses Versuchs. Deinstallation entfernt unveraenderte Runtime und Marker,
nicht externe Projekte, Modelle, Basiswerkzeuge oder Logs. Offline-Tests
pruefen Installerlogik, nicht die echte GUI auf deinem Rechner. Hier wurden
kein AppImage, GUI, Modell, MCP oder Export gestartet.
