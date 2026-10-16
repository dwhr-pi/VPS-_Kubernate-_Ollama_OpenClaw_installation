# Hoerbuecher, Synchronisation, Soundeffekte und Bildbearbeitung

Diese Anleitung ergaenzt das bestehende Setup, keinen neuen Worktree und keine
zweite Installation. Sie startet weder WSL noch Docker, Kubernetes, Modelle
oder externe APIs. [Tool-Katalog und Quellen](AUDIO_VIDEO_TOOL_CATALOG.md).

## Hoerbuch: Sprache ist nicht Musik

Fuer einen gesprochenen langen Text brauchst du TTS, Kapitelverwaltung und
Qualitaetskontrolle, nicht primaer Suno oder einen Songgenerator.
Minimal: vorhandener Piper-Pfad mit kurzen Textabschnitten, Probehören und
anschliessender Montage. Fuer mehrere Rollen ist Alexandria/Qwen3-TTS ein
passender **geplanter** Ausbaukandidat, kein bereits getesteter Installer.
Alexandria dokumentiert LLM-Skriptannotation, Stimmenzuordnung, abschnittsweise
Neugenerierung und MP3/M4B-Export. Ein lokaler Ollama-Endpunkt kann der
Textannotation dienen; die eigentliche Sprache entsteht im TTS-Modell.

1. Eigenen/freigegebenen Text in Kapitel und Sprecherabschnitte zerlegen.
2. Rollen/Stimmen mit Einwilligungsnachweis fest zuordnen, nicht pro Satz wechseln.
3. Erst kurze synthetische Szene testen: Deutsch, Namen, Zahlen und Aussprache.
4. Abschnitte seriell erzeugen, nach Fehlern nur betroffene Abschnitte ersetzen.
5. Lautheit/Pausen pruefen, Kapitelgrenzen setzen, Master-WAV behalten.
6. MP3 oder M4B mit Kapitelmetadaten exportieren und komplett gegenhoeren.

Stundenlanger fehlerfreier Vortrag ist kein zugesicherter Ein-Klick-Effekt.
Voice-Cloning nur mit eigenen oder ausdruecklich autorisierten Stimmen;
Stimmreferenzen sind vertrauliche Daten, keine oeffentlichen Repo-Beispiele.
ChatTTS nicht ungeprueft als deutsche/kommerzielle Hoerbuchloesung einsetzen.

## Film synchronisieren: mehrere getrennte Aufgaben

```mermaid
flowchart LR
  A[Freigegebener kurzer Clip] --> B[Audio extrahieren / Sprache erkennen]
  B --> C[Sprecher und Zeiten pruefen]
  C --> D[Uebersetzen / Dialog anpassen]
  D --> E[Autorisierte TTS-Stimmen]
  E --> F[Timing und Originalatmosphaere mischen]
  F --> G[Optional Lip-Sync / manuelles Review]
```

Faster-Whisper/WhisperX sind fuer Transkription/Alignment interessant,
Ollama fuer einen pruefbaren Uebersetzungsvorschlag. Diarisierung unterscheidet
Sprechersegmente, identifiziert aber keine Person zweifelsfrei. Manche Modelle
brauchen zusaetzliche akzeptierte Nutzungsbedingungen oder Tokens.
Whispers Uebersetzungsmodus ist nicht automatisch ein Deutsch-/Japanisch-
Uebersetzer; Sprachen und konkrete Pipeline getrennt auswaehlen.

[ViDubb](../tools/vidubb.md) hat einen GitHub-Quellinstaller ohne Docker,
aber noch keine sichere betriebsbereite Dubbing-Laufzeit. Just-Dub-It bleibt
Kandidat. Cloud-Provider, benoetigte Checkpoints,
Lip-Sync-Umfang und Modellgeneration vorab pruefen. Dubbing bedeutet nicht
automatisch Lip-Sync, und neue Dialoglaengen passen nicht immer zur Szene.
Wav2Lip/GFPGAN sind kein beliebig kombinierbares, garantiert lizenzfreies
Produktionspaket; Gesichtsrestaurierung kann die Identitaet veraendern.
Filmrechte, Darsteller-/Stimmrechte und Kennzeichnung vor Veroeffentlichung klaeren.

## Soundeffekte als eigene Spuren

AudioLDM2, AudioGen oder Stable Audio Open erzeugen SFX/Atmosphaeren aus Text.
Zunaechst kurze Ereignisse testen: Wind, Wellen, Motor im Leerlauf oder eine
rein filmische Effektszene. Master als WAV behalten, lautheitsangepasst und
mit Abstand zur Sprachspur mischen; Spitzenpegel/Clipping vermeiden.
Nicht jedes Modell erzeugt gleichzeitig hochwertige Musik, Sprache und SFX.

Ein langer Wind-Loop braucht haeufig Schnitt/Crossfade, nicht nur einen langen
Prompt. Keine universelle 48-kHz-/Dauerbehauptung fuer jede AudioLDM2-Variante.
Lautheitseinheiten, Zielplattform und Hoerprobe entscheiden ueber den Mix,
nicht ein pauschales Normalisierungsrezept. Generierte Impulsgeraeusche beim
ersten Abspielen leise abhoeren.

## Personen, Objekte oder Landschaften ersetzen/entfernen

Fotos: ComfyUI mit geeignetem Inpainting-Modell, selbst erstellter Maske und
einem freigegebenen Referenzbild. Erst Ausschnitt/Identitaet/Beleuchtung pruefen.
Videos brauchen zusaetzlich zeitlich konsistente Masken/Tracking; eine separat
generierte Reparatur pro Frame kann stark flackern.

ProPainter ist ein maskenbasierter Forschungsweg; Kiwi-Edit unterstuetzt
Anweisungs-/Referenz-Editing. VOID adressiert auch Interaktionen, garantiert
aber keine korrekten Schatten, Reflexionen oder verdeckten Objekte.
Vor lokalem Einsatz alle Hilfsmodelle und etwaige externe Analyse-APIs auditieren.
Ein eigenes Testvideo mit einem einfachen Objekt ist besser als gleich ein
langer Film. Keine fremden Personen taeuschend umdeuten oder Rechte-/Herkunfts-
kennzeichnungen entfernen. Unveraendertes Original getrennt aufbewahren.

## OpenClaw/n8n/K3s erst als kontrollierte Orchestrierung

Ziel: feste Task-Typen statt frei uebernommener Shellstrings, ein Job, genehmigte
Dateien, Timeout und begrenzte Retries. Der Agent darf weder beliebige Nodes
nachinstallieren noch den gesamten ENV-Tresor an eine Medienpipeline reichen.
Kein oeffentlicher Gradio-Link, keine offenen Modell-/Adminports.
Kubernetes ist optional, nicht Voraussetzung fuer lokale Audiobearbeitung.
Telegram-/Cloud-Uploads privater Stimmen oder Filme sind keine lokale Verarbeitung.

Hier sind **keine** produktiven n8n-JSON-Flows, MCP-/OpenClaw-Adapter oder K3s-
Deployments implementiert. Vorher pro Task einen echten lokalen Smoke-Test,
Ressourcenprofil und Audit-/Freigabevertrag bauen. Neue Kandidaten bleiben
planned. Bestehende Queue ist keine Sandbox und keine globale GPU-Speichergarantie.

## Installation und naechste Freigabe

Quellcode, Gewichte, LoRAs, Encoder und Codecs getrennt inventarisieren:
Version/Commit, Downloadgroesse, Hash, Lizenz, Datentraeger und kompatible
Python-/PyTorch-/GPU-Version. Modelldownloads koennen beim Erststart automatisch
ausgeloest werden. Das Setup tut dies fuer neue Kandidaten bewusst nicht.
Keine Audio-LLM-Installation in Ollama versprechen, wenn das Projekt einen
eigenen Python-/Codec-Stack verlangt.

Einstieg: vorhandene Basistools pruefen, synthetischen 10-20-Sekunden-Clip
waehlen, genau einen Kandidaten separat auditieren. Erst dann dessen
versionsgebundenen opt-in Installer und eigenen Doctor/Uninstaller implementieren.

[Karaoke und Untertitel](KARAOKE_SUBTITLES_GUIDE.md) sowie
[MIDI/Samples/Plugins](MIDI_SAMPLING_GUIDE.md) sind eigene Bearbeitungspfade.
