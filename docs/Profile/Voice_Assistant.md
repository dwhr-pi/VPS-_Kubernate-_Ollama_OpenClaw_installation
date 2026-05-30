# Profil: Voice_Assistant

## Zweck
Profil für einen lokalen Sprachassistenten mit Wakeword, STT, TTS und Smart-Home-Anbindung.

## Use Cases
- lokaler Sprachassistent
- Sprachsteuerung für Home Assistant
- Voice-Pipelines für Räume oder Geräte

## Enthaltene Tools
- Whisper.cpp
- faster-whisper
- Piper
- openWakeWord
- Rhasspy
- Wyoming
- Mosquitto

## Installation
```bash
scripts/profiles/Voice_Assistant_install.sh
```

## Ports
- 1883 Mosquitto
- 12101 Rhasspy

## Modelle
- lokale STT/TTS-Modelle

## Abhängigkeiten
- Audio-Geräte
- optional Home Assistant

## Ressourcenverbrauch (CPU / RAM / Storage)
- CPU: mittel
- RAM: ab 8 GB
- Storage: ab 12 GB

## Sicherheitshinweise
- Audio- und Raumdaten lokal halten
- Mikrofonfreigaben und Netzwerkzugriffe bewusst prüfen
- Piper bleibt der Standard fuer lokale Sprachausgabe; Coqui/OpenVoice/RVC nur optional und nicht automatisch aktivieren.
- Keine fremden Stimmen ohne Einwilligung als Assistenzstimme verwenden.

## Voice-Studio-Erweiterung

Dieses Profil ist Teil der Voice-Studio-Gruppe. Fuer einfache Home-Assistant-Ausgaben reicht Piper. Fuer hochwertige Stimmen, Voice-Cloning oder Dubbing bitte die Profile `Voice_Studio`, `Voice_Clone` und `Dubbing_Studio` lesen und die Sicherheitsregeln beachten.

## Start / Stop / Status Befehle
```bash
docker ps
ss -ltn | grep -E '1883|12101' || true
```

## Test-Command
```bash
bash scripts/profiles/Voice_Assistant_install.sh
```

## Deinstallation
```bash
scripts/profiles/Voice_Assistant_uninstall.sh
```
