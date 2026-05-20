#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="gamedev_3d_studio_install"
START_TS="$(date +%s)"
GAMEDEV_HOME="${GAMEDEV_HOME:-$HOME/Ultimate_KI_Setup/gamedev_3d_studio}"
LOG_DIR="$GAMEDEV_HOME/logs"
LOG_FILE="$LOG_DIR/gamedev-3d-studio-install.log"
GODOT_REPO_URL="${GODOT_REPO_URL:-https://github.com/godotengine/godot.git}"
GODOT_DEMOS_REPO_URL="${GODOT_DEMOS_REPO_URL:-https://github.com/godotengine/godot-demo-projects.git}"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

free_gb() {
    df -BG "$HOME" | awk 'NR==2 {gsub("G","",$4); print $4}'
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log "Fehlt: $1"
        return 1
    fi
}

install_base_packages() {
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y git curl ca-certificates python3 python3-venv python3-pip unzip zip jq
        if [ "${GAMEDEV_INSTALL_HEAVY_TOOLS:-0}" = "1" ]; then
            sudo apt-get install -y blender scons pkg-config build-essential clang || true
        fi
    else
        log "Kein apt-get gefunden. Bitte Basisabhaengigkeiten manuell installieren: git curl python3 unzip zip jq."
    fi
}

create_structure() {
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
        "$GAMEDEV_HOME/docs"
}

clone_or_update() {
    local repo_url="$1"
    local target_dir="$2"
    if [ -d "$target_dir/.git" ]; then
        log "Aktualisiere $target_dir"
        git -C "$target_dir" pull --ff-only
    else
        log "Klone $repo_url nach $target_dir"
        git clone --depth 1 "$repo_url" "$target_dir"
    fi
}

write_examples() {
    cat > "$GAMEDEV_HOME/gamedev_3d_studio.env.example" <<'EOF'
GAMEDEV_HOME=~/Ultimate_KI_Setup/gamedev_3d_studio
OLLAMA_BASE_URL=http://127.0.0.1:11434
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
COMFYUI_HOST=http://127.0.0.1:8188
N8N_BASE_URL=http://127.0.0.1:5678
DEFAULT_NPC_MODEL=ollama/llama3.2:1b
DEFAULT_STORY_MODEL=ollama/qwen2.5:7b
EOF

    cat > "$GAMEDEV_HOME/ai/agents/game-master-agent.md" <<'EOF'
# OpenClaw Agent: Game Master

Aufgabe: Quests, NPC-Ziele, Ereignisse, Weltzustand und Build-/Asset-Aufgaben planen.

Sicherheitsregeln:
- Keine Secrets ausgeben.
- Keine Cloud-Deployments ohne Freigabe.
- Keine grossen Downloads ohne Speicherpruefung.
- NPC-Memory versionieren und exportierbar halten.
EOF

    cat > "$GAMEDEV_HOME/ai/npc-brains/npc-brain-template.json" <<'EOF'
{
  "npc_id": "npc_example_001",
  "name": "Example NPC",
  "model": "ollama/llama3.2:1b",
  "memory_policy": "local-jsonl",
  "faction": "neutral",
  "relationships": {},
  "safety": {
    "no_personal_data": true,
    "no_secret_output": true
  }
}
EOF
}

main() {
    log "Starte GameDev 3D Studio NEXTLEVEL Installation"
    log "Freier Speicher vorher: $(free_gb) GB"

    create_structure
    install_base_packages
    require_command git || true

    if [ "${GAMEDEV_CLONE_GODOT:-0}" = "1" ]; then
        clone_or_update "$GODOT_REPO_URL" "$GAMEDEV_HOME/projects/godot/godot"
    else
        log "Godot Clone uebersprungen. Aktivieren mit GAMEDEV_CLONE_GODOT=1."
    fi

    if [ "${GAMEDEV_CLONE_DEMOS:-0}" = "1" ]; then
        clone_or_update "$GODOT_DEMOS_REPO_URL" "$GAMEDEV_HOME/projects/godot/godot-demo-projects"
    else
        log "Godot Demo Projects uebersprungen. Aktivieren mit GAMEDEV_CLONE_DEMOS=1."
    fi

    if [ "${GAMEDEV_BUILD_GODOT:-0}" = "1" ]; then
        if [ -d "$GAMEDEV_HOME/projects/godot/godot" ]; then
            log "Starte Godot Source Build. Das kann lange dauern."
            (cd "$GAMEDEV_HOME/projects/godot/godot" && scons platform=linuxbsd target=editor -j"$(nproc)")
        else
            log "Godot Build angefragt, aber Repository fehlt. Setze GAMEDEV_CLONE_GODOT=1."
        fi
    else
        log "Godot Source Build uebersprungen. Aktivieren mit GAMEDEV_BUILD_GODOT=1."
    fi

    write_examples
    log "Freier Speicher nachher: $(free_gb) GB"
    log "Dauer: $(( $(date +%s) - START_TS )) Sekunden"
    log "GameDev 3D Studio vorbereitet: $GAMEDEV_HOME"
    log "Logdatei: $LOG_FILE"
}

main "$@"
