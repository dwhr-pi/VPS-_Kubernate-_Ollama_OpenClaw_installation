# Telefon- und Fritz!Fon-Konzept

## Status

Konzept / optionales Advanced-Modul.

Dieses Dokument beschreibt moegliche Integrationen. Es behauptet **keine** vollstaendige Implementierung im aktuellen Repo.

## Moegliche Integrationen

- Fritz!Box Call Monitor
- SIP oder Asterisk
- Home Assistant
- Whisper oder Vosk fuer Speech-to-Text
- Piper, Coqui oder XTTS fuer Text-to-Speech
- OpenClaw und Ollama als Reasoning-Schicht

## Denkbare Rollen

- Callcenter-Persona
- Telefonzentrale
- Terminannahme
- Rueckrufnotizen
- Weiterleitungslogik

## Beispielablauf

1. eingehender Anruf
2. STT transkribiert den Anrufer
3. Persona antwortet im `callcenter`-Modus
4. Ergebnis wird als Notiz oder Termin gespeichert
5. bei Bedarf Weitergabe an Mensch oder System

## Sicherheits- und Transparenzregeln

- Anrufer duerfen nicht ueber die KI-Natur im oeffentlichen Einsatz getaeuscht werden
- Telefon- und Termin-Memory nur dokumentiert und datensparsam speichern
- keine unbemerkte Aufzeichnung ohne rechtliche Grundlage
