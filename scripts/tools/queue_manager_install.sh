#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---dry-run}"
QUEUE_DIR="${QUEUE_MANAGER_DIR:-$HOME/.openclaw_ultimate_user_data/queue}"

case "$MODE" in
  --dry-run|--plan|--prepare|--status|--help|-h) ;;
  *)
    echo "Bitte --dry-run, --prepare, --status oder --help verwenden." >&2
    exit 2
    ;;
esac

if [[ "$MODE" == "--help" || "$MODE" == "-h" ]]; then
  echo "Usage: bash scripts/tools/queue_manager_install.sh [--dry-run|--prepare|--status]"
  exit 0
fi

if [[ "$MODE" == "--status" ]]; then
  echo "Queue Manager Status"
  [[ -d "$QUEUE_DIR" ]] && echo "Queue-Ordner vorhanden: $QUEUE_DIR" || echo "Queue-Ordner fehlt: $QUEUE_DIR"
  [[ -f "$QUEUE_DIR/queue-policy.json" ]] && cat "$QUEUE_DIR/queue-policy.json" || true
  exit 0
fi

if [[ "$MODE" == "--dry-run" || "$MODE" == "--plan" ]]; then
  echo "Dry-run Queue Manager"
  echo "Wuerde lokalen Queue-Ordner vorbereiten: $QUEUE_DIR"
  echo "Wuerde Beispiel-Policy fuer MiniPC, VPS, Pi und GPU Workstation schreiben."
  echo "Keine Queue-Engine wird automatisch installiert."
  exit 0
fi

mkdir -p "$QUEUE_DIR/jobs" "$QUEUE_DIR/logs"
cat > "$QUEUE_DIR/queue-policy.json" <<'EOF'
{
  "default_engine": "planned",
  "parallelism": {
    "minipc_wsl2": 1,
    "oracle_vps": 2,
    "raspberry_pi": 1,
    "gpu_workstation_heavy": 1,
    "gpu_workstation_light": 2
  },
  "heavy_tools_require_confirmation": [
    "airbyte",
    "autogpt",
    "comfyui",
    "blender",
    "video_render_queue"
  ],
  "secrets_policy": "no_secrets_in_job_payloads"
}
EOF
echo "Queue Manager vorbereitet: $QUEUE_DIR"
