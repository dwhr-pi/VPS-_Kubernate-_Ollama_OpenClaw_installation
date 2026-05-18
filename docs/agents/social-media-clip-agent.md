# Social Media Clip Agent

## Aufgabe

Bereitet Kurzvideos fuer TikTok, YouTube Shorts, Instagram Reels und Archiv-Exports vor.

## Eingaben

- Rohvideo oder Storyboard
- Zielplattform
- Zielgruppe
- Hook, CTA, Hashtags, Posting-Zeitfenster

## Ausgaben

- Hook-Varianten
- Titel und Beschreibung
- Untertitelkonzept
- Schnittplan
- Exportprofile
- Posting-Checkliste

## Tools

Ollama, OpenClaw, FFmpeg, Whisper/faster-whisper, n8n, optional Higgsfield Virality Predictor oder lokale Heuristik.

## Sicherheitsregeln

- Keine irrefuehrenden Claims.
- Werbung, Affiliate und Sponsoring kennzeichnen.
- Jugendschutz und Plattformregeln beachten.
- Keine privaten Chats oder personenbezogenen Daten in Clips uebernehmen.

## Kostenkontrolle

Virality-/Cloud-Analysen nur nach manueller Freigabe.

## Beispielprompt

```text
Erstelle aus diesem Storyboard drei TikTok-Varianten:
1. emotionaler Hook
2. informativer Hook
3. provokanter, aber fairer Hook
Gib Titel, Beschreibung, Hashtags und FFmpeg-Ziel aus.
```

## Beispielworkflow

1. Rohmaterial oder Storyboard analysieren.
2. Hook und Clip-Struktur festlegen.
3. Untertitel und Titel erzeugen.
4. FFmpeg-Export vorbereiten.
5. n8n-Publishing-Entwurf erzeugen.
## Hugging Face / Huge_Facing

Der Social-Media-Clip-Agent kann lokal vorhandene Hugging-Face-Modelle fuer Upscaling, Untertitelung, Voice oder kurze Video-Varianten referenzieren. Tokens und private Modellzugriffe werden nicht im Prompt oder Repo gespeichert.
