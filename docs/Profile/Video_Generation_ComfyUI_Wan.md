# Video Generation: ComfyUI + Wan2.x

Status: `experimental`  
Tier: `advanced`  
Kategorie: `media`

Dieses technische Profil beschreibt den lokalen Video-Stack fuer ComfyUI und Wan2.1/Wan2.2. Es ist die Render-Schicht fuer OpenHiggsStack.

## Hardware-Anforderungen

| Klasse | Erwartung |
|---|---|
| Low-End CPU-only | nur Prompting, Planung, Workflow-Tests ohne ernsthaftes Rendering |
| 8-12 GB VRAM | minimale kleine Workflows, kurze Clips, reduzierte Aufloesung |
| 16-24 GB VRAM | empfohlen fuer realistischere lokale Tests |
| 24 GB+ VRAM | komfortabler fuer groessere Modelle, laengere Clips und Batch-Jobs |
| Multi-GPU/Kubernetes | optional, spaeterer Advanced-Pfad mit Queue, Storage und Monitoring |

Speicherwarnung: Video-Modelle, VAE, LoRAs, Zwischenbilder und Outputs koennen schnell viele hundert GB belegen.

## Windows 11 + WSL2

- WSL2 mit Ubuntu nutzen.
- NVIDIA-Treiber auf Windows-Seite installieren.
- In WSL mit `nvidia-smi` pruefen, ob die GPU sichtbar ist.
- Projektdateien und Modelle moeglichst im Linux-Dateisystem speichern, nicht unter `/mnt/c`, wenn viele kleine Dateien genutzt werden.
- ComfyUI-Weboberflaeche standardmaessig nur lokal nutzen: `http://127.0.0.1:8188`.

## Ubuntu Hinweise

Basis:

```bash
sudo apt-get update
sudo apt-get install -y git python3 python3-venv python3-pip ffmpeg
```

Optional GPU:

- NVIDIA-Treiber
- CUDA-kompatibles PyTorch
- ausreichend Swap/SSD

## Python venv

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

## ComfyUI starten

```bash
cd ~/ai-stack/comfyui
source venv/bin/activate
python main.py --listen 127.0.0.1 --port 8188
```

Dann im Browser:

```text
http://127.0.0.1:8188
```

## ComfyUI Manager

ComfyUI Manager ist optional. Er erleichtert Custom Nodes, kann aber auch unkontrolliert viele Abhaengigkeiten nachziehen. In produktionsnahen Setups besser dokumentiert und bewusst installieren.

## Wan2.1/Wan2.2 Modellhinweise

- Modelle nicht automatisch im Setup herunterladen.
- Modellquellen und Lizenzen vor Nutzung pruefen.
- Passende ComfyUI-Workflows separat importieren.
- Fuer kurze Tests mit niedriger Aufloesung starten.
- Outputs zuerst lokal pruefen, bevor Cloud-/Social-Uploads automatisiert werden.

## Beispielordner

```text
~/ai-stack/comfyui
~/ai-stack/models
~/ai-stack/outputs/video
~/.openclaw/agents/video-director
```

## FFmpeg

FFmpeg wird fuer folgende Schritte genutzt:

- Framerate anpassen
- Audio und Video zusammenfuehren
- Shorts-Formate erzeugen
- Thumbnails extrahieren
- Untertitel einbrennen
- Archivkopien erzeugen

Beispiel:

```bash
ffmpeg -i input.mp4 -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" output-short.mp4
```

## OpenClaw/Ollama-Einbindung

Ollama erstellt Storyboards, Shotlisten, negative Prompts und Social Captions. OpenClaw entscheidet, welcher Schritt lokal, per ComfyUI oder optional per Cloud-Fallback laufen soll.

## Ersttest

1. `bash scripts/install-openhiggsstack.sh` ausfuehren.
2. ComfyUI starten.
3. Einen kleinen Image-to-Video-Workflow manuell importieren.
4. Mit kurzer Dauer und niedriger Aufloesung rendern.
5. Ergebnis mit FFmpeg nachbearbeiten.

## Referenzen

- ComfyUI: `https://github.com/comfy-org/ComfyUI`
- Wan2.1: `https://github.com/Wan-Video/Wan2.1`
- Wan2.2: `https://github.com/Wan-Video/Wan2.2`
- ComfyUI Wan2.2 Tutorial: `https://docs.comfy.org/tutorials/video/wan/wan2_2`
