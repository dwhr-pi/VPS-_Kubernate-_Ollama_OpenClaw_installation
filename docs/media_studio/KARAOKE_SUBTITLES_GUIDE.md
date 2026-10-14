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
Es wird keine neue Runtime-/Workspace-Struktur angelegt. Ausgaben nur in
einen von dir explizit gewaehlten, bereits existierenden privaten Exportordner
ausserhalb des Repositories; vorhandene Dateien werden nicht ueberschrieben.

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
