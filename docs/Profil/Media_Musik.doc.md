Nice, dein Setup geht klar in Richtung AI Music Production Stack + Prompt-Engineering Pipeline + Media-Multiagent (Ollama/OpenClaw) – genau da lohnt es sich, das „Media_Musik“-Profil sauber wie ein kleines Creative Studio zu denken.

Ich teile dir das mal in zwei Teile auf:


---

## 🎛️ 1. Prompt-Liste für Music / Media (Suno / Udio / MusicGen Style)

Das ist deine „Prompt-Bibliothek als Engine“ für OpenClaw.

### 🔥 Core Prompt Template (Master-Struktur)

Du kannst das als Standard für alle Generierungen nutzen:

#### STRUCTURED MUSIC PROMPT

* Genre:
* Subgenre:
* BPM:
* Key:
* Mood:
* Energy Level:
* Instruments:
* Vocal Style:
* Language:
* Structure:
* Drop Design:
* FX / Sound Design:
* Reference Vibe:



---

### ⚡ EDM / Hyperpop / Trap Prompt Set

#### 💿 Viral Hyperpop EDM (Female Lead)
```
futuristic hyperpop, aggressive edm trap fusion, 128 bpm, f minor, glitch stutter vocals, distorted vocal chops, neon cyber aesthetic, female vocal energy, heavy sidechain bass, fast arpeggiated synths, build up tension, explosive drop, festival ready, tiktok viral hook, robotic adlibs
```



---

#### 🔊 Cyber Trap (Dark Tech)

```
dark cyber trap, 140 bpm, minimal but heavy 808s, metallic percussion, dystopian atmosphere, whisper rap vocals, synthetic textures, industrial bass design, glitch transitions, cinematic tension build, underground club vibe
```



---

#### 🌈 Pop EDM Viral Hook

```
bright edm pop, 124 bpm, uplifting chord progression, clean female vocals, catchy hook chorus, summer festival vibe, tropical synth layers, punchy kick, wide stereo mix, emotional drop, radio friendly structure
```



---

### 🎧 K-Pop / Hybrid Style

#### 💥 K-Pop Hyper EDM (Aggressive Girl Group Style)

```
k-pop hyperpop edm trap fusion, 128 bpm, f minor, powerful female group vocals, rap + singing switch, fast cut transitions, glitch edits, cinematic intro, high energy pre chorus, explosive drop chorus, anime aesthetic, futuristic production, viral tiktok hook
```



---

#### 🎤 Emotional K-Pop Ballad Hybrid

```
emotional k-pop ballad with edm elements, 90 bpm, piano driven intro, soft female vocals, cinematic strings, build into electronic drop, emotional chorus, layered harmonies, dramatic storytelling
```



---

### 🧠 Rap / Trap / AI Vocal Style

#### 🔥 Aggressive Trap Rap

```
dark trap beat, 140 bpm, heavy 808 bass, punchy snare, rap vocals with aggressive flow, minimal melody, cinematic dark atmosphere, street energy, repetitive hook phrase, club ready
```



---

#### 🤖 AI Glitch Rap (Experimental)

```
experimental glitch rap, fragmented vocal cuts, chopped syllables, hypercompressed drums, unpredictable rhythm, digital distortion, cyberpunk vibe, glitchcore aesthetic
```



---

### 🎬 Cinematic / Media / Soundtrack

#### 🎥 Trailer Music Hybrid EDM

```
cinematic trailer music, orchestral + edm fusion, rising tension, epic percussion, choir layers, massive drop, emotional intensity, heroic theme, hybrid orchestral synth design
```



---

#### 🧬 AI Ambient Tech Soundscape

```
ambient futuristic soundscape, slow evolving pads, minimal rhythm, deep sub drones, neural network inspired textures, calm but eerie, sci-fi atmosphere
```



---

### 🧰 Prompt “Modifiers” (für OpenClaw wichtig)

Diese kannst du als Parameter Layer nutzen:

* VIRAL: “tiktok hook optimized”
* CLUB: “DJ festival mix ready”
* CINEMATIC: “trailer scoring style”
* LOFI: “soft textures, warm noise”
* GLITCH: “stutter edits, fragmented audio”
* ANIME: “japanese pop aesthetic”
* DARK: “minor key, dystopian tone”
* FUTURISTIC: “AI generated aesthetic, cyber sound design”



---

## 🧠 2. Sinnvolle Tools für dein Ollama + OpenClaw Media_Musik Profil

Hier wird’s spannend – du willst nicht nur Musik generieren, sondern ein Agenten-Studio bauen.


---

### 🧩 Core Stack (Pflicht)

#### 🧠 Ollama (LLM Core)

* Prompt-Engineering
* Genre-Interpretation
* Music Metadata Structuring
* Lyrics Generator
* Prompt Refiner


#### 👉 Modelle:

* llama3
* mistral
* qwen2.5
* codellama (für Toolchains)



---

### 🎛️ OpenClaw (Orchestration Layer)

* Workflow Engine für:

  * Prompt → Music → Remix → Metadata → Export


* Agent Routing:

  * “Lyric Agent”
  * “Beat Agent”
  * “Style Agent”
  * “Viral Agent”




---

### 🎵 AI Music Generator Layer

#### 🎧 Suno / Udio API (oder Wrapper)

* Haupt-Generator
* final Audio Output


Alternative Open Source:

* MusicGen (Meta) 
* Riffusion (experimentell / streaming style)



---

### 🧠 Prompt Intelligence Layer

#### 🧾 Prompt Engine Tools

* Prompt templates DB (JSON / YAML)
* Variant Generator (A/B/C styles)
* LLM-as-Judge (Qualitätsscore)

👉 Idee: „8 Prompt Variants → Score → Best Pick → Generate Music“


---

### 🔊 Audio Processing Layer

Tools:

* FFmpeg (cut, normalize, remix)
* librosa (audio analysis)
* pydub (simple manipulation)
* demucs (stem separation)



---

### 🎨 Media Layer (Optional aber stark)

### 🖼️ Album / Visual Generator

* Stable Diffusion (Cover Art)
* ControlNet (style consistency)
* Music2P-style pipeline 



---

#### 📊 Analytics / Viral Layer

* Hook detection (repeating phrases)
* BPM + energy classification
* “TikTok probability score”
* Emotion tagging



---

### 🧠 Advanced OpenClaw Agents (empfohlen)

Du könntest dein System so strukturieren:

* 🎼 Music Director Agent

→ entscheidet Genre / Mood / Structure

* ✍️ Lyric Agent

→ schreibt DE/EN Mix Lyrics + Hooks

* 🔊 Sound Designer Agent

→ instrument + synth + FX design

* 📈 Viral Agent

→ optimiert für TikTok / Shorts

* 🧪 Critic Agent

→ bewertet Output & regeneriert


---

### 🚀 Bonus: Media_Musik Profil Architektur

So könnte dein Stack aussehen:
```
User Idea
   ↓
OpenClaw Router
   ↓
Ollama (Music Director Agent)
   ↓
Prompt Builder Engine
   ↓
Variant Generator (x8)
   ↓
Judge Agent (scoring)
   ↓
Best Prompt
   ↓
Suno / MusicGen
   ↓
Audio Processing (FFmpeg / Stem split)
   ↓
Metadata + Viral Score
   ↓
Export (Dashboard / API / Playlist)
```

---

## Wenn du willst

Ich kann dir als nächsten Schritt bauen:

* 🔥 1. komplettes OpenClaw Media_Musik YAML Schema

* 🔥 2. Agent Prompt System (fertig für Ollama)

* 🔥 3. Prompt-Generator Microservice (Python / Node)

* 🔥 4. Viral TikTok Optimizer Algorithmus

* 🔥 5. oder ein Dashboard für dein VPS/Kubernetes Setup

Sag mir einfach, wie tief du rein willst – das Ding kann schnell von „Tool“ zu „Mini-Musik-OS“ werden 😄

## 📌 Ende des Dokuments
Wenn du willst, kann ich dir als nächsten Step daraus direkt machen:
* �⁠🧠 OpenClaw Media_Musik YAML Pipeline
* �⁠🎛️ Prompt-Engine als JSON Schema
* �⁠🚀 Kubernetes Microservice Architektur
* �⁠🎵 oder ein „AI Music OS“ Konzept für dein VPS Setup
