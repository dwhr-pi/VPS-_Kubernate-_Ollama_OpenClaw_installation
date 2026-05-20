#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
CAD3D_HOME="${CAD3D_HOME:-$HOME/Ultimate_KI_Setup/cad_3d_konstruktion}"
LOG_DIR="${CAD3D_HOME}/logs"
LOG_FILE="${LOG_DIR}/cad-3d-konstruktion-install.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte CAD 3D Konstruktion Basisinstallation..."
echo "Home: $CAD3D_HOME"
df -h "$HOME" || true

create_tree() {
  mkdir -p \
    "$CAD3D_HOME/projects" \
    "$CAD3D_HOME/requirements" \
    "$CAD3D_HOME/prompts" \
    "$CAD3D_HOME/openscad" \
    "$CAD3D_HOME/freecad" \
    "$CAD3D_HOME/cadquery" \
    "$CAD3D_HOME/build123d" \
    "$CAD3D_HOME/meshes" \
    "$CAD3D_HOME/exports/stl" \
    "$CAD3D_HOME/exports/step" \
    "$CAD3D_HOME/exports/obj" \
    "$CAD3D_HOME/exports/glb" \
    "$CAD3D_HOME/exports/3mf" \
    "$CAD3D_HOME/previews" \
    "$CAD3D_HOME/slicer" \
    "$CAD3D_HOME/robotik_bauteile" \
    "$CAD3D_HOME/reports" \
    "$CAD3D_HOME/archive" \
    "$CAD3D_HOME/logs"
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
    echo "Kein apt-get gefunden. Bitte git, Python, FreeCAD und OpenSCAD manuell installieren."
    return 0
  fi

  sudo apt-get update
  apt_install_if_available \
    git curl ca-certificates python3 python3-venv python3-pip pipx \
    openscad freecad meshlab blender

  if [ "${CAD3D_INSTALL_HEAVY_TOOLS:-0}" = "1" ]; then
    apt_install_if_available prusa-slicer cura
  else
    echo "Schwere/optionale Tools wie PrusaSlicer/Cura werden nicht automatisch installiert."
    echo "Setze CAD3D_INSTALL_HEAVY_TOOLS=1 fuer einen bewussten Versuch."
  fi
}

install_python_tools() {
  python3 -m venv "$CAD3D_HOME/venv"
  "$CAD3D_HOME/venv/bin/python" -m pip install --upgrade pip wheel setuptools
  "$CAD3D_HOME/venv/bin/pip" install trimesh numpy-stl

  if [ "${CAD3D_INSTALL_PARAMETRIC_LIBS:-0}" = "1" ]; then
    echo "Installiere optionale Python-CAD-Bibliotheken. Das kann je nach Plattform fehlschlagen."
    "$CAD3D_HOME/venv/bin/pip" install cadquery build123d || echo "Hinweis: cadquery/build123d Installation fehlgeschlagen; bitte manuell pruefen."
  else
    echo "Optionale Python-CAD-Bibliotheken cadquery/build123d werden nicht automatisch installiert."
    echo "Setze CAD3D_INSTALL_PARAMETRIC_LIBS=1 fuer einen bewussten Versuch."
  fi
}

write_examples() {
  cat > "$CAD3D_HOME/cad_3d_konstruktion.env.example" <<'EOF'
CAD3D_HOME=~/Ultimate_KI_Setup/cad_3d_konstruktion
OLLAMA_BASE_URL=http://127.0.0.1:11434
OPENCLAW_GATEWAY_URL=ws://127.0.0.1:18789
N8N_BASE_URL=http://127.0.0.1:5678
FREECAD_BIN=freecad
FREECAD_CMD=FreeCADCmd
OPENSCAD_BIN=openscad
BLENDER_BIN=blender
DEFAULT_CAD_MODEL=ollama/qwen2.5-coder
CAD3D_INSTALL_HEAVY_TOOLS=0
CAD3D_INSTALL_PARAMETRIC_LIBS=0
EOF

  cat > "$CAD3D_HOME/openscad/example_sensor_mount.scad" <<'EOF'
// Einfaches parametrisches Beispiel fuer einen Sensorhalter.
width = 60;
depth = 35;
height = 4;
hole_d = 4.2;
hole_offset = 10;

difference() {
  cube([width, depth, height], center = true);
  translate([-(width/2-hole_offset), 0, 0]) cylinder(h = height + 2, d = hole_d, center = true, $fn = 40);
  translate([(width/2-hole_offset), 0, 0]) cylinder(h = height + 2, d = hole_d, center = true, $fn = 40);
}
EOF

  cat > "$CAD3D_HOME/prompts/text_to_cad_prompt.md" <<'EOF'
# Text-to-CAD Prompt

Erzeuge ein parametrisches CAD-Modell. Frage nach fehlenden Massen, Toleranzen,
Material, Druckverfahren, Lastfall, Schrauben/Inserts und Montageumgebung.
Gib erst eine Konstrukteurs-Checkliste aus, danach OpenSCAD oder FreeCAD-Python.
EOF
}

create_tree
install_apt_tools || true
install_python_tools || true
write_examples

echo "Keine Cloud-Keys, keine grossen Modelle und keine proprietaeren CAD-Daten wurden eingerichtet."
echo "FreeCAD/OpenSCAD/Blender koennen je nach Ubuntu/WSL2-Paketstand manuelle Nacharbeit brauchen."
df -h "$HOME" || true
echo "Dauer: $(($(date +%s) - START_TS)) Sekunden"
echo "Logdatei: $LOG_FILE"
