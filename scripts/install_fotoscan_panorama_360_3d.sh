#!/usr/bin/env bash
set -euo pipefail

START_TS="$(date +%s)"
MEDIA_HOME="${FOTOSCAN_MEDIA_HOME:-$HOME/KI-Media}"
LOG_DIR="${MEDIA_HOME}/logs"
LOG_FILE="${LOG_DIR}/fotoscan-panorama-360-3d-install.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "Starte FotoScan Panorama 360 3D Installation..."
echo "Media Home: $MEDIA_HOME"
df -h "$HOME" || true

detect_system() {
  echo "Kernel: $(uname -a)"
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Hinweis: WSL/WSL2 erkannt. GPU/CUDA, GUI und USB-/Viewer-Tools koennen Sonderkonfiguration benoetigen."
  fi
}

create_dirs() {
  mkdir -p \
    "$MEDIA_HOME/input/photos" \
    "$MEDIA_HOME/output/panorama" \
    "$MEDIA_HOME/output/360" \
    "$MEDIA_HOME/output/3d" \
    "$MEDIA_HOME/output/splat" \
    "$MEDIA_HOME/work" \
    "$MEDIA_HOME/logs"
}

install_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "Kein apt-get gefunden. Bitte Hugin, COLMAP, exiftool, zip und ffmpeg manuell installieren."
    return 0
  fi

  sudo apt-get update
  sudo apt-get install -y hugin hugin-tools enblend enfuse exiftool zip unzip ffmpeg

  if apt-cache show colmap >/dev/null 2>&1; then
    sudo apt-get install -y colmap
  else
    echo "COLMAP ist ueber diese apt-Quellen nicht verfuegbar. Bitte manuell installieren oder aus Quelle bauen."
  fi

  echo "Meshroom/AliceVision wird nur optional markiert. Prebuilt Binary oder manuelle Installation nach Projekt-Doku nutzen."
  echo "OpenMVG/OpenMVS sind optionale Build-Pfade und werden wegen Build-Aufwand nicht automatisch gebaut."
}

write_examples() {
  cat > "$MEDIA_HOME/README_FotoScan.md" <<'EOF'
# FotoScan Panorama 360 3D

Ordner:

- input/photos
- output/panorama
- output/360
- output/3d
- output/splat

Panorama-Beispiel:

```bash
cd ~/KI-Media/input/photos
pto_gen -o project.pto *.jpg
cpfind --multirow -o project.pto project.pto
autooptimiser -a -l -s -m -o project.pto project.pto
hugin_executor --stitching --prefix=~/KI-Media/output/panorama/pano project.pto
```

COLMAP-Beispiel:

```bash
PROJECT=~/KI-Media/output/3d/colmap_project
mkdir -p "$PROJECT"
colmap automatic_reconstructor --workspace_path "$PROJECT" --image_path ~/KI-Media/input/photos --quality medium
```
EOF
}

detect_system
create_dirs
install_packages || true
write_examples

echo "FotoScan Basisinstallation abgeschlossen."
echo "Keine GPU-lastigen oder experimentellen Photogrammetrie-/Splatting-Builds wurden automatisch ausgefuehrt."
df -h "$HOME" || true
echo "Dauer: $(($(date +%s) - START_TS)) Sekunden"
echo "Logdatei: $LOG_FILE"

