#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
exec python3 -I -B "$ROOT/scripts/profiles/coding_agents.py" profile Ollama_Coder "${1:-uninstall}"
