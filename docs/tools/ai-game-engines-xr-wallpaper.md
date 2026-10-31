# KI-Animationen, Game-Engines, VR/AR und Live-Wallpaper

Stand: 28.10.2026. **Installations- und Hardwareabnahme: ungeprueft.**

## Zweck und Einstieg

Mit einer Game-Engine werden KI-erzeugte Assets und Animationen zu interaktiven Szenen, Spielen oder
Simulationen. Ein lokales Modell kann bei Skripten und NPC-Dialogen helfen; es ersetzt weder Rigging
noch Animation, Retargeting, Spielmechanik oder Tests auf dem Zielgeraet. Fuer dieses Setup ist
Godot ein ueberschaubarer Einstieg. O3DE ist eine schwerere Alternative; Unity und Unreal sind
gesondert lizenzierte Engines, nicht frei installierbare GitHub-Pakete.

Empfohlener Ablauf (Architekturvorschlag, keine fertige Agentenanbindung):

```text
ComfyUI / eigene lizenzierte Assets -> Blender: Rigging und Animation
                                  -> glTF/GLB -> Godot: AnimationTree / Logik
Ollama / Coding-Agent -> gepruefte Skriptvorschlaege -> eigenes Testprojekt
                                  -> Desktop / Web / XR / Mobile-Export
                                  -> optional Windows-Wallpaper ueber Lively
```

Unity nutzt Animator/Animation Rigging, Unreal Animation Blueprints und Control Rig. Importformate
und Skelettkonventionen muessen pro Engine geprueft werden. Ein generiertes Video ist noch keine
riggbare 3D-Animation. Unitys [ML-Agents](https://github.com/Unity-Technologies/ml-agents) ist ein
separater Trainings-/Simulationsbaukasten, kein automatischer Text-zu-Animation-Editor; hier nur
Referenz, kein neuer Installer und kein Trainingsstart.

## Neue Auswahl im Tools-Menue

Alle Eintraege sind optional, aus GitHub, ohne Docker und nach der bestehenden Trennlinie
alphabetisch einsortiert. Quellpakete sind **keine fertigen Apps**.

| Menueeintrag              | Tatsaechlicher Umfang                                       | Reserve vor Download                |
| ------------------------- | ----------------------------------------------------------- | ----------------------------------- |
| `Godot_Source`            | Godot 4.7.2: nur gepinnte Quellen                           | 2 GiB Disk                          |
| `Godot_Build`             | Separater Linux-Editor-Source-Build, GDScript ohne .NET     | 16 GiB Disk, 6 GiB verfuegbarer RAM |
| `Godot_XR_Tools`          | XR Tools 4.5.2: Quellen inklusive Addon, kein Projektimport | 2 GiB Disk                          |
| `O3DE_Source`             | O3DE 26.05: Quellcheckout, ohne LFS-Payloads oder Build     | 4 GiB Disk                          |
| `Lively_Wallpaper_Source` | Windows-Projektquellen fuer Studien/Weiterentwicklung       | 2 GiB Disk                          |

Diese Reserven sind konservative Vorpruefungen, keine gemessenen Endgroessen. Unter WSL wird auch
freier Windows-C:-Speicher geprueft. Der Godot-Build bleibt schwergewichtig: derzeit wenig freier
C:-Speicher ist ein legitimer Abbruchgrund. Die Konfiguration mit Pins steht in
[gap_tools.json](../../scripts/tools/helpers/gap_tools.json), die Registrierung in
[tools.yml](../../config/tools.yml).

Nur den Plan ansehen (kein Download, Build oder Schreiben im User-Workspace):

```bash
bash scripts/tools/godot_source_install.sh --dry-run
bash scripts/tools/godot_build_install.sh --dry-run
bash scripts/tools/godot_xr_tools_install.sh --dry-run
bash scripts/tools/o3de_source_install.sh --dry-run
bash scripts/tools/lively_wallpaper_source_install.sh --dry-run
```

Erst nach bewusster Auswahl auf Ubuntu/Linux:

```bash
bash scripts/tools/godot_source_install.sh
INSTALL_HEAVY_TOOLS=1 GODOT_BUILD_JOBS=1 bash scripts/tools/godot_build_install.sh
bash scripts/tools/godot_build_doctor.sh
```

Der Buildweg unterstuetzt Linux x86_64/aarch64, nicht natives Windows/macOS. Vorhandenes
SCons >=4.4, Python >=3.9, C++-Compiler und pkg-config sowie die
Grafik-/Audio-Entwicklungsbibliotheken muessen separat bereitstehen. Es gibt keinen automatischen
apt-/pip-, Treiber- oder SDK-Umbau. Hoestens zwei Buildjobs, vier Stunden Zeitlimit und begrenzte,
laufende Logausgabe; geprueft wird nur `--headless --version`, kein Editorfenster oder Projekt.
Siehe
[offizieller Linux-Buildweg](https://docs.godotengine.org/en/stable/engine_details/development/compiling/compiling_for_linuxbsd.html).

Godot-Buildziel: `~/.openclaw_ultimate_user_data/tools/godot_build/runtime/bin/`. Die anderen
Eintraege nutzen ihren eigenen `tools/<id>/runtime/`-Ordner. Ein Update prueft denselben Pin, nicht
einen beweglichen `main`-Branch. Ein fehlgeschlagener Versuch bekommt keinen Erfolgsmarker.
Deinstallation entfernt nur inventarisierte unveraenderte Tool-Dateien; Projekte ausserhalb, Logs
und Basiswerkzeuge bleiben. Bei veraenderten Dateien wird abgebrochen.

Godot-Export-Templates fuer weitere Plattformen werden nicht mitgebaut. XR Tools wird ebenfalls
nicht in fremde Projekte kopiert: Nach Sicherung nur den passenden Ordner `addons/godot-xr-tools` in
ein eigenes Projekt uebernehmen und die Versionskompatibilitaet pruefen. XR Tools 4.5.x nennt
Godot >=4.4; die Kombination mit unserem Pin ist noch nicht praktisch getestet.
[Addon-Anleitung](https://godotvr.github.io/godot-xr-tools/docs/installation/),
[Versionsmatrix](https://github.com/GodotVR/godot-xr-tools/tree/4.5.2).

O3DE verwendet Git LFS. Der Quellmodus laesst absichtlich LFS-Zeiger stehen und laedt keine grossen
Binaerdaten, Drittanbieter-SDKs oder Gems. Deshalb ist er **kein vollstaendiger baubarer
O3DE-Bestand**. Vollbuild und Betrieb bleiben offen.
[O3DE-Quellen](https://github.com/o3de/o3de/tree/2605.0).

## Engines, Plattformen und Lizenzen

| Engine | Windows / Linux / macOS                   | Android / iPhone                   | Browser                                                                            | Zugang                                                                  |
| ------ | ----------------------------------------- | ---------------------------------- | ---------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Godot  | Native Exportziele                        | Android und iOS mit passenden SDKs | WebAssembly + WebGL 2.0, Compatibility-Renderer                                    | MIT; GitHub-Quellbuild moeglich                                         |
| O3DE   | Windows/Linux; macOS experimentell        | Android; iOS experimentell         | Hier kein verifizierter Standard-Webexport                                         | Apache-2.0/MIT und Drittkomponenten getrennt                            |
| Unity  | Zielplattform und Editor-Version beachten | Android/iOS mit Buildmodulen       | Webexport, Browsergrenzen beachten                                                 | Unity-Lizenz; Editor nicht aus oeffentlichem GitHub vollstaendig baubar |
| Unreal | Native Desktop-Ziele, passende Toolchains | Android/iOS mit SDKs               | Kein hier verifizierter Standard-HTML5-Export; Pixel Streaming ist Serverstreaming | Epic-EULA, GitHub-Zugriff nach Kontoverknuepfung                        |

Keine Engine liefert mit einem unveraenderten Projekt automatisch gleichwertige Desktop-, Mobil-,
Browser- und VR-Versionen. Eingabe, Renderer, UI, Assets und Leistungsbudget muessen angepasst
werden. iOS-Export mit Godot benoetigt einen Mac mit Xcode; Signierung und Store-Veroeffentlichung
sind separate Schritte.
[Godot iOS (offizielle Repository-Quelle)](https://github.com/godotengine/godot-docs/blob/6d86d7c7f3b8f4f56c71e113022d72fe80b2c84d/tutorials/export/exporting_for_ios.rst);
`https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html` (Originaladresse,
CI HTTP 429 am 31.10.2026),
[O3DE-Plattformstatus](https://www.docs.o3de.org/docs/welcome-guide/supported-platforms/),
[Unity-Webbrowser](https://docs.unity.com/en-us/engine/6000.5/manual/platform-specific/webgl/intro/browsercompatibility),
[Unreal-GitHub-Zugang](https://dev.epicgames.com/documentation/en-us/unreal-engine/downloading-source-code-in-unreal-engine).

Bei Godot 4 ist Webexport derzeit nicht fuer C#-Projekte verfuegbar; fuer einen gemeinsamen
Web-/Desktop-Einstieg GDScript bevorzugen. Nicht pauschal WebGPU versprechen: dokumentiert ist WebGL
2.0. Mehrthread-Webexport braucht besondere Cross-Origin-Isolation; Mikrofon/WebXR brauchen
geeignete Browser und sichere Kontexte. Ein Webspiel kann keine beliebigen lokalen Dateien oder
USB-Geraete wie eine Desktop-App ansprechen.
[Godot-Webexport (offizielle Repository-Quelle)](https://github.com/godotengine/godot-docs/blob/6d86d7c7f3b8f4f56c71e113022d72fe80b2c84d/tutorials/export/exporting_for_web.rst);
`https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html` (Originaladresse,
CI HTTP 429 am 31.10.2026).

## Stereoskopie, Valve Index, VR und AR

Stereoskopie bedeutet getrennte Ansichten fuer beide Augen. VR ergaenzt Tracking, Controller und
niedrige Latenzen; AR zusaetzlich Kamera-/Umgebungsfunktionen. Ein Side-by-Side-Video ist daher noch
keine interaktive VR-Anwendung.

Godot hat OpenXR im Kern. Fuer Valve Index ist eine passende aktive OpenXR-Runtime, etwa SteamVR auf
dem nativen Host, samt Treibern und Controller-Bindings erforderlich. XROrigin3D, XRCamera3D und
Eingabeaktionen muessen im Projekt eingerichtet werden; Initialisierung kann fehlschlagen. XR Tools
liefert Hilfsszenen, nicht die SteamVR-Installation. Die pauschale Aussage, ein beliebiges Spiel
werde per Knopfdruck VR, ist nicht zutreffend.
[Godot-XR-Einrichtung](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html).

Unity bietet XR-Pakete, Unreal OpenXR-Plugins und O3DE einen OpenXR-Gem-Weg.
Geraete-/Rendering-Kompatibilitaet ist pro Engine, Runtime und Version zu pruefen; insbesondere
keine zugesicherte Valve-Index-Abnahme fuer O3DE.
[Unity XR](https://docs.unity3d.com/Manual/xr-support-packages.html),
[O3DE OpenXR](https://github.com/o3de/o3de-extras/wiki/Build-and-Run-OpenXR-in-O3DE).

Smartphone-AR ueber ARCore/ARKit ist nicht automatisch durch OpenXR vorhanden. Plugins, native SDKs,
Kameraberechtigungen und reale Zielgeraete sind gesondert zu pruefen. Desktop-OpenXR, mobiles AR und
WebXR nicht gleichsetzen. Fuer deine RTX-Workstation VR zuerst nativ unter Windows/Linux testen; WSL
ist ein Build-/Backend-Weg, keine zugesicherte VR-Headset-Laufzeit. Auf kleinen VPS nur
Verwaltung/Buildplanung, keine Echtzeit-VR versprechen.

## Wallpaper und Bildschirmschoner

[Lively Wallpaper](https://github.com/lively-community/lively) kann unter Windows Webseiten, Videos
und geeignete Godot-/Unity-Anwendungen als Hintergrund nutzen und bietet eine
Bildschirmschonerfunktion. Das neue Quellpaket installiert aber **keine Windows-App**, registriert
keinen Autostart und aendert keinen Desktop. Lively ist GPL-3.0; Wallpaper Engine ist dagegen keine
hier angebotene Open-Source-GitHub-Alternative. Anwendungseinbettung bleibt projektspezifisch. Der
bisherige GitHub-Link `rocksdanister/lively` leitet zum hier verwendeten Repository
`lively-community/lively` um; auch dort bleibt der konkrete Commit fest.
[Lively-Quellstand](https://github.com/lively-community/lively/tree/25a0a5f4ed1988ff42117d3a17feb321062237fe),
[Anwendungseinbettung](https://github.com/lively-community/lively/wiki/Application-Wallpaper).

Eine `.exe` nur in `.scr` umzubenennen genuegt nicht. Ein eigener Windows- Bildschirmschoner muss
Start-/Vorschau-/Konfigurationsmodi, Fensterintegration und Beenden bei Eingabe korrekt behandeln,
etwa `/s`, `/p` und `/c`. Die Sitzungssperre bleibt eine Betriebssystemfunktion, kein
Sicherheitsmerkmal deines Spiels.
[Microsoft-Anleitung](https://learn.microsoft.com/en-us/windows/win32/lwef/screen-saver-library).

Unter Linux sind X11-/Wayland-Compositor und Desktop entscheidend; Lively ist kein
Linux-Wallpaper-Host. macOS, Android und iOS haben eigene Integrations- und Sandboxregeln. Ein
normaler Spieleexport wird auf keinem dieser Systeme automatisch zum Live-Wallpaper. Fuer einen
einfachen Einstieg Animation als Video rendern und einen passenden Wallpaper-Host separat
auswaehlen.

Auch kleine 3D-Hintergruende koennen erheblich GPU/VRAM und Energie verbrauchen. FPS begrenzen, bei
Vollbild/VR pausieren und mit Ollama/ComfyUI um VRAM konkurrierende Szenen vermeiden. Keine
Kameras/Mikrofone oder Modellaufrufe im Wallpaper-Default.

## Abnahme und sichere KI-Anbindung

1. Plan und Speicher pruefen, dann nur die gewuenschte Quelle oder den Build auswaehlen.
2. Versionspruefung und wiederholte Installation protokollieren; kein ungeprueftes `tested`
   vergeben.
3. Ein eigenes leeres Projekt ohne Plugins als Desktop-Spiel testen.
4. Einfache GLB-Animation importieren; erst danach Web, XR oder Wallpaper einzeln testen.
5. Projekt sichern, vor Agentenaenderungen Diff pruefen und Exportziele getrennt abnehmen.

Browser-/Mobile-Clients bekommen keine Ollama-/OpenClaw-Adminports oder API-Keys. NPC-Anfragen bei
Bedarf ueber ein authentifiziertes Backend mit Kosten-/Token- und Parallelitaetslimits; nichts davon
wird durch diese Installer eingerichtet. Fremde Addons und Buildskripte sind ausfuehrbarer Code,
keine Sandbox. Assets, Stimmen, Motion-Capture und KI-Modelle behalten ihre eigenen Lizenzen.

Bestehendes GameDev-Profil: `GameDev_3D_Studio_NEXTLEVEL`. Sein aelterer Installer ist kein Alias
fuer diese neuen gepinnten Werkzeuge und wurde nicht umgebaut. Die vorhandenen ungepinnten
Clone-/Buildoptionen sind dadurch nicht abgenommen. Weitere Einstiege:
[Tools-Katalog](../TOOLS_CATALOG.md) und [Teststatus](../TESTED_STATUS_MATRIX.md).
