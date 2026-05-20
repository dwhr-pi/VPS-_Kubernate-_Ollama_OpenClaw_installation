#!/usr/bin/env bash
set -euo pipefail

echo "Starte Architektur_3D_BIM Profil-Setup..."
echo "Standardmodus: Diagnose und Ordnerstruktur. Schwere Installationen nur mit ARCH_INSTALL_CORE=1."

PROJECT_ROOT="${ARCHITECTURE_PROJECT_ROOT:-$HOME/Ultimate_KI_Setup/architecture}"

mkdir -p \
  "$PROJECT_ROOT/projects" \
  "$PROJECT_ROOT/ifc" \
  "$PROJECT_ROOT/cad" \
  "$PROJECT_ROOT/blender" \
  "$PROJECT_ROOT/comfyui" \
  "$PROJECT_ROOT/renders" \
  "$PROJECT_ROOT/exports" \
  "$PROJECT_ROOT/textures" \
  "$PROJECT_ROOT/materials" \
  "$PROJECT_ROOT/photogrammetry" \
  "$PROJECT_ROOT/reports" \
  "$PROJECT_ROOT/cache" \
  "$PROJECT_ROOT/backups"

echo "Projektordner vorbereitet: $PROJECT_ROOT"

if command -v lsb_release >/dev/null 2>&1; then
  echo "System: $(lsb_release -ds)"
fi

if grep -qi microsoft /proc/version 2>/dev/null; then
  echo "WSL erkannt. GPU-/GUI-Tools bitte mit WSLg/CUDA-Kompatibilitaet pruefen."
fi

if [[ "${ARCH_INSTALL_CORE:-0}" != "1" ]]; then
  echo "Keine Paketinstallation ausgefuehrt."
  echo "Optional: ARCH_INSTALL_CORE=1 bash scripts/install_architektur_3d_bim_optional.sh"
  echo "Empfohlene Pakete je nach Distribution: freecad, blender, openscad, qgis, sweethome3d, colmap."
  exit 0
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get nicht gefunden. Bitte Pakete passend zur Distribution manuell installieren."
  exit 0
fi

echo "Installiere optionale Kernpakete ueber apt, soweit verfuegbar..."
sudo apt-get update
sudo apt-get install -y freecad blender openscad qgis colmap python3 python3-pip python3-venv || {
  echo "Einige Pakete konnten nicht installiert werden. Das kann je nach Ubuntu-Version normal sein."
}

echo "Installationslauf beendet. Bitte anschliessend pruefen:"
echo "  bash profiles/architektur_3d_bim/scripts/check_architektur_stack.sh"

