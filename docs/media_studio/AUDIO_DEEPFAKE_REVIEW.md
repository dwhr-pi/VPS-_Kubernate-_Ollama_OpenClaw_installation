# Audio-Deepfakes: pruefen, isolieren und sicher bearbeiten

Quellenstand: 14.10.2026. **Kein universeller Deepfake-Entferner.**
Eine synthetische Stimme ist ein Audiosignal, kein rueckgaengig zu machender
Filter. Aus einer geklonten Aufnahme laesst sich die urspruengliche Stimme
ohne geeignete Originalquelle nicht verlaesslich rekonstruieren.
Klangverbesserung beweist weder Echtheit noch unveraenderten Inhalt.

Dieses Modul ist documentation-first: keine Installation, Modell-Downloads,
Telemetrie, Medienverarbeitung, Cloud-Aufrufe oder WSL-Eingriffe.

## 1. Welches Ziel hast du?

| Ziel | Geeigneter Ansatz | Wichtige Grenze |
|---|---|---|
| Aufnahme ist verdaechtig | Original sichern, Herkunft klaeren, fachliche Pruefung | Kein Spektrogramm oder einzelner Modellscore beweist allein einen Deepfake |
| Stimme soll aus Musik verschwinden | Demucs/UVR auf Arbeitskopie testen | Trennt nicht automatisch echte von geklonten Stimmen |
| Bestimmter Sprecher soll entfernt werden | Sprecher-Zeitbereiche pruefen, Abschnitte stummschalten/schneiden | Diarisierung trennt keine gleichzeitig sprechenden Personen |
| Exakte beigemischte Spur liegt vor | Kontrollierte Signalkomponenten-Subtraktion | Prompt, aehnliche Stimme oder Hintergrundspur reichen nicht |
| Autorisierte Aufnahme hat Rauschen | Vorsichtige Rauschminderung auf Kopie | Kann Sprache veraendern; keine Authentizitaetsreparatur |
| Eigene Herkunftsmarkierung pruefen | AudioSeal fuer dessen Wasserzeichen | Negativer Befund bedeutet nicht "echt" oder "nicht KI" |

Bei Betrugsverdacht: keinen Anweisungen der Aufnahme folgen, die betroffene
Person ueber einen bereits bekannten unabhaengigen Kanal kontaktieren.
Original nicht filtern/ueberschreiben. Fuer belastbare Entscheidungen
qualifizierte Audioforensik hinzuziehen, nicht nur einen LLM-Bericht.

## 2. Tools im Setup

| Werkzeug / Quelle | Stand | Nutzen und Grenze |
|---|---|---|
| [Audacity](https://github.com/audacity/audacity) | bereits optional registriert | Anhoeren, Spektrogramm, Schnitt/Mute, kontrollierte Signaladdition |
| [Demucs](https://github.com/facebookresearch/demucs) | bereits registriert | Musik-Stems; kein generischer Sprach-/Deepfake-Detektor |
| [UVR5](https://github.com/Anjok07/ultimatevocalremovergui) | bereits planned | Separation mit ausgewaehlten Modellen; Gewichte/Lizenzen einzeln pruefen |
| [RVC](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) | bereits planned | Autorisierte Voice Conversion, keine Rueckgewinnung einer echten Originalstimme |
| Pyannote_Audio / `pyannote_audio`: [pyannote/pyannote-audio](https://github.com/pyannote/pyannote-audio) | experimental, eigener [GitHub-Installer](../tools/pyannote-audio.md) | Quellen und optionale private CPU-Pakete; keine Modelle/Audioaktionen oder Echtheits-/Identitaetsgarantie |
| DeepFilterNet / `deepfilternet`: [Rikorose/DeepFilterNet](https://github.com/Rikorose/DeepFilterNet) | experimental, [GitHub-Rust-Build](../tools/deepfilternet.md) | CPU-CLI, eingebettetes Modell; keine universelle Trennung konkurrierender Sprecher |
| AudioSeal / `audioseal`: [facebookresearch/audioseal](https://github.com/facebookresearch/audioseal) | experimental, [GitHub-CPU-Paketinstaller](../tools/audioseal.md) | Keine Modelle/Audioaktionen beim Installieren; kein universeller Deepfake-Detektor |

Code, Gewichte und Rechte am Eingangsmaterial getrennt pruefen.
BS-Roformer bezeichnet eine Modellfamilie; ein Dateiname allein belegt
weder kompatible UVR-Unterstuetzung noch eine kommerzielle Lizenz.
Reaper/iZotope RX sind proprietaere Alternativen, keine neuen
Open-Source-GitHub-Installer dieses Setups. SciPy/NumPy sind Rechenbibliotheken,
keine Echtheitsdetektoren.

Demucs: Meta-Repo ist archiviert und verweist auf den Autoren-Fork
`adefossez/demucs` mit eingeschraenkter Pflege. Keine automatische Migration
oder Behauptung eines aktuell voll gepflegten Meta-Produkts.
Die vorhandenen Installer wurden hier nicht ausgefuehrt oder umgebaut.

pyannote: Bibliothekscode MIT; Modellbedingungen, Gating, optionales
Telemetrieverhalten und lokale Pipeline separat pruefen.
Nicht versehentlich einen gehosteten Premium-Pfad statt lokaler Inferenz
waehlen; HF-Token nur falls erforderlich, read-only und ausserhalb Git.
AudioSeal dokumentiert MIT fuer Code/Gewichte; konkrete Revision pruefen.
Andere Wasserzeichen-/Detektorsysteme werden damit nicht allgemein erfasst.

AudioSeal hat einen eigenen GitHub-Paketinstaller mit privater CPU-venv.
DeepFilterNet hat einen eigenen GitHub-Rust-Installer ohne Docker; Pyannote_Audio
einen eigenen Source-/CPU-Installer. Details und Grenzen siehe die Tool-Anleitungen.
Keines der Tools oeffnet automatisch Ports.

```bash
bash scripts/tools/audio_review_candidate_install.sh --dry-run
bash scripts/tools/audio_review_candidate_doctor.sh
```

Der alte gemeinsame Guard bleibt fuer Legacy-Aufrufe nicht-installierend,
ist aber keinem dieser drei Tools mehr im Menue zugeordnet. Er meldet nur
Registrierungsstatus, keinen Audiobefund; Aktionen liefern dort Exit-Code 2.
AudioSeal prueft Paketmetadaten ohne Modellimport; Modellpins und Audio-Smoke-
Tests bleiben offen. Sein Checkpoint-Loader kann Pickle-Code ausfuehren: nur
vertrauenswuerdige Gewichte verwenden. DeepFilterNet hat Build-/Hashchecks,
aber noch keinen bestaetigten Audio-Ende-zu-Ende-Test. Pyannote hat eigene Source-/CPU-
Checks, aber noch keinen bestaetigten Decoder-/Modell-/Diarisierungstest.

## 3. Einsteigerablauf: Original zuerst schuetzen

1. Herkunft und Berechtigung klaeren. Keine vertraulichen Anrufe fremden
   Web-Detektoren hochladen; Stimmen koennen sensible personenbezogene Daten sein.
2. Unveraendertes Original privat sichern. Hash, Empfangszeit, Quelle und
   Uebertragungsweg dokumentieren; SHA-256 prueft Dateigleichheit, nicht Echtheit.
3. Arbeitskopie anlegen. Keine Originale, Stimmproben, Transkripte oder
   persoenlichen Fallberichte ins Git-Repository.
4. Zunaechst ohne Filter anhoeren, Kanalzahl/Samplerate/Codec erfassen und
   verdaechtige Zeitbereiche notieren. Nicht vorschnell "KI" beschriften.
5. Original vor jeder Verarbeitung getrennt fuer Analyse erhalten.
6. Nur fuer klar definierten Zweck eine Arbeitskopie bearbeiten.
7. Ergebnis gegenhoeren, verbleibende Stimme/Verstaendlichkeit pruefen;
   keine garantierte Anonymisierung oder vollstaendige Entfernung behaupten.
8. Abgeleitete Datei und veraenderte Zeitbereiche kennzeichnen.
   Bei Weitergabe manuell freigeben; keine automatische Publikation.

Hash manuell auf dem passenden Host berechnen, keine Installation noetig:

```powershell
Get-FileHash -Algorithm SHA256 -LiteralPath 'C:\PRIVATER_FALLORDNER\original.wav'
```

```bash
sha256sum -- /ABSOLUTER_PRIVATER_FALLORDNER/original.wav
```

Platzhalter durch eigenen privaten Pfad ersetzen. Ein Hash belegt weder
Aufnahmezeit noch Identitaet und ersetzt keine dokumentierte Beweismittelkette.

## 4. Stimme aus einer Mischspur entfernen

### Gesang/Sprache mit Musik

Demucs/UVR kann einen brauchbaren Hintergrund liefern, aber auch echte
Stimmen entfernen, Instrumente beschaedigen und Sprachreste behalten.
Demucs `--two-stems=vocals` erzeugt typischerweise `vocals.wav` und
`no_vocals.wav` im modell-/trackbezogenen Ausgabeordner.
Der Dateiname `no_vocals.wav` ist keine Garantie fuer Sprachfreiheit.

Erst nach separater Installation/Modellfreigabe und Ressourcenpruefung eine
kurze autorisierte Arbeitskopie testen. Erster Modellaufruf kann Gewichte
herunterladen; keinen vermeintlich offline sicheren Erststart annehmen.
Hier absichtlich kein ungepinnter `pip install demucs`-Einzeiler.

### Bestimmter Sprecher

Diarisierung liefert vermutete Sprechergruppen und Zeiten, keine
verlaessliche persoenliche Identitaet. Zeiten manuell kontrollieren.
In Audacity auf der Arbeitskopie betreffende Bereiche markieren und
stummschalten oder schneiden; Schnitt veraendert die Zeitachse.
Bei Ueberlappung wird dadurch auch andere Sprache oder Hintergrund entfernt.
Gezielte Sprecherseparation ist ein weiterer Modellpfad, nicht automatisch
Teil von pyannote oder Demucs. Verbleibende verstaendliche Worte pruefen.

## 5. Signalausloeschung: was wirklich funktioniert

Bei idealer additiver Mischung `m = b + s` ergibt `m - s = b`.
Dafuer muss `s` die **exakte enthaltene Stoerkomponente** sein: gleiche
Samples, Kanalzuordnung, Zeitlage, Pegel und Verarbeitung.
Audacity "Invert" kehrt das Vorzeichen um; das ist eine Polaritaetsinvertierung.
[Offizielle Invert-Erklaerung](https://manual.audacityteam.org/man/invert.html).

Nur eine Hintergrundreferenz `b` vorhanden? Dann liefert `m - b = s`
gerade die Stimme, nicht den Hintergrund. Ein Prompt, Seed, aehnlicher
Stimmklon oder neu synthetisierte Aufnahme ist keine exakte Referenz.
Codec, Hall, Kompression/Limiting, Pegelbewegungen und zeitliche Abweichungen
lassen Reste entstehen. Keine automatische Ausrichtung/Subtraktion hier implementiert.
Nur auf Kopien vergleichen; Nulltest-Erfolg sagt nichts ueber den Sprecher aus.

## 6. Klangbereinigung ist keine Deepfake-Entfernung

Hochfrequenzgrenzen, Stille, Metallklang und Spektrogramm-Kanten koennen
auch von Telefoncodecs, Mikrofonen, Schnitt oder Kompression stammen.
Weder eine 8-kHz-Kante noch glatte Frequenzuebergaenge beweisen einen Deepfake
oder dessen erfolgreiche Entfernung.

Keine pauschale Low-Pass-Empfehlung bei 12-14 kHz: Filter koennen Sprachdetails
und Analysematerial entfernen. Rauschminderung nur zweckgebunden, zurueckhaltend,
reproduzierbar dokumentiert und auf freigegebener Arbeitskopie.
DeepFilterNet nicht als Echtheits-Reparatur ausgeben.

RVC/Re-Synthese erzeugt ein neues synthetisches Signal; sie entfernt keinen
urspruenglichen Betrug und stellt keine echte Stimme wieder her.
Diese Erweiterung enthaelt keine Anleitung, durch Raumton, Filter oder
Voice Conversion Detektoren zu umgehen, Wasserzeichen zu entfernen oder
synthetische Herkunft zu verschleiern. Legitime kreative Bearbeitung
bleibt getrennt, autorisiert und klar gekennzeichnet.

## 7. Erkennung nur mit begrenzten Aussagen

AudioSeal erkennt seine eigenen Markierungen, nicht jede KI-Stimme.
Ein vorhandenes Wasserzeichen ist ein systemspezifischer Hinweis;
sein Fehlen oder ein niedriger Score beweist keine menschliche Aufnahme.
[ASVspoof 5](https://github.com/asvspoof-challenge/asvspoof5) ist eine
Forschungs-/Evaluationsreferenz, kein automatisch freigegebener Produktivdetektor.
Detektoren brauchen Modell-/Datenversionsnachweis, passende Evaluation und
Fehlalarmpruefung; unbekannte Generatoren/Codecs koennen Ergebnisse veraendern.
Keine erfundene Prozent-Sicherheit und keine autonome Personenbeschuldigung.

## 8. Python-/OpenClaw-/n8n-Pipeline als Plan

[Defensiver Workflowvertrag](../workflows/media/Audio_Review_And_Redaction.md):
Original sichern -> Inventar/Hash -> menschliche Zweckfreigabe ->
optionale Analyse -> freigegebene Arbeitskopie/Redaktion -> manuelle Abnahme.

Ein spaeterer Python-Adapter braucht feste strukturierte Eingaben,
neues privates Ausgabeziel, versionsgepinnte Tools, Hash/Transformationsjournal,
Timeout, Groessenlimits und einen seriellen Queue-Auftrag.
Keine beliebigen Shellstrings aus Transkripten, keine Originalueberschreibung.
Noch kein ausfuehrbarer Python-/OpenClaw-/n8n-Adapter enthalten.
LLM darf einen Bericht strukturieren, aber nicht eigenstaendig "echt/falsch"
entscheiden, Klonstimmen erzeugen oder sensible Aufnahmen an APIs senden.

Ressourcen: zuerst kurze Kopie, CPU/RAM/Swap und echte freie SSD messen;
Input + Stems + Tempdateien + Modellcache + Reserve einplanen.
WAV kann viel groesser als komprimierter Eingang sein. Unter WSL zusaetzlich
freien Windows-Datentraeger der VHDX pruefen. MiniPC/RPi/VPS eher Planung/
leichte Analyse; GPU nur fuer separat getesteten Modellpfad, K3s optional.
Keine ungemessene RAM-/VRAM-Mindestgarantie oder automatische GPU-Installation.
