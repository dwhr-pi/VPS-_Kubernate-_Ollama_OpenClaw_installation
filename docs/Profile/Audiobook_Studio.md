# Audiobook Studio

## Zweck
Audiobook Studio ist fuer Hoerbuecher, lange Lesungen, Kapitelstruktur, Rollenstimmen und Qualitaetskontrolle vorgesehen.

## Typische Aufgaben
- Text in Kapitel zerlegen.
- Rollen und Sprecherstimmen zuweisen.
- Lange TTS-Jobs ueber die Job Queue ausfuehren.
- Hoerbuch als WAV/MP3 plus Kapitel-Metadaten exportieren.

## Empfohlene Tools
- Piper fuer schnelle Vorproduktion.
- Coqui TTS / XTTS v2 optional fuer Rollenstimmen.
- FFmpeg fuer Kapitel und Audioexport.
- Audacity fuer manuelle Kontrolle.

## Ressourcenbedarf
- Minimal: CPU, 8 GB RAM.
- Empfohlen: 16 GB RAM und Queue-Manager.
- GPU optional fuer hochwertige Voice-Modelle.

## Sicherheitsregeln
- Urheberrechte am Text pruefen.
- KI-Stimmen kennzeichnen.
- Keine Trainingsdaten oder fertige Hoerbuecher ohne Rechte verteilen.

## Beispiel-Prompt
```text
Plane aus diesem Manuskript ein Hoerbuch mit Kapiteln, Rollenstimmen,
Pausenregeln und Exportformaten.
```

