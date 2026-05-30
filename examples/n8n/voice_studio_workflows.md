# n8n Voice Studio Workflow-Vorlagen

Diese Datei beschreibt die Vorlagen bewusst als Ablauf statt als sofort importierbare produktive JSON-Datei. Damit vermeiden wir gefaehrliche Defaults fuer Voice-Cloning oder automatische Veroeffentlichung.

## Text zu Sprache
- Trigger: Webhook.
- Check: Consent und Zielpfad.
- Action: Piper TTS.
- Action: FFmpeg Export.
- Output: WAV/MP3 plus Markdown-Protokoll.

## Text zu Hoerbuch
- Trigger: Datei oder Text.
- Split: Kapitel.
- Queue: ein Job pro Kapitel.
- Review: manuelle Hoerprobe.
- Output: Kapiteldateien plus Gesamt-MP3.

## Text zu Podcast
- Trigger: Thema oder Outline.
- LLM: Skriptentwurf.
- TTS: Sprecherrollen.
- Review: manuelle Freigabe.
- Output: Episode plus Show Notes.

## Text zu Chor
- Trigger: Lyrics.
- Planung: SATB.
- Queue: Renderjobs seriell.
- Review: manuelle Freigabe.
- Output: Layer und Mixdown.

## Text zu Song-Demo
- Trigger: Songidee.
- Planung: Struktur, Stil, Stimme.
- Tools: OpenUtau/DiffSinger/RVC nur planned.
- Output: Demo-Protokoll, keine automatische Veroeffentlichung.

