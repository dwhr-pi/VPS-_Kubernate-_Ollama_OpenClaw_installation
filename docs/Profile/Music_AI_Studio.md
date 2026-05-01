# Profil: Music_AI_Studio

## Zweck
Musik- und Audio-AI-Studio für Analyse, Stem-Separation und lokale Prompt-/Produktionshilfen.

## Use Cases
- Stems erzeugen
- Musik analysieren
- Audio vorbereiten
- Songstruktur und Prompt-Hilfen

## Enthaltene Tools
- Demucs
- FFmpeg
- librosa
- pydub
- MusicGen
- BPM Analyzer

## Installation
```bash
scripts/profiles/Music_AI_Studio_install.sh
```

## Ports
- keine Pflichtports

## Modelle
- MusicGen optional

## Abhängigkeiten
- Python

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: 8 GB+
- Storage: 20 GB+

## Sicherheitshinweise
- keine Suno-/Udio-API-Umgehung

## Start / Stop / Status Befehle
```bash
ffmpeg -version
```

## Test-Command
```bash
bash scripts/profiles/Music_AI_Studio_install.sh
```

## Deinstallation
```bash
scripts/profiles/Music_AI_Studio_uninstall.sh
```
