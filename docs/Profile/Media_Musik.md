# Profil: Media_Musik

## Überblick

Dieses Profil wurde aus der fachlichen Quelle [Media_Musik.doc.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Media_Musik.doc.md:1), `readme.md`, `docs/setup_guide.md` und `scripts/profiles/Media_Musik_install.sh` zusammengeführt.
Es beschreibt ein OpenClaw- und Ollama-kompatibles Kreativprofil für Musik, Audioanalyse, Prompt-Design, Remix-Workflows und Medienproduktion.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`, `python3`, `python3-pip`, `python3-venv`
- Bereits als einzelne Tools installierbar:
  - Clawbake unter `/opt/clawbake`
  - FFmpeg systemweit
  - librosa unter `/opt/librosa`
  - pydub unter `/opt/pydub`
  - Demucs unter `/opt/demucs`
  - Whisper unter `/opt/whisper`

## Dokumentierte zusätzliche Tools

Diese Bausteine sind in der Quelldatei enthalten, aber noch nicht vollständig als einzelne Installskripte umgesetzt:

- Suno / Udio API oder Wrapper
- MusicGen
- Riffusion
- Stable Diffusion
- ControlNet
- Music2P-style pipeline
- Hook detection
- BPM- und Energy-Classification
- TikTok probability score
- Emotion tagging

## Verantwortlichkeiten

- Musik- und Medien-Prompting
- Genre-, Mood- und Strukturdefinition
- Audioanalyse und Audio-Nachbearbeitung
- Remix- und Stem-Workflows
- Agentische Musikproduktion mit OpenClaw
- Viral- und Hook-orientierte Optimierung

## Verfügbare Kommandos

```bash
scripts/tools/clawbake_install.sh
scripts/tools/ffmpeg_install.sh
scripts/tools/librosa_install.sh
scripts/tools/pydub_install.sh
scripts/tools/demucs_install.sh
scripts/tools/whisper_install.sh
```

## Vollständige Prompt-Liste

### Structured Music Prompt

```txt
Genre:
Subgenre:
BPM:
Key:
Mood:
Energy Level:
Instruments:
Vocal Style:
Language:
Structure:
Drop Design:
FX / Sound Design:
Reference Vibe:
```

### Viral Hyperpop EDM

```txt
futuristic hyperpop, aggressive edm trap fusion, 128 bpm, f minor, glitch stutter vocals, distorted vocal chops, neon cyber aesthetic, female vocal energy, heavy sidechain bass, fast arpeggiated synths, build up tension, explosive drop, festival ready, tiktok viral hook, robotic adlibs
```

### Cyber Trap

```txt
dark cyber trap, 140 bpm, minimal but heavy 808s, metallic percussion, dystopian atmosphere, whisper rap vocals, synthetic textures, industrial bass design, glitch transitions, cinematic tension build, underground club vibe
```

### Pop EDM Viral Hook

```txt
bright edm pop, 124 bpm, uplifting chord progression, clean female vocals, catchy hook chorus, summer festival vibe, tropical synth layers, punchy kick, wide stereo mix, emotional drop, radio friendly structure
```

### K-Pop Hyper EDM

```txt
k-pop hyperpop edm trap fusion, 128 bpm, f minor, powerful female group vocals, rap + singing switch, fast cut transitions, glitch edits, cinematic intro, high energy pre chorus, explosive drop chorus, anime aesthetic, futuristic production, viral tiktok hook
```

### Emotional K-Pop Ballad Hybrid

```txt
emotional k-pop ballad with edm elements, 90 bpm, piano driven intro, soft female vocals, cinematic strings, build into electronic drop, emotional chorus, layered harmonies, dramatic storytelling
```

### Aggressive Trap Rap

```txt
dark trap beat, 140 bpm, heavy 808 bass, punchy snare, rap vocals with aggressive flow, minimal melody, cinematic dark atmosphere, street energy, repetitive hook phrase, club ready
```

### AI Glitch Rap

```txt
experimental glitch rap, fragmented vocal cuts, chopped syllables, hypercompressed drums, unpredictable rhythm, digital distortion, cyberpunk vibe, glitchcore aesthetic
```

### Trailer Music Hybrid EDM

```txt
cinematic trailer music, orchestral + edm fusion, rising tension, epic percussion, choir layers, massive drop, emotional intensity, heroic theme, hybrid orchestral synth design
```

### AI Ambient Tech Soundscape

```txt
ambient futuristic soundscape, slow evolving pads, minimal rhythm, deep sub drones, neural network inspired textures, calm but eerie, sci-fi atmosphere
```

### Prompt Modifiers

```txt
VIRAL: tiktok hook optimized
CLUB: DJ festival mix ready
CINEMATIC: trailer scoring style
LOFI: soft textures, warm noise
GLITCH: stutter edits, fragmented audio
ANIME: japanese pop aesthetic
DARK: minor key, dystopian tone
FUTURISTIC: AI generated aesthetic, cyber sound design
```

## Beispiel-Nutzung im OpenClaw-Setup

### Musik-Prompt für Agentenrouting

```txt
Nutze den Structured Music Prompt.
Genre: Hyperpop EDM
Subgenre: Festival Trap
BPM: 128
Key: F minor
Mood: futuristisch, aggressiv, viral
Energy Level: hoch
Instruments: distorted synths, sidechain bass, punchy kick
Vocal Style: female lead, glitch chops
Language: EN
Structure: intro, buildup, explosive drop, short hook, second drop
Drop Design: hard hitting, festival ready
FX / Sound Design: stutter, robotic adlibs, glitch cuts
Reference Vibe: cyber tiktok anthem
```

### Audio-Analyse

```txt
Nutze den Music Director Agent. Analysiere meinen Track nach BPM, Energie, Hook-Stärke
und möglicher Viralität. Gib mir konkrete Empfehlungen für Arrangement, Drop und Hook.
```

### Remix-Workflow

```txt
Nutze den Sound Designer Agent. Plane einen Workflow aus Stem-Separation, Audio-Cleanup,
Arrangement-Anpassung und finalem Export mit FFmpeg, Demucs und pydub.
```

## OpenClaw / Ollama Fit

- Dieses Profil passt gut zu OpenClaw als Workflow-Orchestrator für Musik- und Medienpipelines.
- Ollama eignet sich hier vor allem für Prompt-Refinement, Lyrics, Strukturplanung und Variantenbildung.
- `FFmpeg`, `librosa`, `pydub`, `Demucs` und `Whisper` decken bereits starke lokale Audio-Bausteine ab.
- Für die in der Quelldatei beschriebene eigentliche Musik-Generierung fehlen noch Music-Generatoren und Visual-Generatoren.

## Vergleich

### ✅ In Sync

- `Clawbake` ist eingebunden.
- `FFmpeg`, `librosa`, `pydub`, `Demucs` und `Whisper` sind als einzelne Tools vorhanden.
- Das Profil ist damit für Analyse, Bearbeitung und Prompting praktisch einsetzbar.

### ⚠ Missing in Setup

- `Suno`, `Udio`, `MusicGen` und `Riffusion` fehlen noch als installierbare Module.
- `Stable Diffusion`, `ControlNet` und weitere Media-Layer-Bausteine sind nur dokumentiert.
- Analytics- und Viral-Layer wie Hook-Detection, BPM-/Energy-Classification oder TikTok-Score fehlen als echte Tools.

### ❌ Missing in Docs

- Die Verzahnung zwischen Musikprofil, Audio-Pipeline und Visual-Pipeline ist in der Hauptdoku noch nicht klar genug beschrieben.

## Hinweise

- Das Profil ist aktuell stärker für Prompting, Analyse und Post-Processing als für vollständige Musikgenerierung ausgeprägt.
- Für GPU-intensive Medienpipelines fehlen noch mehrere der in der Quelldatei genannten Generator-Module.
