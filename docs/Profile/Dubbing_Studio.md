# Dubbing Studio

## Zweck
Dubbing Studio deckt Synchronisation, Voice-Over, Mehrsprecher-Dialoge und lokale Transkriptions-/TTS-Pipelines ab.

## Typische Aufgaben
- Audio transkribieren.
- Sprecherrollen erkennen.
- Uebersetzung oder Umschreibung vorbereiten.
- Dubbing-Spuren erzeugen und mit Video synchronisieren.

## Empfohlene Tools
- faster-whisper oder Whisper.cpp fuer Transkription.
- Piper oder Coqui TTS fuer Ausgabe.
- OpenVoice/RVC optional fuer freigegebene Stimmen.
- FFmpeg fuer Synchronisation.

## Ressourcenbedarf
- Transkription: CPU moeglich, GPU schneller.
- Dubbing mit Voice Conversion: GPU empfohlen.

## Sicherheitsregeln
- Keine fremden Stimmen imitieren.
- Keine irrefuehrenden Deepfake-Dubbings.
- Menschliche Freigabe vor Export und Veroeffentlichung.

## Beispiel-Prompt
```text
Erstelle einen Dubbing-Plan fuer dieses Video: Transkription, Sprecherrollen,
TTS-Stimmen, Timing und manuelle Freigabepunkte.
```

