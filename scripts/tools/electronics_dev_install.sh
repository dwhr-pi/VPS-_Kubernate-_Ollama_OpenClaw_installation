#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
ELECTRONICS_HOME="${ELECTRONICS_HOME:-$HOME/Ultimate_KI_Setup/electronics}"
LOG_DIR="${ELECTRONICS_HOME}/logs"
LOG_FILE="${LOG_DIR}/electronics-dev-install.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte Elektronik Entwickler Toolchain..."
echo "Home: $ELECTRONICS_HOME"
df -h "$HOME" || true

create_tree() {
  mkdir -p \
    "$ELECTRONICS_HOME/projects" \
    "$ELECTRONICS_HOME/kicad" \
    "$ELECTRONICS_HOME/freecad" \
    "$ELECTRONICS_HOME/firmware" \
    "$ELECTRONICS_HOME/fpga" \
    "$ELECTRONICS_HOME/datasheets" \
    "$ELECTRONICS_HOME/bom" \
    "$ELECTRONICS_HOME/gerber" \
    "$ELECTRONICS_HOME/simulations" \
    "$ELECTRONICS_HOME/dashboards" \
    "$ELECTRONICS_HOME/exports" \
    "$ELECTRONICS_HOME/logs"
}

install_apt_basics() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Kein apt-get gefunden. Bitte Toolchain manuell installieren."
    return 0
  fi

  sudo apt-get update
  sudo apt-get install -y \
    git curl ca-certificates build-essential cmake ninja-build pkg-config \
    python3 python3-venv python3-pip pipx \
    kicad freecad ngspice openocd verilator yosys gtkwave \
    arduino librepcb fritzing

  if [ "${ELECTRONICS_INSTALL_HEAVY_EDA:-0}" = "1" ]; then
    sudo apt-get install -y openroad || echo "OpenROAD nicht ueber apt verfuegbar; siehe Projekt-Doku."
  else
    echo "Schwere EDA-Pakete wie OpenROAD/OpenLane werden nicht automatisch installiert."
    echo "Setze ELECTRONICS_INSTALL_HEAVY_EDA=1 fuer zusaetzliche lokale Versuche."
  fi
}

install_python_tools() {
  python3 -m venv "$ELECTRONICS_HOME/venv"
  "$ELECTRONICS_HOME/venv/bin/python" -m pip install --upgrade pip wheel setuptools
  "$ELECTRONICS_HOME/venv/bin/pip" install platformio
}

install_node_tools() {
  if [ "${ELECTRONICS_INSTALL_NODE_TOOLS:-0}" != "1" ]; then
    echo "Node/TypeScript-EDA-Tools nicht automatisch installiert."
    echo "Setze ELECTRONICS_INSTALL_NODE_TOOLS=1 fuer tscircuit/Arduino CLI-nahe Node-Tools."
    return 0
  fi

  if command -v corepack >/dev/null 2>&1; then
    corepack enable || true
    corepack prepare pnpm@latest --activate || true
  fi

  if command -v npm >/dev/null 2>&1; then
    npm install -g tscircuit || echo "tscircuit konnte nicht global installiert werden."
  else
    echo "npm nicht gefunden; tscircuit uebersprungen."
  fi
}

clone_optional_mcp_tools() {
  if [ "${ELECTRONICS_INSTALL_MCP_TOOLS:-0}" != "1" ]; then
    echo "MCP-/AI-KiCad-Repositories werden nicht automatisch geklont."
    echo "Setze ELECTRONICS_INSTALL_MCP_TOOLS=1 fuer KiCad MCP, circuit-synth und kicad-happy Quellen."
    return 0
  fi

  mkdir -p "$ELECTRONICS_HOME/ai-tools"
  clone_or_pull "https://github.com/Seeed-Studio/kicad-mcp-server.git" "$ELECTRONICS_HOME/ai-tools/kicad-mcp-server"
  clone_or_pull "https://github.com/circuit-synth/circuit-synth.git" "$ELECTRONICS_HOME/ai-tools/circuit-synth"
  clone_or_pull "https://github.com/aklofas/kicad-happy.git" "$ELECTRONICS_HOME/ai-tools/kicad-happy"
}

clone_or_pull() {
  local repo_url="$1"
  local target_dir="$2"
  if [ -d "$target_dir/.git" ]; then
    git -C "$target_dir" pull --ff-only || echo "Hinweis: Update fehlgeschlagen: $target_dir"
  else
    git clone "$repo_url" "$target_dir"
  fi
}

create_tree
install_apt_basics || true
install_python_tools || true
install_node_tools || true
clone_optional_mcp_tools || true

cat > "$ELECTRONICS_HOME/electronics.env.example" <<'EOF'
ELECTRONICS_HOME=~/Ultimate_KI_Setup/electronics
OLLAMA_BASE_URL=http://127.0.0.1:11434
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
MQTT_HOST=127.0.0.1
MQTT_PORT=1883
DEFAULT_LLM_MODEL=ollama/deepseek-coder
EOF

echo "Elektronik Entwickler Toolchain vorbereitet."
echo "Keine Hersteller-Keys, Board-Secrets oder Cloud-Zugangsdaten wurden angelegt."
df -h "$HOME" || true
echo "Dauer: $(($(date +%s) - START_TS)) Sekunden"
echo "Logdatei: $LOG_FILE"

