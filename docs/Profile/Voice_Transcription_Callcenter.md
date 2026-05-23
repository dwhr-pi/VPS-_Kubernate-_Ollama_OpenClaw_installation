# Voice Transcription Callcenter

Status: `planned`  
Hardwarebedarf: `medium`, GPU optional  
Installationsart: lokal, WSL2, GPU-Workstation

## Zweck

Lokale Sprach-Pipelines fuer Whisper/STT, TTS, Warteschleifenmusik, Gespraechszusammenfassung und einfache Callcenter-/Support-Workflows.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| Whisper.cpp | lokale STT | empfohlen |
| faster-whisper | GPU-faehige STT | empfohlen |
| Piper TTS | lokale TTS | empfohlen |
| Coqui XTTS | Voice-Cloning optional | experimentell |
| FFmpeg | Audio-Schnitt, Transcoding | empfohlen |

## Datenschutzregeln

- Einwilligung fuer Aufnahmen beachten.
- Gespraechsprotokolle lokal speichern und loeschbar halten.
- Keine Stimmklone ohne Rechte/Freigabe.
