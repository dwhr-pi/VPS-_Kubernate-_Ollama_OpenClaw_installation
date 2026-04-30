# Profil: Audio_Voice_Music

## Zweck
Lokale Audio-, Sprache- und Musik-Pipeline mit Whisper.cpp, Piper, Coqui TTS, FFmpeg und optional MusicGen.

## Use Cases
- Transkription
- lokale TTS
- Audio-Vorverarbeitung
- Musik-Experimente

## Enthaltene Tools
- Whisper.cpp
- Piper
- Coqui TTS
- FFmpeg
- MusicGen optional

## Installation
```bash
scripts/profiles/Audio_Voice_Music_install.sh
```

## Ports
- keine Pflichtports

## Modelle
- lokale Whisper-Modelle
- Piper-Stimmen
- MusicGen optional

## Abhängigkeiten
- Python
- FFmpeg

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 8 GB
- Storage: ab 15 GB

## Sicherheitshinweise
- Sprachdaten können personenbezogen sein
- Modelle und Stimmen nur aus vertrauenswürdigen Quellen

## Start / Stop / Status Befehle
```bash
ffmpeg -version
```

## Test-Command
```bash
bash scripts/profiles/Audio_Voice_Music_install.sh
```

## Deinstallation
```bash
scripts/profiles/Audio_Voice_Music_uninstall.sh
```
