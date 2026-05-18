#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_DIR/logs"
LOG_FILE="$LOG_DIR/openhiggsstack-install.log"
START_TS="$(date +%s)"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

say() { printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }
need_cmd() { command -v "$1" >/dev/null 2>&1; }

expand_path() {
    local value="$1"
    value="${value/#\~/$HOME}"
    printf '%s\n' "$value"
}

OPENHIGGSSTACK_HOME="${OPENHIGGSSTACK_HOME:-~/ai-stack}"
OPENHIGGSSTACK_HOME="$(expand_path "$OPENHIGGSSTACK_HOME")"
COMFYUI_DIR="$OPENHIGGSSTACK_HOME/comfyui"
MODEL_DIR="$OPENHIGGSSTACK_HOME/models"
VIDEO_OUTPUT_DIR="${VIDEO_OUTPUT_DIR:-~/ai-stack/outputs/video}"
VIDEO_OUTPUT_DIR="$(expand_path "$VIDEO_OUTPUT_DIR")"
ENV_EXAMPLE="$REPO_DIR/.env.openhiggsstack.example"

say "OpenHiggsStack Installation startet"
say "Logdatei: $LOG_FILE"
say "OS: $(uname -a)"
say "Freier Speicher vorher:"
df -h "$HOME" || true

say "Pruefe Basisprogramme"
need_cmd python3 || { echo "Fehler: python3 fehlt."; exit 1; }
need_cmd git || { echo "Fehler: git fehlt."; exit 1; }

if ! need_cmd ffmpeg; then
    say "FFmpeg fehlt."
    if need_cmd apt; then
        read -r -p "FFmpeg via apt installieren? [j/N] " answer
        case "${answer:-N}" in
            j|J|y|Y)
                sudo apt update
                sudo apt install -y ffmpeg
                ;;
            *)
                echo "FFmpeg wird nicht installiert. Postprocessing bleibt deaktiviert."
                ;;
        esac
    else
        echo "Kein apt gefunden. Bitte FFmpeg manuell installieren."
    fi
else
    say "FFmpeg gefunden: $(command -v ffmpeg)"
fi

say "Erstelle Ordnerstruktur"
mkdir -p \
    "$OPENHIGGSSTACK_HOME" \
    "$MODEL_DIR/image" \
    "$MODEL_DIR/video" \
    "$MODEL_DIR/loras" \
    "$MODEL_DIR/controlnet" \
    "$VIDEO_OUTPUT_DIR" \
    "$OPENHIGGSSTACK_HOME/outputs/images" \
    "$OPENHIGGSSTACK_HOME/outputs/storyboards" \
    "$OPENHIGGSSTACK_HOME/projects" \
    "$HOME/.openclaw/agents/video-director"

if [ ! -f "$ENV_EXAMPLE" ]; then
    say "Erzeuge $ENV_EXAMPLE"
    cat > "$ENV_EXAMPLE" <<'EOF'
OPENHIGGSSTACK_HOME=~/ai-stack
COMFYUI_HOST=http://127.0.0.1:8188
OLLAMA_BASE_URL=http://127.0.0.1:11434
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
VIDEO_OUTPUT_DIR=~/ai-stack/outputs/video
FFMPEG_PATH=ffmpeg
HIGGSFIELD_API_KEY=
HUGGINGFACE_TOKEN=
KLING_API_KEY=
VEO_API_KEY=
RUNWAY_API_KEY=
SEEDANCE_API_KEY=
DEFAULT_VIDEO_MODEL=wan2.2
DEFAULT_IMAGE_MODEL=flux
DEFAULT_LLM_MODEL=ollama/llama3.2:1b
EOF
else
    say "$ENV_EXAMPLE existiert bereits und wird nicht ueberschrieben."
fi

if [ ! -d "$COMFYUI_DIR/.git" ]; then
    read -r -p "ComfyUI jetzt nach $COMFYUI_DIR klonen? [j/N] " clone_answer
    case "${clone_answer:-N}" in
        j|J|y|Y)
            git clone https://github.com/comfy-org/ComfyUI.git "$COMFYUI_DIR"
            python3 -m venv "$COMFYUI_DIR/venv"
            # shellcheck disable=SC1091
            source "$COMFYUI_DIR/venv/bin/activate"
            pip install --upgrade pip
            pip install -r "$COMFYUI_DIR/requirements.txt"
            deactivate || true
            ;;
        *)
            say "ComfyUI-Klon uebersprungen."
            ;;
    esac
else
    say "ComfyUI ist bereits vorhanden: $COMFYUI_DIR"
fi

say "Grosse Modelle werden absichtlich NICHT automatisch heruntergeladen."
read -r -p "Nur Dokumentationshinweis fuer manuelle Wan/Flux-Modell-Downloads anzeigen? [J/n] " model_answer
case "${model_answer:-J}" in
    n|N) ;;
    *)
        cat <<'EOF'
Manuelle Modellkandidaten:
- Wan2.1 T2V-1.3B als kleiner Einstieg
- Wan2.1/Wan2.2 I2V je nach ComfyUI-Workflow
- Flux oder Stable Diffusion fuer Keyframes
- ControlNet/IPAdapter/LoRA nur projektbezogen
- Hugging Face / Huge_Facing als Modellquelle nutzen, aber grosse Modelle nur manuell laden
- HUGGINGFACE_TOKEN nur lokal setzen, falls private oder gated Modelle wirklich benoetigt werden
EOF
        ;;
esac

END_TS="$(date +%s)"
DURATION="$((END_TS - START_TS))"
say "Freier Speicher nachher:"
df -h "$HOME" || true
say "OpenHiggsStack Vorbereitung abgeschlossen in ${DURATION}s."
say "Erster Test: cd \"$COMFYUI_DIR\" && source venv/bin/activate && python main.py --listen 127.0.0.1 --port 8188"
