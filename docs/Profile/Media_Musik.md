# Profil: Media_Musik

## Überblick

Dieses Profil ist dokumentiert als Medien- und Musikprofil und wird jetzt konkret um FFmpeg ergänzt.

## Installierter Stack

- Basis: `git`, `nodejs>=22`, `pnpm`
- Profil-Tooling:
  - Clawbake unter `/opt/clawbake`
  - FFmpeg als Systempaket für Audio- und Videoverarbeitung
  - librosa unter `/opt/librosa`
  - pydub unter `/opt/pydub`
  - Demucs unter `/opt/demucs`
  - Whisper unter `/opt/whisper`

## Verantwortlichkeiten

- Build- und Deployment-Unterstützung für kreative oder mediennahe Workflows

## Verfügbare Kommandos

```bash
scripts/tools/clawbake_install.sh
scripts/tools/ffmpeg_install.sh
scripts/tools/librosa_install.sh
scripts/tools/pydub_install.sh
scripts/tools/demucs_install.sh
scripts/tools/whisper_install.sh
```

## Beispielprompts

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

## OpenClaw / Ollama Fit

- Ollama kann hier Prompt-Refinement, Genre-Interpretation und Metadaten-Struktur übernehmen.
- Die neuen Audio-Tools unterstützen Analyse, Bearbeitung und Stem-Workflows rund um OpenClaw-Automationen.

## Vergleich

### ✅ In Sync

- Clawbake ist vorhanden und im Profilskript verankert.
- FFmpeg ist jetzt als konkretes Medienprogramm im Profil eingebunden.
- librosa, pydub, Demucs und Whisper decken wichtige Analyse- und Postprocessing-Bausteine aus der Quelldatei ab.

### ⚠ Missing in Setup

- Keine Audio-AI-Tools
- Keine Video-Generatoren
- Keine direkte Alexa-Integration aus dem Profil heraus
- MusicGen, Riffusion, Stable Diffusion und ControlNet sind noch nicht als lokale Installskripte umgesetzt.

### ❌ Missing in Docs

- Es gibt keine dedizierte Profil-Markdown-Datei im ursprünglichen Repo.

## Hinweise

- Das Profil ist jetzt greifbarer als zuvor, bleibt aber weiterhin deutlich schlanker als die übergeordnete Dokumentation suggeriert.
