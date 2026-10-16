# Karaoke, Untertitel und getrennte Instrumentalspuren

Status: **Workflow-Entwurf**, plus getesteter lokaler Basis-LRC/SRT-Konverter.
Keine automatische Transkription, Separation, Uebersetzung oder Videoproduktion
durch den Konverter. Alle Beispiele sind synthetisch, ohne fremde Songtexte.

## 1. Die Dateien verstehen

| Format | Zeitinformation | Geeignet fuer / Grenze |
|---|---|---|
| SRT | Beginn und Ende eines Untertitelblocks | Film-Untertitel; normalerweise keine Silben-/Wortzeiten |
| WebVTT | Web-Untertitel mit weiteren Moeglichkeiten | Webplayer; Funktionsumfang playerabhaengig |
| Basis-LRC | meist Beginn einer Textzeile | synchronisierte Lyrics; keine ausdrueckliche Block-Endzeit |
| Enhanced LRC | zusaetzliche Wortmarker in einer Variante | nicht von jedem Editor/Player gleich unterstuetzt |
| ASS | Styles, Beginn/Ende und optional Karaoke-Tags | Karaoke-Gestaltung in Aegisub/libass-faehigen Playern |

Ein Beispiel fuer eine Enhanced-LRC-Variante ist
`[00:12.000]<00:12.000>Hallo <00:12.500>Welt`.
Nicht alle eckigen Klammern pro Wort erzeugen automatisch ein standardkonformes
Enhanced LRC. Normale LRC-Zeilentags und Wortmarker unterscheiden.
ASS-Karaoke verwendet u. a. Dauertags in Hundertstelsekunden; ohne gepruefte
Wort-/Silbenzeiten entstehen keine richtigen Animationen nur durch Dateiumbenennung.

## 2. Eine vernuenftige lokale Produktionskette

1. Freigegebene Musik/Video in ein Projekt aufnehmen, Original unveraendert behalten.
2. Demucs/UVR5 trennt bei passendem Modell Vocals und Begleitung. Nicht perfekt;
   das nichtvokale Demucs-Ergebnis heisst oft `no_vocals.wav`.
3. Transkription auf der Vocal-Spur mit Faster-Whisper, optional WhisperX-Alignment.
4. Text gegen bekannte erlaubte Lyrics/Hoerprobe korrigieren; Gesang, Hall,
   Instrumentalpausen und mehrere Stimmen sind schwieriger als klare Sprache.
5. Zeiten im Editor pruefen, optional Wort-/Silben-Timing manuell verfeinern.
6. Instrumentalspur separat als WAV behalten und hoerpruefen.
7. SRT/LRC fuer Textaustausch oder ASS fuer Karaoke-Styling exportieren.
8. Erst danach ein Video rendern oder eine separate Untertitelspur bereitstellen.

ASR-Wortzeiten sind Schaetzungen, keine Millisekunden-Wahrheit. Diarisierung,
Forced Alignment und Singing-Alignment sind unterschiedliche Aufgaben.
Faster-Whisper liefert nicht durch ein einzelnes Flag automatisch jedes LRC-
Exportformat; ein passender Exporter/Adapter ist erforderlich.

## 3. Der neue Offline-Konverter im Repository

Python 3.10+ reicht, keine externe Bibliothek, GPU, API oder Modelle.
Beim direkten Aufruf wird kein Workspace angelegt. Der optionale Installer
legt lediglich einen privaten Starter und seine Registrierung an. Ausgaben nur in
einen von dir explizit gewaehlten, bereits existierenden privaten Exportordner
ausserhalb des Repositories; vorhandene Dateien werden nicht ueberschrieben.

### Im Setup installieren, ohne Docker

`Karaoke_Formats` ist **eigener Code in unserem GitHub-Setup**, kein fremdes
Projekt und kein Container. Die bisherige Meldung war eine fehlende
Installationsaktion: Das Menue leitete `install` an den reinen Konverter weiter.
Jetzt richtet das Menue einen privaten Starter aus dem vorhandenen Checkout ein.
Ein zusaetzlicher Clone oder Download waere hier eine unnoetige zweite Kopie.
Ein Setup-Update von GitHub liefert den neuen Quellcode; lokale Aenderungen
sind noch keine Veroeffentlichung auf GitHub.

```bash
# Im aktuellen GitHub-Setup-Verzeichnis, ohne sudo:
bash scripts/tools/karaoke_formats_install.sh --dry-run
bash scripts/tools/karaoke_formats_install.sh
bash scripts/tools/karaoke_formats_doctor.sh
bash scripts/tools/karaoke_formats_status.sh

# Installierten Starter offline pruefen:
"$HOME/.openclaw_ultimate_user_data/tools/karaoke_formats/bin/karaoke-formats" plan
"$HOME/.openclaw_ultimate_user_data/tools/karaoke_formats/bin/karaoke-formats" \
  check --from srt --input examples/karaoke_formats/demo.srt
```

Voraussetzungen: Python 3.10+ und fuer die Shell-Starter Bash, keine pip-/npm-
Pakete, GPU, Modelle oder Dienste. Python 3.12 von Ubuntu 24.04 passt.
Fehlt Python, dieses Basiswerkzeug bewusst separat installieren. Unsere
vorsichtige Disk-Reserve: 64 MiB am Ziel, unter WSL zusaetzlich 1 GiB auf C:.
Dies sind Setup-Grenzen, keine gemessenen Mindestanforderungen. Keine schwere
RAM-/GPU-Installation: nur kleine Textdateien, Eingaben auf 2 MiB begrenzt.
MiniPC, RPi, VPS und GPU-PC nutzen denselben CPU-Konverter; K3s ist unnoetig.

Unter `~/.openclaw_ultimate_user_data/tools/karaoke_formats/` liegen
`bin/karaoke-formats` und `installed.json`; Protokolle stehen in `install_logs/`
des privaten User-Workspace. `OPENCLAW_USER_DATA_DIR` kann den absoluten
Workspace ausserhalb des Repos aendern. Symlink-/unaufgeloeste Pfade werden
abgelehnt. Der SHA-256-gepruefte Starter verweist auf diesen Checkout: wird
er verschoben oder der Konverter aktualisiert, Update erneut aufrufen.
Status/Doctor pruefen Quelle und Starter offline, ohne Daten anzulegen.

```bash
bash scripts/tools/karaoke_formats_update.sh
# Gleichbedeutend fuer eine Reparatur:
bash scripts/tools/karaoke_formats_install.sh --repair
bash scripts/tools/karaoke_formats_uninstall.sh
```

Installation ist idempotent. Ein Operations-Lock verhindert parallele
Aenderungen; nach einem harten Prozessabbruch einen verwaisten Lock erst
nach Pruefung laufender Prozesse manuell entfernen. Fremde Starter und
fremde Registrierungen werden nicht automatisch ueberschrieben. Repair/Update
kann einen registrierten Starter erneuern. Deinstallation entfernt nur den
unveraenderten Starter und seine Registrierung, keine Quellen, Logs, Medien
oder Exporte. Es gibt keine automatische PATH-/Shellprofil-Aenderung.
Unter Windows kann man den Starter auch mit `python -I -B <Starterpfad>`
aufrufen; die Shell-Menueintegration ist fuer Linux/WSL vorgesehen. Codex
installiert dabei nichts in einer vorhandenen WSL.

Die `install`/`update`/`uninstall`-Modi von `formats.py` selbst bleiben
absichtlich gesperrt: Installationen laufen ausschliesslich ueber die
Setup-Skripte beziehungsweise deren `manage.py`, Konvertierungen separat.

```bash
# Offline pruefen, nur Anzahl der Bloecke ausgeben:
python3 tools/karaoke_formats/formats.py check --from srt --input examples/karaoke_formats/demo.srt

# Plan: noch keine Eingabedatei lesen oder Ausgabe schreiben:
python3 tools/karaoke_formats/formats.py convert --from srt --to lrc
```

Erst fuer den expliziten Export mit eigenem absoluten Zielpfad:

```bash
python3 tools/karaoke_formats/formats.py convert --from srt --to lrc \
  --input examples/karaoke_formats/demo.srt \
  --output /ABSOLUTER_PRIVATER_EXPORTORDNER/demo.lrc --apply

python3 tools/karaoke_formats/formats.py convert --from lrc --to srt \
  --input examples/karaoke_formats/demo.lrc --last-end 00:06.000 \
  --output /ABSOLUTER_PRIVATER_EXPORTORDNER/demo.srt --apply
```

Platzhalter durch einen eigenen vorhandenen Ordner ersetzen. Ein Original
niemals als Ausgabeziel angeben. Unter Linux werden neue Dateien mit 0600
angelegt; Windows-Zugriffsrechte separat kontrollieren. Keine Textinhalte
oder Songtexte in allgemeinen Agenten-/CI-Logs speichern.

### Was die Konvertierung verliert

SRT zu LRC verliert Block-Endzeiten und visuelle Zeilenumbrueche. Der Export
nutzt Millisekunden mit drei Nachkommastellen; Player-Kompatibilitaet testen.
LRC zu SRT setzt das Ende einer Zeile auf den Beginn der naechsten; die
urspruenglichen Sprechpausen werden damit nicht rekonstruiert. Der letzte
Endzeitpunkt muss explizit angegeben werden. Ein Rundlauf ist **nicht verlustfrei**.

Unterstuetzte Teilmenge: einzelne aufsteigende Basis-LRC-Zeilenzeitstempel,
einige einfache Metadaten und geordnete, nicht ueberlappende SRT-Bloecke.
Nicht unterstuetzt: Enhanced LRC, nichtnull Offset, mehrfache Zeitstempel pro
LRC-Zeile, ASS/Karaoke-Tags, Duett-Ueberlappung oder beliebige SRT-Erweiterungen.
Diese Faelle werden abgelehnt, nicht still auf vermeintliche Wortzeiten reduziert.
Es gibt keine automatische LRC-zu-ASS-Wortausrichtung.

## 4. Englisches Lied mit deutschen/japanischen Texten

Zunaechst unterscheiden: eine inhaltliche Uebersetzung zum Mitlesen ist
nicht dasselbe wie ein singbarer Text mit passenden Reimen, Betonungen und
Silben. Original-Timing kann als Szenenraster dienen, aber keine automatisch
korrekte Wortverteilung der neuen Sprache liefern.

Ein spaeterer Ollama-Adapter sollte Texte ueber feste Segment-IDs uebersetzen;
Zeitstempel bleiben ausserhalb des Modells und werden vom Programm wieder
zugeordnet. Sprachliche Laengen, Auslassungen und Segmentzuordnung pruefen.
Keine Zeitstempel aus frei generierten Antworten ungeprueft uebernehmen.
Fuer singbare Karaoke-Fassungen neue Silbenzeiten manuell oder mit passendem
Alignment erarbeiten; Rechte an Uebersetzung/Bearbeitung klaeren.
Dieser Adapter und neue Gesangsaufnahmen sind hier nicht implementiert.

## 5. Editoren, Linux-Player und YouTube

Aegisub ist der geplante ASS-/Karaoke-Editor; Subtitle Edit ist bereits im
Setup registriert. Welche LRC-Varianten importiert/exportiert werden koennen,
haengt von Editor/Version ab. UltraStar hat ein eigenes notenbasiertes
Songformat: LRC oder SRT ersetzt dessen Tonhoehen-/Beatdaten nicht.

Fuer Linux sind VLC oder mpv Kandidaten fuer Video mit SRT/ASS. Darstellung,
Fonts und Karaoke-Effekte konkret testen; nicht jeder Renderer bildet jeden
Effekt identisch ab. Gleichnamige Datei im selben Ordner kann automatische
Erkennung erleichtern, garantiert aber keine Wort-Karaoke-Anzeige.
Native Enhanced-LRC-Anzeige und Desktop-Overlays sind ein eigener Client-Test.
Spotube, Strawberry, Lyrica oder lyrics-in-terminal nicht allein aufgrund des
Namens als universell kompatibel ausgeben; konkrete Version/Quelle fehlen im Auftrag.

YouTube: vorzugsweise ein dokumentiertes Untertitelformat wie SRT/WebVTT
bereitstellen. ASS-Karaoke-Styling nicht als erhaltene Uploadfunktion annehmen.
Fuer garantiert sichtbares eigenes Styling kann man es in die Videopixel
rendern (Hardsubs); es ist dann nicht abschaltbar. Separates SRT bleibt fuer
Barrierefreiheit/Sprachwahl sinnvoll. [YouTube-Formate](https://support.google.com/youtube/answer/2734698?hl=de).

FFmpeg mit libass kann ASS rendern; passende Build-Optionen/Fonts vorausgesetzt.
Eine abschaltbare ASS-Spur ist z. B. ein gesonderter MKV-/Player-Pfad, kein
universelles MP4-/YouTube-Versprechen. [FFmpeg-Filter](https://ffmpeg.org/ffmpeg-filters.html).
Es werden hier keine Videos gerendert oder hochgeladen.

## 6. Integration und offene Punkte

OpenClaw/n8n duerfen spaeter feste Schritte mit genehmigten Dateien ausloesen,
nicht beliebige Shellstrings aus Medienmetadaten. Fuer Sprache/SFX/Video
zunaechst ein Job, danach Ressourcen messen. Keine Modelle, Tokens, Stimmen
oder private Filme automatisch in externe Dienste schicken. K3s optional,
kein noetiger Zusatz zur Offline-Formatkonvertierung.

Offen: echter ASR-/Gesangs-Alignment-Test, lokale Uebersetzung, Separation,
ASS-Export, Editor-/Player-Matrix und ein freigegebener OpenClaw/n8n-Adapter.
Der Formatkonverter prueft weder Urheberrechte noch die inhaltliche Richtigkeit.

```bash
python3 -m unittest discover -s tests -p test_karaoke_formats.py -v
```
