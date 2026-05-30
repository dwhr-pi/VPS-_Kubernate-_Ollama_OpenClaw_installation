# Tutorial: Eigene Stimme trainieren

Dieses Tutorial ist fuer eigene Stimmen gedacht. Fremde Stimmen duerfen nur mit ausdruecklicher, dokumentierter Einwilligung verwendet werden.

## Schritt 1: Aufnahme
- Mindestens 30 Minuten Sprache aufnehmen.
- Format: WAV, 16 Bit, 44.1 kHz.
- Ruhiger Raum, gleichbleibender Mikrofonabstand.
- Verschiedene Saetze, Emotionen und Sprechgeschwindigkeiten aufnehmen.

## Schritt 2: Audio reinigen
- Stoergeraeusche mit Audacity entfernen.
- Bei gemischten Spuren UVR5 fuer Trennung pruefen.
- Keine aggressive Rauschreduktion verwenden, wenn die Stimme dadurch metallisch klingt.

## Schritt 3: Datensatz vorbereiten
```text
voice_dataset/
  wavs/
    0001.wav
    0002.wav
  metadata.csv
```

`metadata.csv` sollte je Zeile Datei und Text enthalten. Beispiel:

```csv
wavs/0001.wav|Das ist eine kurze Testaufnahme.
wavs/0002.wav|Heute trainiere ich meine eigene Stimme.
```

## Schritt 4: XTTS Training
1. Coqui TTS / XTTS v2 nur in einer isolierten Umgebung vorbereiten.
2. Python-Version und CUDA-Kompatibilitaet pruefen.
3. Kleinen Testlauf mit wenigen Dateien starten.
4. Ergebnis kennzeichnen: `KI-Stimme, basierend auf eigener Stimme`.

## Schritt 5: RVC Training
1. Saubere Sprach- oder Gesangssegmente vorbereiten.
2. RVC-Projektordner ausserhalb des Repos speichern.
3. Training nur starten, wenn genug RAM/VRAM frei ist.
4. Testausgaben vergleichen und Qualitaet dokumentieren.

## Schritt 6: OpenVoice Training / Transfer
1. Referenzstimme aus eigenem Material waehlen.
2. Transfer nur fuer erlaubte Inhalte testen.
3. Ausgabe nicht automatisch veroeffentlichen.

## Speicherorte
- Rohdaten: `~/.openclaw_ultimate_user_data/voice_studio/datasets/`
- Modelle: `~/.openclaw_ultimate_user_data/voice_studio/models/`
- Exporte: `~/.openclaw_ultimate_user_data/voice_studio/exports/`

## Warnung
Voice-Cloning kann Menschen taeuschen. Deshalb gilt: keine Fremdstimmen, keine Identitaetsimitation, keine automatische Veroeffentlichung, keine Secrets oder Rohdaten ins Git-Repo.

