# FILM aus GitHub, ohne Docker

## Was dieser Menuepunkt installiert

FILM steht fuer Frame Interpolation for Large Motion. Es erzeugt Zwischenbilder zwischen vorhandenen
Bildern, aber keine neuen Handlungen, keine verlaessliche Szenenrekonstruktion und keinen
garantierten Deflicker. Originale behalten: bei Verdeckungen, Schnitten oder grossen Bewegungen sind
Artefakte moeglich. Interpolation ersetzt weder SUPIR noch Wan-Generierung.

Das Setup verwendet jetzt einen eigenen **experimentellen GitHub-Quellinstaller** statt des
gemeinsamen Hybrid-Platzhalters. Quelle:
[google-research/frame-interpolation](https://github.com/google-research/frame-interpolation),
fester Commit `69f8708f08e62c2edf46a27616a4bfcf083e2076`. Code: Apache-2.0, Modell-/Datenbedingungen
separat pruefen. Der offizielle Upstream ist seit 14.10.2025 archiviert und schreibgeschuetzt.

**Die Quellinstallation ist noch keine lauffertige Interpolation.**
`source-ready`/`source_ready: true` bestaetigt nur gepinnte, unveraenderte Quellen mit
Syntaxpruefung. Status meldet bewusst `runtime_ready: false`. Keine
TensorFlow-/CUDA-/Conda-Installation, kein Modell-Download, keine Bildverarbeitung und kein Docker
werden automatisch ausgefuehrt.

## Warum nicht einfach die Requirements installieren?

Die
[gepinnten Requirements](https://github.com/google-research/frame-interpolation/blob/69f8708f08e62c2edf46a27616a4bfcf083e2076/requirements.txt)
nennen unter anderem TensorFlow 2.6.2, TensorFlow Addons 0.15.0 und Apache Beam 2.34.0. Die alte
[Upstream-Anleitung](https://github.com/google-research/frame-interpolation/blob/69f8708f08e62c2edf46a27616a4bfcf083e2076/README.md#installation)
beschreibt einen Nicht-Docker-Pfad mit Python 3.9, CUDA 11.2.1 und cuDNN 8.1.0. Das ist kein
geprueftes Ubuntu-24.04-/Python-3.12- oder RTX-5080-Rezept.

Das Setup kompiliert deshalb kein altes Python und ersetzt weder System- TensorFlow noch
GPU-Treiber. Ein erzwungenes Paketinstallieren mit `--no-deps` oder ein blindes Upgrade auf
aktuelles TensorFlow beweist keine SavedModel- und Code-Kompatibilitaet. Vor einer Runtime-Freigabe
sind isolierter Dependency-Lock, Sicherheitspruefung und echter Interpolationstest erforderlich.

`FILM_INSTALL_RUNTIME=1` wird mit klarer Begruendung abgewiesen, auch zusammen mit
`INSTALL_HEAVY_TOOLS=1`. Ohne diese Variable funktioniert die untenstehende
GitHub-Quellinstallation. Der Docker-Hinweis in der originalen Requirements- Datei ist nur
Upstream-Kommentar, kein vom Setup ausgefuehrter Docker-Befehl.

## 1. Quellen installieren

Erforderlich: Linux, normaler Benutzer, Bash, Git, flock, realpath/coreutils und Python 3.10+ fuer
die **reine Syntaxpruefung**. Python 3.12 ist dafuer geeignet, ohne eine alte TensorFlow-Laufzeit zu
installieren. Fehlende Basiswerkzeuge bewusst separat einrichten, ohne sudo im Toolaufruf.

Konservative Setup-Reserve: **1 GiB freie Ziel-Disk**, unter WSL zusaetzlich **2 GiB freie
Windows-C:-Reserve**. Dies ist keine RAM-/VRAM-Mindestangabe fuer Rendering. Modellgroesse,
Bildaufloesung, Patches und Zahl der Frames bestimmen den spaeteren Bedarf; der konkrete
Runtime-Pfad ist hier ungetestet. MiniPC, RPi und Oracle-VPS koennen die Quellen vorbereiten.
GPU-Workstation, ARM, Windows und K3s sind damit nicht als getestete Interpolationsziele
freigegeben.

```bash
# Im aktuellen Ultimate-Setup-Checkout, ohne sudo:
bash scripts/tools/film_install.sh --dry-run
bash scripts/tools/film_install.sh
bash scripts/tools/film_status.sh
bash scripts/tools/film_doctor.sh
```

Alternativ im Tools-Menue **FILM** auswaehlen. Installationsziel:
`~/.openclaw_ultimate_user_data/tools/film/source/`. Git-Prompt ist deaktiviert; das oeffentliche
Repository braucht keine Zugangsdaten. Pin, Ursprung, lokale Aenderungen und ausgewaehlte Python-
Einstiegsdateien werden geprueft, ohne diese auszufuehren oder zu importieren. Insbesondere keine
TensorFlow-/SavedModel-Imports oder Modell-API-Aufrufe.

Protokolle: `~/.openclaw_ultimate_user_data/install_logs/film_*.log`. `OPENCLAW_USER_DATA_DIR`
erlaubt einen anderen absoluten, normalisierten User-Workspace ausserhalb von Git.
Symlink-Umleitungen werden abgelehnt.

## 2. Gewichte und sichere spaetere Tests

Die TensorFlow-SavedModels werden **nicht mit dem GitHub-Code installiert**. Modelle nur bewusst aus
den offiziellen Upstream-Verweisen beziehen, mit Revision-/Hash-, Lizenz- und Speicherpruefung.
Keine gdown-/Cloud-/Token-Aktion durch diesen Installer. Modelldateien sind fremde
Daten/Codeartefakte; nur in einer begrenzten Umgebung laden, nicht in einem privilegierten Prozess.

**Achtung Ausgabeordner:** Die originale
[CLI](https://github.com/google-research/frame-interpolation/blob/69f8708f08e62c2edf46a27616a4bfcf083e2076/eval/interpolator_cli.py)
kann bestehende `frame_*.png` im Unterordner `interpolated_frames` vor einem neuen Lauf entfernen.
Niemals das einzige Originalmaterial oder einen bereits benutzten Renderordner als unbeaufsichtigtes
Jobziel verwenden. Pro Test einen neuen privaten Jobordner anlegen und nur Kopien freigegebener
Eingaben nutzen. Der Setup-Installer startet diese CLI auch nicht probeweise mit `--help`.

Rekursive Interpolation kann die Framezahl stark vergroessern. Fuer **ein Paar** Eingabebilder
ergeben `n` rekursive Mittelpunktschritte `2^n + 1` Frames inklusive der beiden Endbilder. Das ist
kein garantiertes Ergebnis fuer beliebige Mehrbildfolgen; deren tatsaechliche Ausgabelogik gesondert
pruefen. Neue Frames brauchen Speicher und koennen Audio-/Zeitachsenanpassungen erfordern. Mit
kleinen Bildkopien und wenigen Schritten anfangen, nicht mit 8K oder einer langen Filmdatei.
Patch-Unterteilung ist kein pauschales Qualitaets-/VRAM-Versprechen.

OpenClaw/n8n koennen spaeter einen freigegebenen seriellen Worker ansprechen: validierte
Eingabe-/Ausgabepfade, feste Frame-/Aufloesungsgrenzen, Timeout, Disk-Budget und ein Job
gleichzeitig. Keine Shellstrings aus Medienmetadaten, keine oeffentliche API und kein autonomer
Endlos-Renderlauf. Ein solcher Runtime-/ComfyUI-/Queue-Adapter ist hier **nicht implementiert**.

## Update, Fehler und Deaktivierung

```bash
bash scripts/tools/film_update.sh
bash scripts/tools/film_install.sh --repair
bash scripts/tools/film_uninstall.sh
```

Update und Repair pruefen denselben Pin, kein stilles `pull main` und kein automatischer Wechsel auf
einen fremden Fork. Wiederholte Installation verwendet einen konsistenten Checkout erneut. Bei
fremden, veraenderten oder unvollstaendigen Quellordnern erst manuell sichern/umbenennen; kein
Reset, Ueberschreiben oder rekursives Loeschen. Ein Operations-Lock verhindert parallele Aktionen;
Fehler erzeugen keinen neuen Erfolgsmarker.

Doctor und Status sind offline und legen keinen Workspace an. Ein erfolgreicher Doctor bestaetigt
**keinen** TensorFlow-/GPU-/Modelltest. Uninstall deaktiviert nur die Setup-Markierung; Quellcode,
eigene Umgebungen, Modelle, Bilder, Videos und Logs bleiben erhalten. Keine Prozesse oder Dienste
werden beendet.

Hier wurden nur synthetische Offline-Dateien und Mocks getestet. Echte TensorFlow-Installation,
SavedModel-Inferenz, FFmpeg-Export und GPU-/Windows- Kompatibilitaet bleiben offen. Deine vorhandene
WSL wurde nicht veraendert.
