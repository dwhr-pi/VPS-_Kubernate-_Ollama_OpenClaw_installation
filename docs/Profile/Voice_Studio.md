# Voice Studio

## Zweck
Das Voice Studio ist das zentrale Profil fuer lokale Sprachsynthese, Voice-Over, Mehrsprecher-Projekte, Podcasts, Hoerbuecher und sichere Voice-Cloning-Experimente. Es startet bewusst als `planned`/`documentation-first`, weil Stimmtraining und Voice-Cloning rechtlich sensibel und oft GPU-lastig sind.

## Typische Aufgaben
- Text in Sprache umwandeln.
- Sprecherrollen fuer Podcast, Hoerbuch oder Video verwalten.
- Stimmproben katalogisieren und Trainingsdaten vorbereiten.
- Voice-Over fuer Videos oder Home-Assistant-Ausgaben erzeugen.
- Ergebnisse als WAV/MP3/Markdown-Protokoll ablegen.

## Empfohlene Tools
- Piper fuer schnelles lokales TTS auf CPU.
- Coqui TTS / XTTS v2 fuer hochwertige Stimmen und Voice-Cloning.
- StyleTTS2 fuer emotionale Studio-Stimmen.
- OpenVoice fuer Voice Transfer.
- FFmpeg und Audacity fuer Schnitt, Export und Normalisierung.

## Minimaler Installationspfad
1. Piper und FFmpeg installieren.
2. Test mit kurzer Textdatei ausfuehren.
3. Ergebnisse lokal unter `~/.openclaw_ultimate_user_data/voice_studio/` speichern.

## Full-Installationspfad
1. Coqui TTS/XTTS v2 nur nach Python-/GPU-/RAM-Check aktivieren.
2. OpenVoice und StyleTTS2 als experimentelle Source-Tools pruefen.
3. n8n/OpenClaw-Workflow fuer Freigabe, Export und Logging nutzen.

## Ressourcenbedarf
- Piper: CPU, 1-2 GB RAM, wenige GB Speicher.
- Coqui/XTTS: 8-16 GB RAM, GPU empfohlen, mehrere GB Modelle.
- OpenVoice/StyleTTS2: GPU empfohlen, 8+ GB VRAM fuer komfortables Arbeiten.

## Sicherheitsregeln
- Nur eigene Stimmen oder Stimmen mit ausdruecklicher Einwilligung verwenden.
- KI-Stimmen kennzeichnen.
- Keine fremden Stimmen fuer Taeuschung, Betrug oder Identitaetsimitation nutzen.
- Rohaufnahmen und Modelle nicht ins Git-Repo schreiben.

## Modelle
- Lokal leicht: Piper-Stimmen.
- Lokal Studio: XTTS v2, OpenVoice, StyleTTS2.
- Cloud optional: nur mit Kostenwarnung und extern gespeicherten API-Keys.

## Beispiel-Prompt
```text
Erstelle aus diesem Text drei Voice-Over-Varianten: freundlich, sachlich und energisch.
Nutze nur lokale Stimmen und speichere WAV plus Markdown-Protokoll.
```

