# Audio Postproduction Local First

**Status: planned/documentation-first.** Keine automatische Toolinstallation.
Zweck: Hoerbuch, Synchronisation, SFX, MIDI und Karaoke als getrennte,
pruefbare Produktionsschritte statt eines unbegrenzten Agenten-Loops.

## Minimaler und erweiterter Pfad

Minimal: vorhandenes FFmpeg, Faster-Whisper, Demucs und Subtitle Edit bewusst
einzeln auswaehlen; die eigene [SRT/LRC-CLI](../media_studio/KARAOKE_SUBTITLES_GUIDE.md)
braucht nur Python 3.10+. Geplante Tools sind keine Voraussetzungen dafuer.
Full: je Aufgabe genau einen auditierten TTS-/Dubbing-/Video-Kandidaten aus
dem [Katalog](../media_studio/AUDIO_VIDEO_TOOL_CATALOG.md) auswaehlen.
Nicht alle Modelle gleichzeitig installieren oder laden.

## Aufgaben und Grenzen

Defensiver Zusatzpfad:
[Audio-Deepfakes pruefen/isolieren](../media_studio/AUDIO_DEEPFAKE_REVIEW.md).
Optional pyannote_audio, deepfilternet, audioseal (planned); keine Original-
ueberschreibung, Herkunftsverschleierung oder autonome Echtheitsentscheidung.

- Erlaubt: Rechte pruefen, synthetische Beispiele lesen, Segment-/Sprecherplan,
  Transkript- und Uebersetzungsvorschlaege, Ausgabeformate validieren.
- Freigabepflichtig: Medienverarbeitung, Stimmklonen, Modelldownload,
  neue lokale Exporte, Schnitt/Rendering und Veroeffentlichung.
- Verboten: fremde Stimmen ohne Einwilligung, versteckte Uploads,
  beliebige Shell-Befehle aus Medien/Prompts, automatische Publikation.
- Ergebnisse: explizit gewaehlter privater Ausgabeordner ausserhalb Git.
  Keine Sprache, Audioausschnitte, Tokens oder personenbezogenen Inhalte loggen.

## Modelle, Ressourcen und Zielhosts

Ollama nur fuer Skript-/Uebersetzungsvorschlaege; ein Sprachmodell ersetzt
keinen TTS- oder Alignment-Encoder. Cloud-Modelle nicht erforderlich;
eine spaetere Anbindung braucht ausdrueckliche Datenschutz-/Kostenfreigabe.
Keine ENV fuer Offline-Konvertierung; keine API-Keys generieren.

MiniPC/WSL2: erst Formatkonverter/kurze CPU-Tests; echte Host-SSD,
RAM/Swap und Python pruefen. RPi: Orchestrierung und Formatpruefung.
Oracle VPS: Queue/Steuerung statt schwerer Medienproduktion; keine Admin-Ports.
GPU-Workstation: ein schwerer Job, Ressourcen checkpointbezogen messen.
K3s nur optional, verteilte GPUs bilden keinen gemeinsamen VRAM-Pool.
CPU/RAM/VRAM/Disk-Einordnung steht im Katalog; keine ungemessenen Mindestwerte.

## OpenClaw / n8n

Integrationsvertrag, noch kein ausfuehrbarer Plugin-/Workflow-Adapter:
zuerst Segmentplan und Rechtefreigabe, dann ein erlaubter Worker-Auftrag,
Timeout/Retry-Limit, Vorschau und menschliche Abnahme.
Keinen ungeprueften Freitext als Shell-Kommando ausfuehren.

Beispiel: "Plane ein deutsches Hoerbuch aus meinem freigegebenen Skript;
verwende keine fremde Stimme und starte noch keinen Download."

Beispiel: "Pruefe diese synthetische LRC auf Zeilentiming.
Erfinde keine Silbenzeiten; uebersetze erst nach manuellem Review."

Siehe [Produktionsanleitung](../media_studio/AUDIO_DUBBING_PRODUCTION_GUIDE.md),
[MIDI/Sampling](../media_studio/MIDI_SAMPLING_GUIDE.md).
