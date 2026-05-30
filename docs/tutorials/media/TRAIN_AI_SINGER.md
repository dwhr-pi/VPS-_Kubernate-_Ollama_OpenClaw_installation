# Tutorial: AI Singer trainieren

## Ziel
Aus eigenem oder freigegebenem Gesangsmaterial entsteht ein KI-Saenger fuer Demos, Chor-Layer oder private Experimente.

## Datenmenge
- Minimum: 30 Minuten Gesang.
- Besser: 2 bis 10 Stunden.
- Enthaltene Stimmen: Maennerstimmen, Frauenstimmen, Kinderstimmen nur mit besonderer Zustimmung, Chorstimmen nur mit Freigabe aller Beteiligten.

## Vorbereitung
1. Gesang als WAV exportieren.
2. Atem-, Klick- und Stoergeraeusche markieren.
3. Mit UVR5 Instrumente und Stimme trennen, falls noetig.
4. Mit Audacity Pegel normalisieren und harte Artefakte entfernen.

## Tool-Auswahl
- RVC: guter Start fuer Voice Conversion und Singer-Prototypen.
- Seed-VC: moderne Voice Conversion, experimentell.
- DiffSinger: KI-Gesang aus Noten/MIDI/Text.
- OpenUtau: Arrangement und virtuelle Saenger.
- NNSVS: fortgeschrittenes Training eigener Singing-Voice-Modelle.

## Trainingsablauf
1. Kleinen Proof-of-Concept mit 5-10 Minuten Material ausfuehren.
2. Qualitaet, Artefakte und rechtliche Freigabe pruefen.
3. Erst danach laengeren Lauf ueber Job Queue starten.
4. Modellversion, Dataset, Toolversion und Exportdatum dokumentieren.

## Ausgabeformate
- WAV fuer Produktion.
- MP3 fuer Vorhoeren.
- Markdown-Protokoll mit Toolversionen, Quellenstatus und Kennzeichnung.

## Sicherheitsregeln
- Keine beruehmten Stimmen nachbauen.
- Keine fremden Saenger ohne Zustimmung imitieren.
- KI-Gesang deutlich kennzeichnen.
- Trainingsdaten nicht ins Repo schreiben.

