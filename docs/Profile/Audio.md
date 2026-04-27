# Profil: Audio

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Audio.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Audio.doc.md:1), `readme.md` und den vorhandenen Tool-Skripten zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Audioprofil für Transkription, Sprachverarbeitung und Audio-Bereinigung.

## Installierter Stack

- Basis: `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - Whisper unter `/opt/whisper`
  - FFmpeg systemweit
  - librosa unter `/opt/librosa`
  - pydub unter `/opt/pydub`

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- Piper
- Coqui TTS

## Verantwortlichkeiten

- Sprache transkribieren
- Audio bereinigen und konvertieren
- Voice-Workflows vorbereiten
- Audio für OpenClaw-Pipelines strukturieren

## Verfügbare Kommandos

```bash
scripts/tools/whisper_install.sh
scripts/tools/ffmpeg_install.sh
scripts/tools/librosa_install.sh
scripts/tools/pydub_install.sh
```

## Beispielprompts

### Audio Transkription

```txt
Transkribiere die folgende Audiodatei mit Whisper,
erkenne Sprecherwechsel soweit möglich und gib mir eine bereinigte Textfassung plus kurze Zusammenfassung.
```

### Audio Cleanup

```txt
Bereite die Audiodatei für einen Voice-Assistant-Workflow vor.
Nutze FFmpeg für Konvertierung und Cleanup und gib die empfohlenen Verarbeitungsschritte an.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw für Audio-Pipelines und Vorverarbeitung.
- `Whisper` deckt Speech-to-Text ab.
- `FFmpeg`, `librosa` und `pydub` ergänzen Analyse und Cleanup.
- Für echtes Text-to-Speech fehlen noch die dokumentierten TTS-Bausteine.

## Vergleich

### ✅ In Sync

- `Whisper` und `ffmpeg` aus der Quelle sind im Projekt bereits als installierbare Tools vorhanden.
- Die Audioanalyse kann zusätzlich über `librosa` und `pydub` gestützt werden.

### ⚠ Missing in Setup

- `Piper` und `Coqui` fehlen noch als installierbare TTS-Module.
- Ein explizites Voice-Assistant-Laufzeitprofil gibt es noch nicht.

### ❌ Missing in Docs

- Dieses Audioprofil war lokal bislang noch nicht als eigene Zielseite vorhanden.

## Hinweise

- Das Profil ist aktuell stark bei Transkription und Nachbearbeitung, aber noch nicht vollständig bei TTS.
