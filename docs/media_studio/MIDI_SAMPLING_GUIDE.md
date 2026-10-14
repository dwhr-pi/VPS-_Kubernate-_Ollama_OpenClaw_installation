# Audio, MIDI, Samples und Plugins unterscheiden

[Gepruefte Tool-Kandidaten](AUDIO_VIDEO_TOOL_CATALOG.md). Keine Software oder
Gewichte werden durch diese Anleitung installiert.

## Was ist was?

| Format/Technik | Inhalt | Kein Ersatz fuer |
|---|---|---|
| WAV/FLAC | aufgenommener/generierter Klang | editierbare MIDI-Noten |
| MIDI | Notenereignisse, Dauer, Anschlag/Controller | gesampeltes Klangbild oder Originalstimme |
| SFZ/SoundFont | Zuordnung von Samples zu Noten/Velocity/Loop-Punkten | ein neu kompiliertes Plugin |
| VST3/LV2/AU | ausgefuehrter Instrument-/Effektcode | ein einfaches WAV- oder KI-Gewichtsformat |
| VFX | visuelle Effekte | DSP-/Audioeffekte; Host-Schnittstellen sind verschieden |

Nicht jede Musik-KI ist ein autoregressives LLM. Die Modellarchitektur und
deren tatsaechliche Export-API pruefen. WAV-Erzeugung bedeutet weder MIDI-
noch Plugin-Export. Modellgewichte sind kein fertiges VST-Instrument.

## Audio zu MIDI

Basic Pitch ist ein verifizierter Kandidat fuer Audio-to-MIDI. Erst mit einer
einzelnen klaren Instrumentenspur testen. Mischungen, Percussion, Vibrato,
Akkorde und Hall koennen Fehlnoten/Oktavfehler erzeugen. In der DAW gegenhoeren,
Tempo und Notenlaengen korrigieren. Ein MIDI-Piano klingt nicht automatisch
wie das urspruengliche Instrument; dafuer braucht es passenden Synth/Sampler.
[Primaerquelle](https://github.com/spotify/basic-pitch).

A2M und Creative MIDI Companion sind im Ausgangstext nicht eindeutig einem
Upstream zugeordnet; deshalb keine erfundenen Installationslinks.
Magenta ist ein eigener historischer MIDI-/Musikwerkzeugpfad, nicht pauschal
ein aktueller Plugin-Standard fuer jede Plattform.

## Stems und Sampler

Demucs/UVR5 koennen Vocals/Begleitung oder Modell-typische Stems trennen.
Ergebnis ist nicht perfekt isoliert: Uebersprechen, Hallreste und Artefakte
bleiben moeglich. `--two-stems=vocals` erzeugt bei Demucs typischerweise
`vocals.wav` und `no_vocals.wav`, nicht zwingend `instrumental.wav`.
Das Ergebnis gegenhoeren; Original nicht ueberschreiben.

Fuer ein Samplerinstrument kurze WAV-Samples schneiden, Grundton, Loop-Punkte,
Lautheit und Velocity-Layer pruefen. In SFZ z. B. Samples auf Notenbereiche
abbilden und mit sfizz abspielen. Ein Soundeffekt ohne stabile Tonhoehe wird
dadurch nicht automatisch zu einem gut spielbaren melodischen Instrument.
[sfizz](https://github.com/sfztools/sfizz).

## Eigene Effekte entwickeln

AIDA-X ist ein Amp-Modell-Player. Capture, Training und gueltiges Modellformat
sind getrennte Aufgaben; daraus entsteht nicht automatisch ein eigenes VST-
Binary. Audio Plugin Coder braucht eine konkrete Quelle und Build-/Lizenzpruefung.
Eine MIT-Lizenz einer Hilfsanwendung ersetzt nicht die Lizenzbedingungen von
JUCE, Plugin-SDKs, Bibliotheken oder enthaltenen Samples.
[AIDA-X](https://github.com/AidaDSP/AIDA-X).

Fuer spaetere Agentic-Plugin-Entwicklung: isoliertes Projekt, DSP-Unit-Tests,
Plugin-Validierung, keine Echtzeit-Thread-Blockaden, Pegelschutz und Tests in
einem Dummy-Host. Neue Plugins nicht ungeprueft im produktiven DAW-Projekt laden.
Es wird hier kein Plugin generiert, trainiert, kompiliert oder installiert.

Rechte an Musik, Stimmen, Samples und Modelloutputs vor Weitergabe pruefen;
Trennen oder Umwandeln hebt Rechte am Ausgangsmaterial nicht auf.
