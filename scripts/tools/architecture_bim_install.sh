#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
ARCHITECTURE_HOME="${ARCHITECTURE_HOME:-$HOME/Ultimate_KI_Setup/architecture}"
LOG_DIR="${ARCHITECTURE_HOME}/logs"
LOG_FILE="${LOG_DIR}/architecture-bim-install.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte Architektur 3D BIM Basisinstallation..."
echo "Home: $ARCHITECTURE_HOME"
df -h "$HOME" || true

create_tree() {
  mkdir -p \
    "$ARCHITECTURE_HOME/projects" \
    "$ARCHITECTURE_HOME/bim" \
    "$ARCHITECTURE_HOME/ifc" \
    "$ARCHITECTURE_HOME/cad" \
    "$ARCHITECTURE_HOME/blender" \
    "$ARCHITECTURE_HOME/freecad" \
    "$ARCHITECTURE_HOME/renders" \
    "$ARCHITECTURE_HOME/textures" \
    "$ARCHITECTURE_HOME/photogrammetry" \
    "$ARCHITECTURE_HOME/gis" \
    "$ARCHITECTURE_HOME/energy" \
    "$ARCHITECTURE_HOME/stl" \
    "$ARCHITECTURE_HOME/vr_ar" \
    "$ARCHITECTURE_HOME/backups" \
    "$ARCHITECTURE_HOME/cache" \
    "$ARCHITECTURE_HOME/reports" \
    "$ARCHITECTURE_HOME/logs"
}

apt_install_if_available() {
  local pkg
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo apt-get install -y "$pkg"
    else
      echo "Hinweis: apt-Paket nicht verfuegbar oder anderer Paketname: $pkg"
    fi
  done
}

install_apt_tools() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Kein apt-get gefunden. Bitte Tools manuell installieren."
    return 0
  fi

  sudo apt-get update
  apt_install_if_available \
    git curl ca-certificates python3 python3-venv python3-pip pipx \
    blender freecad openscad qgis colmap meshlab \
    sweethome3d

  if [ "${ARCHITECTURE_INSTALL_HEAVY_TOOLS:-0}" = "1" ]; then
    apt_install_if_available meshroom openstudio energyplus
  else
    echo "Schwere/optionale Tools wie Meshroom/OpenStudio/EnergyPlus werden nicht automatisch installiert."
    echo "Setze ARCHITECTURE_INSTALL_HEAVY_TOOLS=1 fuer einen bewussten Versuch."
  fi
}

install_python_tools() {
  if [ "${ARCHITECTURE_INSTALL_PY_TOOLS:-1}" != "1" ]; then
    echo "Python-BIM-Tools uebersprungen."
    return 0
  fi

  python3 -m venv "$ARCHITECTURE_HOME/venv"
  "$ARCHITECTURE_HOME/venv/bin/python" -m pip install --upgrade pip wheel setuptools
  "$ARCHITECTURE_HOME/venv/bin/pip" install ifcopenshell specklepy
}

write_env_example() {
  cat > "$ARCHITECTURE_HOME/architecture_bim.env.example" <<'EOF'
ARCHITECTURE_HOME=~/Ultimate_KI_Setup/architecture
OLLAMA_BASE_URL=http://127.0.0.1:11434
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
COMFYUI_HOST=http://127.0.0.1:8188
BLENDER_BIN=blender
FREECAD_BIN=freecad
DEFAULT_ARCH_MODEL=ollama/qwen2.5-coder
EOF
}

create_tree
install_apt_tools || true
install_python_tools || true
write_env_example

echo "Keine proprietaeren Cloud-Keys und keine grossen Modelle wurden eingerichtet."
echo "Bonsai/BlenderBIM, Speckle Connectoren, LoRAs, Texturen und EnergyPlus/OpenStudio bitte je nach Bedarf manuell pruefen."
df -h "$HOME" || true
echo "Dauer: $(($(date +%s) - START_TS)) Sekunden"
echo "Logdatei: $LOG_FILE"

