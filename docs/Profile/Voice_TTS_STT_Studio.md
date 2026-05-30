# Voice_TTS_STT_Studio

## Zweck

STT/TTS, Transkription und Voice-Pipelines.

## Status

- Installationsreife: planned
- Ressourcenklasse: heavy
- Empfohlene Geraete: GPU Workstation, Home Server

## Empfohlene Tools

- whisper_cpp
- faster_whisper
- piper
- coqui_tts

## Sicherheitsregeln

- Keine schweren Installer automatisch starten.
- Secrets nur unter `~/.openclaw_ultimate_user_data` speichern.
- Remotezugriff bevorzugt ueber WireGuard/Tailscale/Allowlist.
- Schreibende Agentenaktionen brauchen Human Approval.

## Installationshinweis

Dieses Profil ist zuerst als Planungs- und Auswahlprofil gedacht. Einzelne Tools muessen bewusst im Setup-Menue ausgewaehlt werden.

## Beispiel-Prompt

```text
Pruefe das Profil Voice_TTS_STT_Studio fuer mein System. Erstelle einen sicheren Installationsplan mit Ressourcencheck, aber starte keine schweren Installer automatisch.
```
