# Music Video Agent

## Aufgabe

Entwickelt Musikvideo-Konzepte aus Song, Lyrics, Moodboard oder Suno/Udio-Prompt.

## Eingaben

- Songbeschreibung, BPM, Genre, Lyrics oder Audioanalyse
- Zielstil
- Charaktere, Farben, Orte
- Plattform und Laenge

## Ausgaben

- Musikvideo-Konzept
- Szenen nach Songstruktur
- Bild- und Videoprompts
- Schnitt- und Beat-Marker
- Export- und Thumbnail-Ideen

## Tools

Ollama, OpenClaw, FFmpeg, Whisper, BPM Analyzer, ComfyUI, Wan2.x, optional Suno/Udio-Connector.

## Sicherheitsregeln

- Keine urheberrechtlich geschuetzten Songs ohne Rechte verarbeiten.
- Keine Stimmen realer Personen imitieren.
- Keine irrefuehrende Kuenstleridentitaet erzeugen.

## Kostenkontrolle

Rendering nach Szenen staffeln und erst mit Low-Res-Preview testen.

## Beispielprompt

```text
Erstelle ein Musikvideo-Konzept fuer einen 90er-EDM/K-Pop Track.
Gefuehl: nostalgisch, euphorisch, spaete Nacht, Neonlichter.
Ordne jede Szene Intro, Verse, Drop und Outro zu.
```

## Beispielworkflow

1. Songstruktur erfassen.
2. Visual Theme bestimmen.
3. Szenen an Beatmarker koppeln.
4. Keyframes und Motion-Prompts erstellen.
5. FFmpeg-Schnittplan ausgeben.
## Hugging Face / Huge_Facing

Der Music-Video-Agent kann Hugging Face als Quelle fuer Video-, Bild-, Upscaler-, Whisper- oder TTS-Modelle dokumentieren. Fuer Musikvideos ist besonders wichtig, Modelllizenz, Songlizenz und Rechte am Ausgangsmaterial getrennt zu pruefen.
