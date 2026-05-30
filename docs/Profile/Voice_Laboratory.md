# Voice Laboratory

## Zweck
Voice Laboratory ist der experimentelle Bereich fuer neue Voice-, Singing-, Emotion- und Chor-Modelle. Es ist bewusst nicht fuer Auto-Installationen gedacht.

## Typische Aufgaben
- Neue GitHub-Voice-Projekte pruefen.
- Modelle nach Ressourcenbedarf und Lizenz sortieren.
- Kleine Proof-of-Concepts isoliert testen.
- Ergebnisse, Risiken und Reproduzierbarkeit dokumentieren.

## Empfohlene Tools
- StyleTTS2.
- OpenVoice.
- RVC.
- Seed-VC.
- DiffSinger.
- NNSVS.

## Ressourcenbedarf
- GPU-Workstation empfohlen.
- 16-32 GB RAM, 8-24 GB VRAM je nach Modell.
- Viel Speicher fuer Datasets, Checkpoints und Exporte.

## Sicherheitsregeln
- Keine ungeprueften Modelle produktiv nutzen.
- Keine `curl | bash`-Installer ohne Review.
- Lizenzen und Trainingsdaten dokumentieren.
- Keine Fremdstimmen ohne Einwilligung.

## Beispiel-Prompt
```text
Bewerte dieses neue Voice-GitHub-Projekt fuer unser Setup:
Lizenz, Ressourcenbedarf, Sicherheitsrisiken, Installationsweg und Rollback.
```

