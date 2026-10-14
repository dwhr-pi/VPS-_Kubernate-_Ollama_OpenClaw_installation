# Hoerbuch, Dubbing, SFX, MIDI und Video-Editing

Quellenpruefung: 14.10.2026. Neue Kandidaten sind **planned/documentation-first**,
nicht installiert oder als Kombination getestet. Gemeinsame Guard-Skripte
verhindern Downloads, Builds, Starts und Loeschungen. Keine neuen Ports.
Code, Gewichte, Trainingsdaten und Plugin-SDKs haben unterschiedliche Lizenzen.
Eine GitHub-Quelle allein ist keine Freigabe fuer kommerzielle Produktion.

## Neue optionale Kandidaten

### Validierung und verbleibende Installationsarbeit

18 synthetische Offline-Tests pruefen Konvertierung, Ausgabegrenzen,
Registry/Dokumentationslinks und nicht-installierende Guards. Bash-Syntax,
Config-, Tool- und Portchecks wurden ausgefuehrt; keine Modell-/GPU-Tests.
ShellCheck war nicht verfuegbar. Die globale Profilpruefung meldet eine
bereits unabhaengig fehlende Datei: `docs/Profile/Embedded_Debug_HIL.md`.

Die Kandidaten haben noch keine echten toolbezogenen Installer, Smoke-Tests,
Update-/Rollback- oder Deinstallationspfade. Die Guard-Dateien sind bewusst
kein Ersatz dafuer. Erst nach Release-/Lizenz-/Hardwarepruefung implementieren.

| Registry-ID / Name | GitHub-Quelle | Aufgabe / Grenze | Ressourcenklasse | Status / Risiko |
|---|---|---|---|---|
| `alexandria_audiobook` (Alexandria_Audiobook) | [Finrandojin/alexandria-audiobook](https://github.com/Finrandojin/alexandria-audiobook) | Mehrstimmige Hoerbuecher auf Qwen3-TTS; MP3/M4B laut Upstream. | gpu-heavy | planned / high |
| `qwen3_tts` (Qwen3_TTS) | [QwenLM/Qwen3-TTS](https://github.com/QwenLM/Qwen3-TTS) | TTS, Voice Design und autorisiertes Voice Cloning; keine ASR. | gpu-heavy | planned / high |
| `chattts` (ChatTTS) | [2noise/ChatTTS](https://github.com/2noise/ChatTTS) | Dialog-TTS, primaer Chinesisch/Englisch; Modelllizenz nichtkommerziell. | medium | planned / high |
| `audioldm2` (AudioLDM2) | [haoheliu/AudioLDM2](https://github.com/haoheliu/AudioLDM2) | Text-to-Audio/SFX; keine beliebige Dauer oder perfekten Loops garantiert. | gpu-heavy | planned / high |
| `audiogen` (AudioGen) | [facebookresearch/audiocraft](https://github.com/facebookresearch/audiocraft) | AudioCraft-SFX-Modell; Gewichte CC-BY-NC 4.0. | gpu-heavy | planned / high |
| `stable_audio_open` (Stable_Audio_Open) | [Stability-AI/stable-audio-tools](https://github.com/Stability-AI/stable-audio-tools) | Text-to-Audio; konkrete Gewichte und deren Lizenz getrennt pruefen. | gpu-heavy | planned / high |
| `moshi` (Moshi) | [kyutai-labs/moshi](https://github.com/kyutai-labs/moshi) | Full-duplex Sprachdialog; kein Hoerbuch-/Musik-Allrounder. | gpu-heavy | planned / high |
| `moss_tts` (MOSS_TTS) | [OpenMOSS/MOSS-TTS](https://github.com/OpenMOSS/MOSS-TTS) | TTS-/Sound-Familie; Faehigkeiten pro Modellvariante pruefen. | gpu-heavy | planned / high |
| `yue` (YuE) | [multimodal-art-projection/YuE](https://github.com/multimodal-art-projection/YuE) | Musik/Gesang; Upstream-Generation YuE/YuE2 genau pinnen. | gpu-heavy | planned / high |
| `ace_step_15` (ACE_Step_15) | [ace-step/ACE-Step-1.5](https://github.com/ace-step/ACE-Step-1.5) | Musikgenerierung; Hardware-/Modellpfad separat testen. | gpu-heavy | planned / high |
| `whisperx` (WhisperX) | [m-bain/whisperX](https://github.com/m-bain/whisperX) | ASR, Alignment und optionale Diarisierung; Gesang manuell nachkorrigieren. | heavy | planned / high |
| `aegisub` (Aegisub) | [TypesettingTools/Aegisub](https://github.com/TypesettingTools/Aegisub) | ASS-Untertitel und Karaoke-Timing im Editor. | light | planned / high |
| `basic_pitch` (Basic_Pitch) | [spotify/basic-pitch](https://github.com/spotify/basic-pitch) | Audio-zu-MIDI; keine perfekte Mehrinstrument-Transkription. | medium | planned / high |
| `sfizz` (Sfizz) | [sfztools/sfizz](https://github.com/sfztools/sfizz) | SFZ-Sampler-Laufzeit; Samples sind keine MIDI-Dateien. | light | planned / high |
| `aida_x` (AIDA_X) | [AidaDSP/AIDA-X](https://github.com/AidaDSP/AIDA-X) | Amp-Modell-Player; Capture/Training ist separater Workflow. | medium | planned / high |
| `propainter` (ProPainter) | [sczhou/ProPainter](https://github.com/sczhou/ProPainter) | Maskenbasiertes Video-Inpainting; kein fehlerfreier Universal-Editor. | gpu-heavy | planned / high |
| `kiwi_edit` (Kiwi_Edit) | [showlab/Kiwi-Edit](https://github.com/showlab/Kiwi-Edit) | Anweisungs-/Referenz-basiertes Video-Editing; Forschungspfad. | gpu-heavy | planned / high |
| `void_model` (VOID_Model) | [Netflix/void-model](https://github.com/Netflix/void-model) | Interaktionsbewusstes Entfernen; externe Modell-/API-Abhaengigkeiten pruefen. | gpu-heavy | planned / high |
| `just_dub_it` (Just_Dub_It) | [justdubit/just-dub-it](https://github.com/justdubit/just-dub-it) | Audio-visuelle Dubbing-Forschung; keine beliebige LTX/Wan-Kompatibilitaet annehmen. | gpu-heavy | planned / high |
| `vidubb` (ViDubb) | [medahmedkrichen/ViDubb](https://github.com/medahmedkrichen/ViDubb) | Dubbing-Projekt; Provider, Lip-Sync und lokale Betriebsfaehigkeit noch auditieren. | heavy | planned / high |

Alle Eintraege haben Registry-, Menue-, Quellen- und Doku-Verknuepfungen.
Die gemeinsamen Install/Update/Uninstall-Guards liefern Exit-Code 2 statt
eine nicht erfolgte Installation als erfolgreich zu markieren. Check/Doctor
zeigen nur den Registrierungsstatus, keinen Modelltest. Beispiel:

```bash
bash scripts/tools/media_candidate_install.sh --dry-run
```

Die gemeinsame Guard-Datei waehlt kein Modell aus; die Tool-Auswahl erfolgt
im Menue. Kein SDK, Checkpoint oder Cloud-Provider wird dabei eingerichtet.

## Vorhandene Bausteine wiederverwenden

Piper, Coqui/XTTS, Faster-Whisper, Whisper.cpp, FFmpeg, Demucs, UVR5,
Subtitle Edit und ComfyUI sind bereits vorhanden bzw. registriert. Bestehende
Installer sind dadurch nicht erneut getestet und starten teils Abhaengigkeits-
oder Modelldownloads. Nicht ungeprueft mit --dry-run ausfuehren.

Piper eignet sich als einfacher lokaler TTS-Pfad; XTTS ist ein Modellpfad
innerhalb der Coqui-Welt, kein separater magischer Hoerbuchgenerator.
Stimmrechte, konkrete Gewichte und deren Lizenzen bleiben zu pruefen.
Suno ist eine Musikplattform, nicht die erste Wahl fuer kontrollierte
Langform-Narration, erzwungene Zeitstempel oder verlustfreie Untertitelarbeit.

## Lizenz- und Faehigkeitskorrekturen

- ChatTTS dokumentiert vor allem Englisch/Chinesisch; kein zugesicherter deutscher
  Hoerbuchstandard. Code AGPLv3+, veroeffentlichtes Modell CC BY-NC 4.0.
- AudioCraft-Code ist MIT, Modellgewichte laut Upstream CC BY-NC 4.0.
  Das gilt nicht automatisch als kommerzielle Freigabe fuer AudioGen/MusicGen.
- Stable Audio Tools ist Code, Stable Audio Open ein gesonderter Modellpfad.
  Modellkarte/aktuellen Lizenztext vor Nutzung akzeptieren und pruefen.
- ASR, TTS, Speech-to-Speech, Musik- und SFX-Generierung sind verschiedene Aufgaben.
  Qwen3-TTS ist kein allgemeiner Musiktranskribierer; Moshi kein Musikmastering-Tool.
- AudioLDM2-Varianten/Dauer/Samplerate checkpointbezogen pruefen; kein beliebig
  langer nahtloser Loop garantiert. Loops brauchen Schnitt und Crossfade.
- ProPainter/VOID/Kiwi-Edit liefern keine garantierte Physik oder perfekte
  Identitaets-/Hintergrundkonsistenz. Lizenz und externe Abhaengigkeiten auditieren.

Die obigen Aussagen sind auf den verlinkten Upstream-Seiten nachzulesen,
keine Ergebnisse eigener Modelltests.

## RAM, VRAM und Speicher realistisch planen

| Bereich | Belastbare Einordnung |
|---|---|
| Formatkonverter/Untertiteleditor | Keine Modell-GPU erforderlich; Mediendateien und Rendering separat dimensionieren |
| Alexandria | Upstream nennt 8 GB VRAM fuer ein Modell/kleine Batches, 16 GB komfortabler und 24 GB+ fuer groessere Batches; keine eigene Messung |
| Moshi PyTorch | Upstream nennt derzeit 24 GB und keine Quantisierung dieses Backends; andere Backends/Varianten getrennt pruefen |
| Qwen3-TTS/MOSS/SFX | Checkpoint, Praezision, Kontext, Dauer, Batch und Offload bestimmen den Bedarf; keine pauschale Zusage 4-6 GB |
| YuE/ACE-Step/Dubbing/Video-Inpainting | GPU-heavy: Pipeline und Cliplaenge konkret messen, keine Zusage fuer 16 GB |
| Gesamtsystem | RAM/Swap, freie echte SSD inkl. Modellcache, Temp-/Stems-/Videoexport und freier VRAM pruefen; ein Job als Startpunkt |

Mehrere GPUs ergeben keinen automatischen gemeinsamen VRAM-Pool. Eine RTX 5080
und Tesla P40 unterscheiden sich in Architektur und Softwareunterstuetzung;
Treiber/PyTorch/Attention-Backends pruefen. Fuer die hier genannten Kandidaten
wird keine vorhandene Hardware automatisch als kompatibel eingestuft.
Kein Performanceversprechen wie perfekt, fehlerfrei oder Echtzeit ohne Messung.

## Noch nicht eindeutig aufgenommen

LeVo 2, A2M, Creative MIDI Companion, QIE-Object-Remover-Bbox, Audio Plugin Coder,
karaok-AI und Lyrica brauchen eine eindeutig zugeordnete Upstream-URL,
Lizenz- und Reifepruefung. Namen allein genuegen nicht; keine geratenen
Repository-Links oder angeblich fertigen Installer. Magenta/MIDI-Werkzeuge,
JUCE und Plugin-Builds sind separate Ausbaupfade, nicht automatisch installiert.

## Anleitungen

- [Hoerbuecher, Synchronisation, SFX und Video-Editing](AUDIO_DUBBING_PRODUCTION_GUIDE.md)
- [MIDI, Sampler und Plugin-Grenzen](MIDI_SAMPLING_GUIDE.md)
- [Karaoke, SRT/LRC/ASS und Player](KARAOKE_SUBTITLES_GUIDE.md)
