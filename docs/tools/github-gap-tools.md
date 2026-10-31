# GitHub-Ergaenzungen: Qwen Desktop, Hermes/Jarvis und Medienquellen

Neue GameDev-Auswahl:
[Godot, XR Tools, O3DE, Lively sowie Unity-/Unreal-Einordnung](ai-game-engines-xr-wallpaper.md).
Godot hat einen separaten optionalen Linux-Source-Build; die anderen neuen Quellpakete starten keine
fertige App, kein Headset und keinen Wallpaper-Host.

Neu: [Qwen_Desktop_Study fuer Studienzwecke und Weiterentwicklung](qwen-desktop-study.md):
GitHub-Quellen als Standard, optionaler separater Linux-/Windows-Build wie bei Enki.

Die neuen Eintraege stehen im **Tools-Menue alphabetisch unterhalb der Trennlinie**. Die bisherige
Trennlinie nach Ruflo bleibt erhalten. Bereits vorhandene Medien-Eintraege werden dort nicht doppelt
angezeigt. Alle Wege sind optional und **ohne Docker**. Fuer Qwen Desktop Build gibt es ausserdem im
Tools-Menue unter **Ubuntu / Windows** die ausdrueckliche Zielauswahl. Windows-Builds starten in
nativem Windows-Python/PowerShell und aendern nicht den Linux-Status. Die benoetigte
MSVC-Developer-Umgebung muss dort bereits verfuegbar sein; andernfalls den unten beschriebenen
Developer-PowerShell-Weg nutzen.

## Qwen Code Desktop: Download oder eigener Build

**Qwen_Desktop** bleibt der bisherige manuelle Windows-Download mit Browser und Bestaetigungspause:
[Windows-Anleitung](qwen-desktop-windows.md). **Qwen_Desktop_Build** ist dagegen ein nativer Build
aus [QwenLM/qwen-code](https://github.com/QwenLM/qwen-code), Pin
`bf66a26c978dac68af31fbc093eb53044e204b24`.

Die
[offizielle Desktop-Anleitung](https://github.com/QwenLM/qwen-code/blob/bf66a26c978dac68af31fbc093eb53044e204b24/packages/desktop/README.md)
beschreibt eine **Tauri-2-Anwendung**, nicht einen zweiten unabhaengigen Qwen-Client. Sie buendelt
Node, CLI und Web Shell. Der Installer folgt dem
[offiziellen Buildworkflow](https://github.com/QwenLM/qwen-code/blob/bf66a26c978dac68af31fbc093eb53044e204b24/.github/workflows/desktop-release.yml):
frozen pnpm-Installation, Desktop npm ci, build:runtime und Tauri-Build. Es wird ein **lokales
unsigniertes Paket** gebaut: Linux-AppImage oder Windows-NSIS-Installer, ohne Updater-Signatur.
Keine fremden Signierschluessel und kein Windows-Setup werden automatisch verwendet beziehungsweise
gestartet.

Voraussetzungen: Git, **Node 22**, npm, Corepack (pnpm-Version aus package.json), Rust/Cargo und
tar. Ubuntu braucht die Tauri-/GTK-/WebKit-Entwicklungsbibliotheken, insbesondere
`libwebkit2gtk-4.1-dev`, GTK3 und `librsvg2-dev` samt pkg-config. Windows braucht die
Visual-Studio-C++-Buildtools, Rust-MSVC und WebView2 zur spaeteren Nutzung. In einer **Developer
PowerShell** starten, damit `cl` im PATH liegt. Basiswerkzeuge werden nicht still systemweit
nachinstalliert. Planungsreserve: **20 GiB freier Zielspeicher** und unter WSL auch auf C:; unter
Linux mindestens **6 GiB verfuegbarer RAM**, besser mehr. Der Build kann lange dauern. Eine Reserve
garantiert nicht, dass jeder Build hineinpasst.

### Abbruch bei 12,9 GiB auf C: trotz 953 GiB unter WSL

Der Build verlangt **20 GiB = 20.480 MiB** sowohl am Ziel als auch beim geprueften
Windows-Host-Pfad. Bei **13.251 MiB** auf C: fehlen mindestens **7.229 MiB**, also rund **7,1 GiB**.
Die freie Kapazitaet im Linux-Dateisystem ersetzt diese Host-Reserve nicht. Reserve nicht
herabsetzen, um den Build auf einer fast vollen Windows-Platte zu erzwingen.

Wenn die Menue-Vorpruefung gleichzeitig nur **4 GiB / 4096 MB** nennt, laeuft vermutlich noch ein
aelterer Setup-Prozess oder eine andere Kopie. Im aktuellen setup_ultimate.sh ist der
Qwen-Desktop-Fallback bereits 20.480 MiB. **Setup vollstaendig beenden und aus dem aktualisierten
Projektverzeichnis neu starten**; ein Dateiaustausch laedt bereits im laufenden Bash-Prozess
definierte Funktionen nicht automatisch neu. Das aktuelle Operationslog nennt nun auch
Installerdatei und Manifestpfad.

Unterhalb der Reserve wird **vor Download und Build** abgebrochen. Es gibt dann keine neuen
Qwen-Programmdateien zurueckzurollen; das aktuelle Log und ein gegebenenfalls angelegter
Verwaltungsordner bleiben erhalten. Bestehende Installationen werden nicht deinstalliert. Erst
Speicher bewusst freigeben oder einen passend dimensionierten Installations-/WSL-Speicherweg
einrichten; keine automatische Datenloeschung oder WSL-Verschiebung.

### Build starten

Linux/Ubuntu/WSL (baut eine **Linux-Anwendung**, Anzeige spaeter z. B. ueber WSLg):

```bash
bash scripts/tools/qwen_desktop_build_install.sh --dry-run
bash scripts/tools/qwen_desktop_build_install.sh
bash scripts/tools/qwen_desktop_build_status.sh
```

Natives Windows, im Repository-Verzeichnis, vorhandenes Python >=3.10:

```powershell
.\scripts\windows\qwen_desktop_build.ps1 -Action plan
.\scripts\windows\qwen_desktop_build.ps1 -Action install
.\scripts\windows\qwen_desktop_build.ps1 -Action status
```

Ziel unter dem jeweiligen Benutzerprofil:
`~/.openclaw_ultimate_user_data/tools/qwen_desktop_build/runtime/`. Paket:
`packages/desktop/src-tauri/target/release/bundle/appimage/*.AppImage` oder unter Windows
`packages/desktop/src-tauri/target/release/bundle/nsis/*.exe`. Das Paket erst nach eigener Pruefung
manuell starten/installieren. Windows kann wegen fehlender Herausgebersignatur eine Warnung zeigen;
nicht blind uebergehen. Das rohe Build-Executable neben `bundle/` ist kein eigenstaendig portables
Paket. Der gepackte CLI-/Node-Bestand liegt unter `packages/desktop/runtime/qwen-code/`. Es erfolgt
kein globaler PATH-Eintrag, kein Desktop-Shortcut und kein GUI-/Daemonstart. Erst beim bewussten
Start gelten die Upstream-Laufzeitfunktionen, einschliesslich Updatepruefungen und moeglicher
Modellverbindungen. `QWEN_DESKTOP_DISABLE_UPDATES=1` bei Bedarf auch fuer diesen separaten Start
setzen. Login und Modellwahl erfolgen dort, nicht waehrend des Builds. **Build erfolgreich ist noch
kein GUI-Funktionstest.**

## Eindeutige Jarvis-Quelle: Hermes Agent von Nous Research

**Hermes_Agent_Jarvis** installiert den Core aus
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent), Pin
`484de065a821b4245697351d08327b465ffd41ba`, mit `uv sync --frozen` in dessen privater `.venv`. Der
aktuelle Pin braucht **Python 3.14** fuer seine eigentlichen Core-Abhaengigkeiten; die aelteren
Python-Versionen im Metadatenfeld dienen laut Upstream dem Upgrade bestehender Installationen. Ein
vorhandenes `uv` ist erforderlich. Bei abweichendem Programmpfad:
`HERMES_PYTHON_BIN=/absoluter/pfad/python3.14` setzen. Fehlt Python 3.14, bietet der Installer nach
Bestaetigung eine private Laufzeit unter `runtime/.python/` an. Dazu verwendet das vorhandene `uv`
die
[Astral-python-build-standalone-Distributionen von GitHub](https://docs.astral.sh/uv/guides/install-python/),
nicht Docker und nicht ein ersetztes Ubuntu-System-Python. `--no-bin` verhindert globale
Python-Launcher; der globale PATH bleibt unveraendert. Die Pruefung erfolgt vor dem
Hermes-Quellcheckout. Ablehnung, EOF oder fehlendes Terminal ohne ausdrueckliche Freigabe fuehren zu
einem klar protokollierten Abbruch. Eine ausdruecklich gesetzte, aber unpassende `HERMES_PYTHON_BIN`
wird nicht ersetzt.

Fuer einen bewusst freigegebenen Python-Download ohne interaktive Rueckfrage:

```bash
HERMES_INSTALL_PYTHON=1 bash scripts/tools/hermes_agent_jarvis_install.sh
```

`HERMES_INSTALL_PYTHON=0` verbietet diesen Download. Das vorhandene `uv` bleibt Voraussetzung. Ein
aelteres `uv`, das `--no-bin` nicht kennt, muss separat aktualisiert werden; der Installer umgeht
diese Schutzoption nicht. Der Download waehlt die von dieser uv-Version angebotene
CPython-3.14-Patchversion, nicht einen separat festgelegten Python-Artefakt-Pin. Version und
Downloadausgabe stehen im aktuellen Operationslog. System-Python und Cloud-Extras bleiben
unberuehrt. Die private Laufzeit wird bei fehlgeschlagener Neuinstallation mit zurueckgerollt und
bei regulaerer Deinstallation zusammen mit dem unveraenderten Tool entfernt. Extern bereitgestelltes
Python und `uv` bleiben erhalten.

```bash
bash scripts/tools/hermes_agent_jarvis_install.sh --dry-run
bash scripts/tools/hermes_agent_jarvis_install.sh
bash scripts/tools/hermes_agent_jarvis_status.sh
```

Ziel: `~/.openclaw_ultimate_user_data/tools/hermes_agent_jarvis/runtime/`. Das CLI liegt dort unter
`.venv/bin/hermes` (Windows: `.venv/Scripts/hermes.exe`). Die Paketmetadaten werden geprueft, **kein
Hermes-Befehl oder Agent gestartet**. Konfiguration, Modellzugriff, OAuth, Werkzeuge, Telegram,
Scheduler und echte Anfragen sind getrennte, bewusst auszufuehrende Schritte.

**Nicht verwechseln:** Till Schaefers Jarvis-Webseite ist eine Anleitung auf Hermes-Basis, kein hier
verifiziertes eigenstaendiges Jarvis-Quellrepository. Es gibt daher keinen erfundenen
`till-schaefer/jarvis`-Installer und kein fertig gebautes Dashboard.
[Quelleneinordnung und Dashboard-Konzept](jarvis-hermes-dashboard.md),
[Hermes-Leitfaden](hermes-jarvis-weekend.md).

## Weitere Eintraege der Lueckenuebersicht

**MuseTalk ist eine Ausnahme zum nachfolgenden Quellenkatalog:** Standard ist jetzt eine getrennte
private Python-/CUDA-Paketumgebung ohne Modelle/Start.
[MuseTalk-Anleitung, Migration, 20-GiB-Reserve und Blackwell-Sperre](musetalk.md). Der bisherige
reine Quellenweg bleibt mit `--source-only` erreichbar.

Diese Eintraege besitzen jetzt eigene gepinnte **GitHub-Quellinstaller**, Status-/Check-/Doctor-,
Update- und Deinstallationsskripte. Umfang `source` bedeutet **gepinntes Hauptrepository, keine
einsatzbereite Anwendung**. Submodule und grosse Git-LFS-Inhalte werden nicht automatisch
nachgeladen. Die Benennung im Menue sagt das ausdruecklich. Keine Gewichte, keine pip-/GPU- Runtime,
kein Link in vorhandenes ComfyUI, keine Aufnahme oder Verarbeitung.

| Menueeintrag    | Offizielle GitHub-Quelle                                                                                    | Noch separat erforderlich                                                                    |
| --------------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Gradio          | [gradio-app/gradio](https://github.com/gradio-app/gradio)                                                   | Python-/Frontend-Build und App-Konfiguration                                                 |
| Streamlit       | [streamlit/streamlit](https://github.com/streamlit/streamlit)                                               | Python-/Frontend-Build und eigene App                                                        |
| WanVideoWrapper | [kijai/ComfyUI-WanVideoWrapper](https://github.com/kijai/ComfyUI-WanVideoWrapper)                           | Passendes ComfyUI, Node-Integration, Runtime/Modelle                                         |
| CogVideoX       | [THUDM/CogVideo](https://github.com/THUDM/CogVideo)                                                         | Modellgeneration, Python/Torch/GPU, Gewichte                                                 |
| LTX_Video       | [Lightricks/LTX-Video](https://github.com/Lightricks/LTX-Video)                                             | Passende Modellgeneration und Runtime/Gewichte                                               |
| Video2Dataset   | [iejMac/video2dataset](https://github.com/iejMac/video2dataset)                                             | Python-Pakete, FFmpeg, rechtmaessige Datenquellen                                            |
| MuseTalk        | [TMElyralab/MuseTalk](https://github.com/TMElyralab/MuseTalk)                                               | [Private Python-Runtime](musetalk.md); Modelle/Inferenz separat, Blackwell nicht freigegeben |
| LivePortrait    | [KwaiVGI/LivePortrait](https://github.com/KwaiVGI/LivePortrait)                                             | GPU-Umgebung/Modelle und Einwilligungen                                                      |
| SadTalker       | [OpenTalker/SadTalker](https://github.com/OpenTalker/SadTalker)                                             | Legacy-Python-/GPU-Umgebung und Modelle                                                      |
| RVC             | [RVC-Project/Voice-Conversion-WebUI](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) | Runtime, eigene/freigegebene Stimmen und Modelle                                             |
| UVR5            | [Anjok07/ultimatevocalremovergui](https://github.com/Anjok07/ultimatevocalremovergui)                       | GUI-/Audioabhaengigkeiten und Modelle                                                        |
| Audacity        | [audacity/audacity](https://github.com/audacity/audacity)                                                   | Nativer C++-/GUI-Build oder separates Release                                                |
| OBS             | [obsproject/obs-studio](https://github.com/obsproject/obs-studio)                                           | Nativer C++-/GUI-Build/Plugins oder separates Release                                        |

Alle geprueften Revisionen stehen in [`gap_tools.json`](../../scripts/tools/helpers/gap_tools.json).
Die Quellaufnahme ist keine rechtliche Freigabe: Code-, Modell- und Medienlizenzen gesondert lesen.
Quellenbeispiel mit `musetalk` (dessen neuer Runtime-Standard ist oben verlinkt):

```bash
bash scripts/tools/musetalk_install.sh --source-only --dry-run
bash scripts/tools/musetalk_install.sh --source-only
bash scripts/tools/musetalk_doctor.sh --source-only
bash scripts/tools/musetalk_uninstall.sh
```

**WebsiteFactory** und **AI_ContentMultiplier** verweisen auf die bestehenden
Workflow-Einrichtungen, nicht auf einen neuen KI-Dienst. Sie werden ebenfalls angehaengt. Ihre
Konfiguration liegt ausserhalb des Repos; bestehende Inhalte bleiben erhalten. Ihre bisherige
Deinstallation ist standardmaessig nur eine Vorschau/Abmeldung, kein Loeschen der Projekte oder
Nutzerdaten. Siehe [WebsiteFactory](websitefactory.md) und
[ContentMultiplier](ai-content-multiplier/README.md). Die **62 Werkzeugquellen** bleiben im eigenen
Untermenue erreichbar (Tools: **62 Quellen verwalten**), ohne 62 doppelte Checkboxen zu erzeugen.
API-Anbieter bleiben Konfigurationen, keine lokalen Scheininstallationen.

## Status, Logs und Entfernung

Neue GitHub-Installationen schreiben `ready.json` erst nach erfolgreichem Checkout beziehungsweise
Build und Artefaktpruefung. `--status` ist lesend; `check` prueft Pin und Hauptartefakte, `doctor`
den gesamten Dateibestand. Update und Reparatur bleiben beim gleichen Pin. Ein vorhandener fremder
oder unvollstaendiger Ordner wird nicht ueberschrieben. Fehler werden im jeweils neuen Operationslog
unter `~/.openclaw_ultimate_user_data/install_logs/` mitprotokolliert; nur neu erzeugte Dateien
dieses Versuchs werden zurueckgerollt. Bei veraenderten oder ergaenzten Dateien verweigert die
Deinstallation die Loeschung und fordert eine manuelle Sicherung. Projekte, Hermes-Gedaechtnis
ausserhalb des verwalteten Ordners, Modelle und Basiswerkzeuge bleiben erhalten. Builds koennen
Paketmanager-/Cargo-Caches ausserhalb des Tool-Ordners erzeugen; das ist keine vollstaendige
Sandbox. Buildskripte koennen Code ausfuehren und Netzwerkverbindungen aufbauen. Keine privaten
Schluessel fuer den Build eingeben.

Die Integration wird offline getestet. Vollstaendige Linux-/Windows-Builds, GUI-Funktion und
GPU-Ablaeufe muessen auf dem Zielsystem separat abgenommen werden.
