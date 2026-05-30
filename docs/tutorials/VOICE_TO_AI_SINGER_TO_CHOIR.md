# Beispielprojekt: Eigene Stimme zu AI Saenger und Chor

## Eingabe
```text
Daniel.wav
```

## Ausgabeziele
- Sprecher.
- Hoerbuchsprecher.
- Saenger.
- Maennerchor.
- Gemischter Chor.
- Gregorianischer Chor.
- Celtic Choir.
- Trance EDM Choir.

## Workflow
1. `Daniel.wav` sichern und nicht ins Repo kopieren.
2. Aufnahme mit Audacity reinigen.
3. Dataset unter `~/.openclaw_ultimate_user_data/voice_studio/datasets/daniel/` vorbereiten.
4. Piper fuer schnelle Sprecher-Drafts nutzen.
5. XTTS/OpenVoice fuer eigene Sprecherstimme testen.
6. RVC oder Seed-VC fuer Saenger-Prototypen testen.
7. OpenUtau/DiffSinger fuer Melodie und Chorlinien nutzen.
8. Chor-Layer in Sopran, Alt, Tenor und Bass planen.
9. Mixdown mit FFmpeg erstellen.
10. Ergebnis mit KI-Kennzeichnung und Projektprotokoll exportieren.

## Minimal-Setup
- Piper.
- FFmpeg.
- Audacity.

## Empfohlenes Setup
- Piper.
- Coqui TTS / XTTS v2.
- FFmpeg.
- Audacity.
- Job Queue.

## High-End Studio Setup
- GPU-Workstation.
- RVC.
- Seed-VC.
- DiffSinger.
- OpenUtau.
- UVR5.
- Job Queue mit Parallelitaet 1 fuer schwere Jobs.

