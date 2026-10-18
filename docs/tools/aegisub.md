# Aegisub aus GitHub, ohne Docker

Aegisub ist ein Desktop-Editor fuer ASS-/SSA-/SRT-Untertitel, Timing,
Typesetting und Karaoke. Kein TTS-, Gesangs- oder KI-Videogenerator.
Quelle: [TypesettingTools/Aegisub v3.5.1](https://github.com/TypesettingTools/Aegisub/releases/tag/v3.5.1),
Commit `088ca6caa878209e279871f8897273f49342372b`.
Status **experimental** fuer diesen Installer, kein realer Linux-/ARM-
Build oder GUI-/Audiotest bei der Entwicklung ausgefuehrt.

## GitHub-Quellen installieren

Der Menuepunkt Aegisub nutzt nun eigene Skripte statt des Medien-Guards.
Zur bewussten Ausfuehrung durch den Benutzer:

```bash
bash scripts/tools/aegisub_install.sh --dry-run
bash scripts/tools/aegisub_install.sh
bash scripts/tools/aegisub_status.sh
bash scripts/tools/aegisub_doctor.sh
```

Standard ist eine gepinnte Quellinstallation, noch kein benutzbarer Editor.
Kein Docker, kein Paketmanager, keine Modelle und kein automatischer
GUI-/Audio-/Dienststart. Der gesamte Checkout kommt aus GitHub; seine
Wrap-Dateien sind Buildrezepte, werden aber nicht automatisch ausgefuehrt.
Der Quell-Pin ist keine Signaturpruefung oder Sicherheitsgarantie.

## Optional: nativen Editor privat bauen

```bash
AEGISUB_BUILD=1 AEGISUB_BUILD_JOBS=1 bash scripts/tools/aegisub_install.sh
```

Der Build nutzt Meson/Ninja mit einem Job (maximal zwei), Release-Modus,
`--wrap-mode=nofallback` und vorhandene Systembibliotheken. Fehlende
Abhaengigkeiten fuehren zum Abbruch statt zu unangekuendigten Downloads.
Upstream-Buildskripte und Compiler-Probetests werden ausgefuehrt; es ist
keine Netzwerksandbox. Aegisub selbst wird nicht gestartet.

Voraussetzungen fuer Quellen: normaler Linux-Benutzer, Bash, Git,
Python 3.10+, flock, realpath und uebliche GNU-Werkzeuge.
Fuer den Build ausserdem:

- Meson >=0.60, Ninja, C-/C++20-Compiler, pkg-config, wx-config und gettext/msgfmt.
- wxWidgets >=3.2.2 mit STC-/OpenGL-Komponenten, Boost >=1.70 (chrono/locale; bei aelteren Versionen regex), zlib und ICU.
- fontconfig, libass, OpenGL, FFMS2 >=2.22, ALSA und LuaJIT >=2.0.
- System-LuaJIT muss laut Upstream den Lua-5.2-Kompatibilitaetstest bestehen; der Installer baut kein Ersatz-LuaJIT.

Typische Ubuntu-Entwicklungspakete: `build-essential`, `meson`,
`ninja-build`, `pkg-config`, `gettext`, `libwxgtk3.2-dev`,
`libwxgtk-gl3.2-dev`, `libboost-chrono-dev`, `libboost-locale-dev`,
`libboost-regex-dev`, `libfontconfig1-dev`, `libass-dev`, `zlib1g-dev`,
`libicu-dev`, `libluajit-5.1-dev`, `libgl1-mesa-dev`, `libffms2-dev`,
`libasound2-dev`. Diese Liste ist eine Orientierung, keine automatische
Systeminstallation oder Garantie fuer einen kompatiblen LuaJIT-Build.
Die endgueltigen Header-/Versions-/Linkpruefungen macht Meson.

Dieser begrenzte Build aktiviert FFMS2 und ALSA. PulseAudio, PortAudio,
OpenAL, Hunspell, uchardet, FFTW, libportal, CSRI, Tests und der
Online-Update-Checker sind deaktiviert. WSL-Audio via ALSA funktioniert
damit nicht automatisch; keine Audio-/WSLg-Konfiguration wird veraendert.
Fuer volle optionale Features ist ein separat gepruefter Build erforderlich.

Die Installation erfolgt ohne sudo unter
`${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/aegisub/native/`.
Meson installiert Binary, Uebersetzungen und Automation-Ressourcen dort,
nicht nach `/usr` oder `/usr/local`. Kein globaler PATH-/Desktop-/Autostart-
Eintrag. Ein geerbtes DESTDIR wird fuer diesen Schritt entfernt.
Nutzerprofile, Schriften, Dateien und eigene Lua-Skripte bleiben unberuehrt.
Lua-Automation ist ausfuehrbarer Code: keine ungeprueften fremden Skripte laden.

## Start und Windows

Nach erfolgreichem Build, ausschliesslich manuell:

```bash
ROOT="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
"$ROOT/tools/aegisub/native/bin/aegisub"
```

Unter WSL2 ist fuer das Fenster funktionierendes WSLg bzw. ein bewusst
konfigurierter Display-Server erforderlich. Ohne Desktop ist der Build
keine nutzbare GUI-Anwendung. Der Installer prueft keinen Display-Server.
Fuer natives Windows stehen die offiziellen
[GitHub-Releases](https://github.com/TypesettingTools/Aegisub/releases/tag/v3.5.1)
zur manuellen Installation zur Verfuegung; dieser Linux-Helper fuehrt
keinen Windows-Installer aus. macOS ebenso separat upstream behandeln.

## Ressourcen und Zielhosts

| Modus/Host | Reserve bzw. Einschraenkung, kein Benchmark |
|---|---|
| Nur Quellen | 1 GiB freie Ziel-Disk; bei messbarem WSL-Host 2 GiB Windows-C: |
| Build | 4 GiB Gesamt-RAM, 2 GiB aktuell verfuegbar; 8 GiB freie Ziel-Disk und Windows-C: |
| MiniPC/WSL2/Intel/AMD | Linux x86_64, standardmaessig ein Build-Job; GUI/Audio separat testen |
| Raspberry Pi | ARM64-Quell-/Buildpfad vorgesehen, Abhaengigkeiten/Grafik ungetestet; kein ARM32-Automatismus |
| Oracle VPS/Kubernetes | Quellen/Buildvorbereitung, ohne Desktop kein sinnvoller interaktiver Editor |
| GPU-Workstation | Kein CUDA oder KI-VRAM-Budget; OpenGL-/GUI-Unterstuetzung erforderlich |

Speicherreserven sind Installer-Policy, keine Upstream-Laufzeitmessung.
Grosse Video-/Audiodateien brauchen zusaetzlichen Platz und RAM.

## Lifecycle und Grenzen

```bash
bash scripts/tools/aegisub_update.sh
AEGISUB_BUILD=1 bash scripts/tools/aegisub_update.sh
bash scripts/tools/aegisub_install.sh --repair
bash scripts/tools/aegisub_uninstall.sh
```

Update/Repair verwendet denselben Pin, kein bewegliches latest/master.
Vorhandene unveraenderte Quellen werden wiederverwendet. Quellstatus wird
nach dem Build erneut geprueft. Der flache Git-Checkout kann im About-Dialog
einen Hash statt des Release-Tags zeigen; der Source-Pin bleibt massgeblich.

`source_ready` prueft Repo/Origin/Commit und unveraenderte Quellen.
`native_built` prueft die registrierte ELF64-Datei, Hostarchitektur,
SHA-256 und die Existenz einer Automation-Ressource; keine vollstaendige
Integritaetspruefung aller installierten Dateien oder Laufzeitbibliotheken.
`gui_tested` bleibt `false`. Doctor kann fuer konsistente Quellen Erfolg
melden, auch ohne Build. Das Menue behauptet keinen getesteten GUI-Betrieb.

Dateien unter `tools/aegisub/`: `source/`, `build/`, `native/`, Marker und
Sperrdatei. Logs im privaten User-Workspace unter `install_logs/`, Diskmessung
vor/nach Installation. Fremde/geaenderte Quellordner, fremde Build-/Prefix-
Ordner, Symlinks und Repo-interne User-Daten werden nicht ueberschrieben.
Owned-Marker erlauben erneute Konfiguration ohne `--wipe` oder Datenloeschung.

Deinstallation deaktiviert nur Quell-/Buildregistrierung und bewahrt
Quellen, Binary, private Installation und Daten. Sie entfernt die Anwendung
nicht physisch. Nach einem Fehler Log lesen und erst danach --repair nutzen.

Hauptlizenz BSD-3-Clause; Komponenten haben eigene Lizenzen gemaess
[LICENCE](https://github.com/TypesettingTools/Aegisub/blob/v3.5.1/LICENCE).
Rechte an Videos, Musik und Untertiteln separat beachten. Tests verwenden
nur synthetische Dateien und Mock-Builds; keine WSL oder Medien verarbeitet.
