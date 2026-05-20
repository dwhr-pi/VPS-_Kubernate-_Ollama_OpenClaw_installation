#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
GAMEDEV_HOME="${GAMEDEV_HOME:-$HOME/Ultimate_KI_Setup/gamedev_3d_studio}"
LOG_DIR="$GAMEDEV_HOME/logs"
LOG_FILE="$LOG_DIR/gamedev-3d-studio-install.log"
GODOT_REPO_URL="${GODOT_REPO_URL:-https://github.com/godotengine/godot.git}"
GODOT_DEMOS_REPO_URL="${GODOT_DEMOS_REPO_URL:-https://github.com/godotengine/godot-demo-projects.git}"
GODOT_BRANCH="${GODOT_BRANCH:-master}"
GODOT_DEMOS_BRANCH="${GODOT_DEMOS_BRANCH:-master}"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte GameDev 3D Studio NEXTLEVEL Basisvorbereitung..."
echo "Home: $GAMEDEV_HOME"
df -h "$HOME" || true

create_tree() {
  mkdir -p \
    "$GAMEDEV_HOME/projects/godot" \
    "$GAMEDEV_HOME/projects/unreal" \
    "$GAMEDEV_HOME/projects/unity" \
    "$GAMEDEV_HOME/projects/npc-ai" \
    "$GAMEDEV_HOME/projects/worldgen" \
    "$GAMEDEV_HOME/projects/renderfarm" \
    "$GAMEDEV_HOME/projects/multiplayer" \
    "$GAMEDEV_HOME/projects/voice" \
    "$GAMEDEV_HOME/projects/mods" \
    "$GAMEDEV_HOME/ai/ollama" \
    "$GAMEDEV_HOME/ai/agents" \
    "$GAMEDEV_HOME/ai/memory" \
    "$GAMEDEV_HOME/ai/rag" \
    "$GAMEDEV_HOME/ai/npc-brains" \
    "$GAMEDEV_HOME/assets/textures" \
    "$GAMEDEV_HOME/assets/models" \
    "$GAMEDEV_HOME/assets/audio" \
    "$GAMEDEV_HOME/assets/music" \
    "$GAMEDEV_HOME/assets/skyboxes" \
    "$GAMEDEV_HOME/assets/icons" \
    "$GAMEDEV_HOME/assets/portraits" \
    "$GAMEDEV_HOME/blender" \
    "$GAMEDEV_HOME/comfyui" \
    "$GAMEDEV_HOME/dashboard/gamedev-control-center" \
    "$GAMEDEV_HOME/benchmarks" \
    "$GAMEDEV_HOME/builds" \
    "$GAMEDEV_HOME/docs" \
    "$GAMEDEV_HOME/logs"
}

install_basics() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Kein apt-get gefunden. Bitte git, Python und Build-Tools manuell installieren."
    return 0
  fi

  sudo apt-get update
  sudo apt-get install -y git curl ca-certificates python3 python3-venv python3-pip unzip zip jq

  if [ "${GAMEDEV_INSTALL_HEAVY_TOOLS:-0}" = "1" ]; then
    sudo apt-get install -y blender scons pkg-config build-essential clang || true
  else
    echo "Schwere Tools/Compiler werden nicht automatisch installiert."
    echo "Setze GAMEDEV_INSTALL_HEAVY_TOOLS=1 fuer Blender/SCons/Build-Tools."
  fi
}

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"
  local branch="$3"

  if [ -d "$target_dir/.git" ]; then
    echo "Aktualisiere Repository: $target_dir"
    git -C "$target_dir" fetch --all --prune
    git -C "$target_dir" checkout "$branch" || true
    git -C "$target_dir" pull --ff-only || echo "Hinweis: Pull nicht moeglich, lokale Aenderungen bleiben erhalten: $target_dir"
  else
    echo "Klone Repository: $repo_url"
    git clone --depth 1 --branch "$branch" "$repo_url" "$target_dir" || git clone --depth 1 "$repo_url" "$target_dir"
  fi
}

prepare_godot() {
  if [ "${GAMEDEV_CLONE_GODOT:-1}" = "1" ]; then
    clone_or_update "$GODOT_REPO_URL" "$GAMEDEV_HOME/projects/godot/godot" "$GODOT_BRANCH"
  else
    echo "Godot-Clone uebersprungen: GAMEDEV_CLONE_GODOT=0"
  fi

  if [ "${GAMEDEV_CLONE_DEMOS:-1}" = "1" ]; then
    clone_or_update "$GODOT_DEMOS_REPO_URL" "$GAMEDEV_HOME/projects/godot/godot-demo-projects" "$GODOT_DEMOS_BRANCH"
  else
    echo "Godot-Demo-Clone uebersprungen: GAMEDEV_CLONE_DEMOS=0"
  fi

  if [ "${GAMEDEV_BUILD_GODOT:-0}" = "1" ]; then
    echo "Godot Source-Build wurde bewusst aktiviert."
    echo "Bitte pruefe vorher RAM, Speicher, Compiler und Godot-Dokumentation."
    (cd "$GAMEDEV_HOME/projects/godot/godot" && scons platform=linuxbsd target=editor || true)
  else
    echo "Godot wird nicht automatisch aus Source gebaut. Setze GAMEDEV_BUILD_GODOT=1 fuer einen bewussten Versuch."
  fi
}

write_examples() {
  cat > "$GAMEDEV_HOME/gamedev_3d_studio.env.example" <<'EOF'
GAMEDEV_HOME=~/Ultimate_KI_Setup/gamedev_3d_studio
GAMEDEV_CLONE_GODOT=1
GAMEDEV_CLONE_DEMOS=1
GAMEDEV_BUILD_GODOT=0
OLLAMA_BASE_URL=http://127.0.0.1:11434
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
N8N_BASE_URL=http://127.0.0.1:5678
COMFYUI_HOST=http://127.0.0.1:8188
DEFAULT_GAMEDEV_MODEL=ollama/qwen2.5-coder
DEFAULT_NPC_MODEL=ollama/llama3.1
EOF

  cat > "$GAMEDEV_HOME/ai/agents/game-master-agent.md" <<'EOF'
# OpenClaw Game Master Agent

Aufgabe: Quests, NPC-Ereignisse, Weltzustand, Fraktionen und dynamische Schwierigkeit planen.

Regel: Keine Live-Deployments, Mod-Uploads oder Serveraenderungen ohne menschliche Freigabe.
EOF

  cat > "$GAMEDEV_HOME/ai/npc-brains/npc-brain-template.json" <<'EOF'
{
  "name": "npc_name",
  "role": "merchant",
  "faction": "neutral",
  "memory_policy": "local_only",
  "relationships": {},
  "rumors": [],
  "safety": {
    "no_real_person_impersonation": true,
    "local_storage_only": true
  }
}
EOF
}

create_tree
install_basics || true
prepare_godot || true
write_examples

echo "GameDev 3D Studio Basisstruktur ist vorbereitet."
echo "Keine Cloud-Keys, keine grossen Modelle und kein Godot-Source-Build ohne explizite Freigabe."
df -h "$HOME" || true
echo "Dauer: $(($(date +%s) - START_TS)) Sekunden"
echo "Logdatei: $LOG_FILE"
