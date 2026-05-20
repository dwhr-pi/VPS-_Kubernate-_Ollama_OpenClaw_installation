#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
AI_3D_HOME="${AI_3D_HOME:-$HOME/Ultimate_KI_Setup}"
LOG_DIR="${AI_3D_HOME}/logs"
LOG_FILE="${LOG_DIR}/ai-3d-studio-install.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte AI 3D Studio Basisinstallation..."
echo "Home: $AI_3D_HOME"
df -h "$HOME" || true

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Fehlt: $1"
    return 1
  fi
}

install_apt_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git python3 python3-venv python3-pip ffmpeg xz-utils
  else
    echo "Kein apt-get gefunden. Bitte git, python3, python3-venv, pip und ffmpeg manuell installieren."
  fi
}

create_project_tree() {
  mkdir -p \
    "$AI_3D_HOME/3d" \
    "$AI_3D_HOME/blender" \
    "$AI_3D_HOME/comfyui" \
    "$AI_3D_HOME/assets" \
    "$AI_3D_HOME/renders" \
    "$AI_3D_HOME/stl" \
    "$AI_3D_HOME/workflows" \
    "$AI_3D_HOME/textures" \
    "$AI_3D_HOME/animations" \
    "$AI_3D_HOME/exports" \
    "$AI_3D_HOME/docs" \
    "$AI_3D_HOME/models" \
    "$AI_3D_HOME/logs"
}

write_env_example() {
  cat > "$AI_3D_HOME/ai3d.env.example" <<'EOF'
AI_3D_HOME=~/Ultimate_KI_Setup
COMFYUI_HOST=http://127.0.0.1:8188
OLLAMA_BASE_URL=http://127.0.0.1:11434
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
BLENDER_BIN=blender
FFMPEG_PATH=ffmpeg
DEFAULT_3D_MODEL=hunyuan3d-2.1
DEFAULT_FAST_3D_MODEL=triposr
AI3D_DOWNLOAD_MODELS=0
EOF
}

clone_comfy_node() {
  local repo_url="$1"
  local target_dir="$2"

  if [ -d "$target_dir/.git" ]; then
    echo "Aktualisiere ComfyUI Node: $target_dir"
    git -C "$target_dir" pull --ff-only || echo "Hinweis: Node konnte nicht aktualisiert werden: $target_dir"
  else
    echo "Klone ComfyUI Node: $repo_url"
    git clone "$repo_url" "$target_dir"
  fi
}

install_comfy_3d_nodes() {
  local comfy_root="${COMFYUI_ROOT:-/opt/comfyui}"
  local custom_nodes="$comfy_root/custom_nodes"

  if [ ! -d "$custom_nodes" ]; then
    echo "ComfyUI custom_nodes nicht gefunden: $custom_nodes"
    echo "Installiere zuerst ComfyUI oder setze COMFYUI_ROOT=/pfad/zur/ComfyUI."
    return 0
  fi

  clone_comfy_node "${COMFYUI_HUNYUAN3D_NODE_REPO:-https://github.com/visualbruno/ComfyUI-Hunyuan3d-2-1}" "$custom_nodes/ComfyUI-Hunyuan3d-2-1"
  clone_comfy_node "${COMFYUI_TRIPOSR_NODE_REPO:-https://github.com/flowtyone/ComfyUI-Flowty-TripoSR}" "$custom_nodes/ComfyUI-Flowty-TripoSR"
  clone_comfy_node "${COMFYUI_TRIPO_NODE_REPO:-https://github.com/VAST-AI-Research/ComfyUI-Tripo}" "$custom_nodes/ComfyUI-Tripo"

  echo "Node-Repositories vorbereitet. Requirements und Modellpfade bitte bewusst nach jeweiliger Node-Doku installieren."
}

install_apt_packages || true
need_cmd git || true
need_cmd python3 || true
need_cmd ffmpeg || true
create_project_tree
write_env_example

if [ "${AI3D_INSTALL_COMFY_NODES:-0}" = "1" ]; then
  install_comfy_3d_nodes
else
  echo "ComfyUI-3D-Nodes wurden nicht automatisch installiert."
  echo "Setze AI3D_INSTALL_COMFY_NODES=1, wenn die Node-Repositories bewusst in ComfyUI/custom_nodes geklont werden sollen."
fi

echo "Keine grossen Modelle wurden automatisch heruntergeladen."
echo "Manuell laden: Hunyuan3D-Shape/Paint, TripoSR Checkpoints, optionale FLUX/Stable-Diffusion-Modelle."
df -h "$HOME" || true

END_TS="$(date +%s)"
echo "AI 3D Studio Basisinstallation abgeschlossen in $((END_TS - START_TS)) Sekunden."
echo "Logdatei: $LOG_FILE"
