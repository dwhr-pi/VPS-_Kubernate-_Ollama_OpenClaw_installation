# Hoerbuch, Dubbing, SFX, MIDI und Video-Editing

Quellenpruefung: 14.10.2026, ViDubb-Quellpfad ergaenzt am 16.10.2026.
Mit Ausnahme der [ViDubb-Quellinstallation](../tools/vidubb.md) und der
[Alexandria-Quell-/venv-Vorbereitung](../tools/alexandria-audiobook.md) sowie dem
[Qwen3-TTS-Paketinstaller](../tools/qwen3-tts.md) und
[ChatTTS-Paketinstaller](../tools/chattts.md) und dem
[AudioLDM2-Basispaket](../tools/audioldm2.md) und dem
[AudioGen-/AudioCraft-Basispaket](../tools/audiogen.md) sowie dem
[Stable-Audio-Open-Basispaket](../tools/stable-audio-open.md) und dem
[Moshi-Basispaket](../tools/moshi.md) und den
[Just-Dub-It-Basispaketen](../tools/just-dub-it.md) sowie der
[VOID-Quellinstallation](../tools/void-model.md) und dem
[Kiwi-Edit-Basispaket](../tools/kiwi-edit.md) sowie der
[ProPainter-Quellinstallation](../tools/propainter.md) und der
[AIDA-X-Quellinstallation mit optionalem Build](../tools/aida-x.md) sowie der
[Sfizz-Engine mit optionalem Renderer-Build](../tools/sfizz.md) und dem
[Basic-Pitch-GitHub-Paket](../tools/basic-pitch.md) und dem
[Aegisub-Quellinstaller mit optionalem Meson-Build](../tools/aegisub.md) sowie dem
[WhisperX-GitHub-Paket](../tools/whisperx.md) und dem
[ACE-Step-1.5-GitHub-Basispaket](../tools/ace-step-15.md) und der
[YuE-v1-Quellinstallation](../tools/yue.md) sind die neuen
Kandidaten **planned/documentation-first**, nicht installiert oder als Kombination getestet. Gemeinsame Guard-Skripte
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

ViDubb besitzt jetzt einen eigenen gepinnten Sparse-Quellinstaller ohne Docker,
aber noch keine sichere Dubbing-Laufzeit. Alexandria hat einen eigenen
Quell-/venv-Installer ohne Docker, noch keine betriebsbereite GPU-Laufzeit.
Qwen3-TTS, ChatTTS, AudioLDM2, AudioGen, Stable Audio Open, Moshi und Just Dub It haben ebenfalls
eigene Paketinstaller, aber keine damit automatisch betriebsbereite Inferenz.
VOID hat einen eigenen gepinnten Sparse-Quellinstaller ohne Pakete/Modelle.
ProPainter ebenso, mit S-Lab-Lizenzbestaetigung fuer nichtkommerzielle Nutzung.
AIDA-X bereitet gepinnte GitHub-Quellen vor und bietet einen optionalen nativen Standalone-Build.
Kiwi Edit installiert das GitHub-Basispaket diffsynth ohne Runtime/Modelle.
Die weiterhin als planned markierten Kandidaten haben noch
keine echten toolbezogenen Installer, Smoke-Tests,
Update-/Rollback- oder Deinstallationspfade. Die Guard-Dateien sind bewusst
kein Ersatz dafuer. Erst nach Release-/Lizenz-/Hardwarepruefung implementieren.

| Registry-ID / Name | GitHub-Quelle | Aufgabe / Grenze | Ressourcenklasse | Status / Risiko |
|---|---|---|---|---|
| `alexandria_audiobook` (Alexandria_Audiobook) | [Finrandojin/alexandria-audiobook](https://github.com/Finrandojin/alexandria-audiobook), [Installer](../tools/alexandria-audiobook.md) | GitHub-Quellen + private venv ohne Docker; TTS-/GPU-Laufzeit separat. | gpu-heavy | experimental / high |
| `qwen3_tts` (Qwen3_TTS) | [QwenLM/Qwen3-TTS](https://github.com/QwenLM/Qwen3-TTS), [Installer](../tools/qwen3-tts.md) | GitHub-Paket ohne Runtime als Standard, Runtime doppelt opt-in; keine Modelle/Inferenz. | gpu-heavy | experimental / high |
| `chattts` (ChatTTS) | [2noise/ChatTTS](https://github.com/2noise/ChatTTS), [Installer](../tools/chattts.md) | GitHub-Paket ohne Runtime als Standard; Core-Runtime doppelt opt-in, kein Modell. Modell nichtkommerziell. | medium | experimental / high |
| `audioldm2` (AudioLDM2) | [haoheliu/AudioLDM2](https://github.com/haoheliu/AudioLDM2), [Installer](../tools/audioldm2.md) | GitHub-Paket --no-deps ohne Docker; Legacy-Runtime/Modelle fehlen, Lizenzwiderspruch. | gpu-heavy | experimental / high |
| `audiogen` (AudioGen) | [facebookresearch/audiocraft](https://github.com/facebookresearch/audiocraft) | [GitHub-Basispaket](../tools/audiogen.md), ohne Runtime/Modelle; Gewichte CC-BY-NC 4.0. | gpu-heavy | experimental / high |
| `stable_audio_open` (Stable_Audio_Open) | [Stability-AI/stable-audio-tools](https://github.com/Stability-AI/stable-audio-tools), [Installer](../tools/stable-audio-open.md) | GitHub-Basispaket 0.0.20, Python 3.10; ohne Docker, GPU-Runtime/Modelle. | gpu-heavy | experimental / high |
| `moshi` (Moshi) | [kyutai-labs/moshi](https://github.com/kyutai-labs/moshi), [Installer](../tools/moshi.md) | GitHub-Python-Basispaket 0.2.13; ohne Docker/Modelle/Server/Mikrofonzugriff. | gpu-heavy | experimental / high |
| `moss_tts` (MOSS_TTS) | [OpenMOSS/MOSS-TTS](https://github.com/OpenMOSS/MOSS-TTS) | [GitHub-Checkout + Basis-Metadatenpaket](../tools/moss-tts.md), keine fertige TTS-Laufzeit. | gpu-heavy | experimental / high |
| `yue` (YuE) | [multimodal-art-projection/YuE](https://github.com/multimodal-art-projection/YuE) | Gepinnte YuE-v1-Quellen ohne Docker; Runtime/Modelle separat, kein YuE2-Wechsel. | gpu-heavy | experimental / high |
| `ace_step_15` (ACE_Step_15) | [ace-step/ACE-Step-1.5](https://github.com/ace-step/ACE-Step-1.5) | Gepinntes GitHub-Basispaket ohne Docker; Runtime/Modelle separat. | gpu-heavy | experimental / high |
| `whisperx` (WhisperX) | [m-bain/whisperX](https://github.com/m-bain/whisperX) | Eigenes GitHub-Basispaket; Runtime separat opt-in, keine automatische Transkription. | heavy | experimental / high |
| `aegisub` (Aegisub) | [TypesettingTools/Aegisub](https://github.com/TypesettingTools/Aegisub) | Gepinnte GitHub-Quellen; optionaler privater Meson-Build ohne Docker. | medium | experimental / high |
| `basic_pitch` (Basic_Pitch) | [spotify/basic-pitch](https://github.com/spotify/basic-pitch) | Audio-zu-MIDI; eigenes GitHub-Basispaket, optionale Runtime, ohne Docker. | medium | experimental / high |
| `sfizz` (Sfizz) | [sfztools/sfizz](https://github.com/sfztools/sfizz) | Gepinnte Engine-Quellen; optional sfizz_render ohne Docker, keine DAW-Plugins. | medium | experimental / archiviert / high |
| `aida_x` (AIDA_X) | [AidaDSP/AIDA-X](https://github.com/AidaDSP/AIDA-X), [Installer](../tools/aida-x.md) | GitHub-Quelle 1.1.0, Standalone-Build optional ohne Docker; kein Audio-/DAW-Start. | medium | experimental / high |
| `propainter` (ProPainter) | [sczhou/ProPainter](https://github.com/sczhou/ProPainter), [Installer](../tools/propainter.md) | GitHub-Sparse-Quellinstallation ohne Docker/Pakete/Modelle. S-Lab-Lizenz nichtkommerziell. | gpu-heavy | experimental / high |
| `kiwi_edit` (Kiwi_Edit) | [showlab/Kiwi-Edit](https://github.com/showlab/Kiwi-Edit), [Installer](../tools/kiwi-edit.md) | GitHub-Basispaket diffsynth 2.0.4 ohne Docker/Runtime/Modelle. Remote-Code-/Lizenzgrenzen beachten. | gpu-heavy | experimental / high |
| `void_model` (VOID_Model) | [Netflix/void-model](https://github.com/Netflix/void-model), [Installer](../tools/void-model.md) | GitHub-Sparse-Quellinstallation ohne Docker/Pakete/Modelle. Notebook 40 GB+ VRAM, Maskenpipeline teils Gemini. | gpu-heavy | experimental / high |
| `just_dub_it` (Just_Dub_It) | [justdubit/just-dub-it](https://github.com/justdubit/just-dub-it), [Installer](../tools/just-dub-it.md) | Archiviert; GitHub-Basispakete ohne Docker/Runtime/Modelle, Lizenz-Opt-in. | gpu-heavy | experimental / high |
| `vidubb` (ViDubb) | [medahmedkrichen/ViDubb](https://github.com/medahmedkrichen/ViDubb), [Quellinstaller](../tools/vidubb.md) | Gepinnter Sparse-Quellcheckout ohne Docker; Dubbing-Laufzeit wegen Legacy-/Import-/Loeschrisiken noch NICHT betriebsbereit. | heavy fuer spaetere Laufzeit | experimental/source-only / high |

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
