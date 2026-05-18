# Video Generation ComfyUI Wan

Status: experimental  
Kategorie: Video / GPU / ComfyUI / Wan  

## Ziel

Dieses technische Profil beschreibt eine lokale Video-KI-Pipeline mit ComfyUI, Wan2.1/Wan2.2, FFmpeg und optionaler OpenClaw-/n8n-Orchestrierung. Es ist die technische Basis fuer OpenHiggsStack.

## Hardware-Anforderungen

- Low-End CPU-only: nur Prompting, Planung, kleine Tests und Workflow-Vorbereitung.
- 8-12 GB VRAM: minimal fuer kleine oder stark optimierte Workflows.
- 16-24 GB VRAM: empfohlen fuer realistische lokale Video-Experimente.
- 32 GB+ RAM: empfohlen fuer groessere Modelle, ComfyUI und parallele Tools.
- 100 GB+ freier Speicher: empfohlen, weil Modelle, Caches und Outputs schnell wachsen.
- Multi-GPU/Kubernetes: optional, Advanced, erst nach stabiler Einzel-GPU-Konfiguration.

## Windows 11 und WSL2

- WSL2 mit Ubuntu 24.04 ist geeignet, wenn GPU-Passthrough funktioniert.
- NVIDIA-Treiber unter Windows installieren, CUDA in WSL pruefen.
- Speicherort fuer Modelle nach Moeglichkeit nicht auf sehr knappem `C:` belassen.
- Nach grossen Loeschungen `wsl --shutdown` und VHDX-Compact einplanen.

## Ubuntu-Hinweise

```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip ffmpeg
```

GPU-Pfade sind hardwareabhaengig. NVIDIA Container Toolkit oder CUDA sollten erst installiert werden, wenn die GPU sauber erkannt wird.

## Beispielordner

```text
~/ai-stack/comfyui
~/ai-stack/models
~/ai-stack/outputs/video
~/.openclaw/agents/video-director
```

## ComfyUI Installation

```bash
mkdir -p ~/ai-stack
cd ~/ai-stack
git clone https://github.com/comfy-org/ComfyUI.git comfyui
cd comfyui
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

Start:

```bash
cd ~/ai-stack/comfyui
source venv/bin/activate
python main.py --listen 127.0.0.1 --port 8188
```

## ComfyUI Manager

ComfyUI Manager ist optional. Er erleichtert Custom Nodes, kann aber auch Abhaengigkeiten und Updates vermischen. Fuer produktive Systeme erst nach Snapshot/Backup aktivieren.

## Wan2.1/Wan2.2 Modellhinweise

- Wan2.1 dokumentiert Text-to-Video, Image-to-Video, Video Editing, Text-to-Image und Video-to-Audio.
- Wan2.1 T2V-1.3B ist der sinnvollste Einstieg fuer kleinere GPUs.
- Wan2.2 sollte bevorzugt ueber dokumentierte ComfyUI-Workflows getestet werden.
- Modelle manuell herunterladen und Checksummen/Quelle dokumentieren.
- Keine automatischen Downloads im Setup, weil einzelne Modelle viele GB belegen.

## FFmpeg

FFmpeg wird fuer Postprocessing benoetigt:

```bash
ffmpeg -i input.mp4 -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -crf 18 -preset medium output-shorts.mp4
```

## OpenClaw-Integration

OpenClaw sollte nicht direkt rohe Modellbefehle blind ausfuehren. Empfohlen ist:

- Agent erstellt Storyboard und Prompts.
- Mensch bestaetigt Modell, Aufloesung, Kosten und Speicher.
- ComfyUI fuehrt Workflow aus.
- n8n ueberwacht Queue und Export.
- FFmpeg erzeugt finale Formate.

## Manuell zu ladende Modelle

- Wan2.1 T2V-1.3B fuer Einstieg.
- Wan2.1/Wan2.2 I2V je nach Workflow.
- Flux oder Stable Diffusion fuer Keyframes.
- ControlNet/IPAdapter/LoRA nur bei Bedarf.
## Hugging Face / Huge_Facing

Hugging Face ist fuer dieses Profil vor allem Modellquelle, Lizenznachweis und Versionsanker. Das Setup soll keine grossen Modelle automatisch herunterladen. Stattdessen werden Modellkarten und Lizenzen manuell geprueft und die Pfade anschliessend in `.env.openhiggsstack`, ComfyUI oder OpenClaw hinterlegt.

Sinnvolle Einsatzpunkte:

- Wan2.1/Wan2.2-Modellgewichte fuer Text-to-Video und Image-to-Video.
- Flux-, SDXL- oder Stable-Diffusion-Modelle fuer Keyframes und Character Consistency.
- LoRA-, ControlNet-, IPAdapter- und Upscaler-Modelle fuer konsistente Stile.
- Whisper/TTS-Modelle fuer spaetere Voice- und Musikvideo-Workflows.

Sicherheitsregel: `HUGGINGFACE_TOKEN` bleibt leer, solange kein privates oder gated Modell benoetigt wird. Wenn ein Token gebraucht wird, liegt er nur lokal in der persoenlichen Env-Datei oder unter `~/.openclaw_ultimate_user_data`.
