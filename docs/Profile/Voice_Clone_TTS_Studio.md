# Profil: Voice_Clone_TTS_Studio

## Zweck
Lokale Voiceover-, TTS- und Transkriptions-Pipeline für sichere Sprachworkflows.

## Use Cases
- Voiceover
- STT/TTS
- Audiobearbeitung
- Transkription

## Enthaltene Tools
- Piper
- Coqui TTS
- Whisper.cpp
- faster-whisper
- FFmpeg
- pydub

## Installation
```bash
scripts/profiles/Voice_Clone_TTS_Studio_install.sh
```

## Ports
- keine Pflichtports

## Modelle
- Piper-Stimmen
- Whisper-Modelle

## Abhängigkeiten
- Python
- FFmpeg

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: 8 GB+
- Storage: 15 GB+

## Sicherheitshinweise
- Stimmen und Sprachdaten nur mit Nutzungsrechten verwenden

## Start / Stop / Status Befehle
```bash
ffmpeg -version
```

## Test-Command
```bash
bash scripts/profiles/Voice_Clone_TTS_Studio_install.sh
```

## Deinstallation
```bash
scripts/profiles/Voice_Clone_TTS_Studio_uninstall.sh
```
