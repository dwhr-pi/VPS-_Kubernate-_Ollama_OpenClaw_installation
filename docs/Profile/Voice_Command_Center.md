# Voice Command Center

Profil fuer lokale Sprachsteuerung mit Whisper/faster-whisper, Piper/Coqui, Home Assistant, Node-RED und OpenClaw.

## Fokus

- Sprache zu Text fuer PC-, Smart-Home- und Agentenbefehle
- lokale TTS-Ausgabe fuer Rueckmeldungen
- Node-RED/n8n als sichere Freigabeschicht
- Audit-Logs fuer Sprachbefehle

## Sicherheitsregel

Sprachbefehle werden standardmaessig als Vorschlag interpretiert. Kritische Aktionen brauchen Bestaetigung, Rollenpruefung und Grenzwerte.

## Installation

```bash
bash scripts/profiles/Voice_Command_Center_install.sh
```
