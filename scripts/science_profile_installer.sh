#!/usr/bin/env bash
set -euo pipefail

PROFILE_KEY="${1:?Profilname fehlt, z.B. Physik}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCIENCE_ROOT="${SCIENCE_LAB_ROOT:-$HOME/Ultimate_KI_Setup/science_lab}"
PROFILE_ROOT="$SCIENCE_ROOT/$PROFILE_KEY"
PROJECT_MANIFEST="$REPO_ROOT/profiles/science_lab/github_projects.tsv"

log() { echo "[science:$PROFILE_KEY] $*"; }

free_gb() {
  df -BG "$HOME" 2>/dev/null | awk 'NR==2 {gsub("G","",$4); print $4}'
}

detect_gpu() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "cuda"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || true
  elif command -v rocminfo >/dev/null 2>&1; then
    echo "rocm"
    rocminfo 2>/dev/null | grep -E 'Marketing Name|Name:' | head -n 10 || true
  else
    echo "cpu"
  fi
}

clone_github_projects() {
  [ -f "$PROJECT_MANIFEST" ] || return 0
  mkdir -p "$PROFILE_ROOT/src"
  while IFS='|' read -r profile name url purpose notes; do
    case "$profile" in ""|\#*) continue ;; esac
    [ "$profile" = "$PROFILE_KEY" ] || continue
    target="$PROFILE_ROOT/src/$(printf '%s' "$name" | tr '[:upper:] /' '[:lower:]__')"
    if [ -d "$target/.git" ]; then
      log "Aktualisiere $name aus GitHub..."
      git -C "$target" pull --ff-only || log "Hinweis: $name konnte nicht fast-forward aktualisiert werden."
    else
      log "Klone $name aus GitHub: $url"
      git clone "$url" "$target"
    fi
  done < "$PROJECT_MANIFEST"
}

write_requirements() {
  case "$PROFILE_KEY" in
    Physik)
      cat > "$PROFILE_ROOT/requirements.txt" <<'REQ'
jupyterlab
numpy
scipy
matplotlib
pandas
sympy
qutip
plasmapy
yt
REQ
      ;;
    Chemie)
      cat > "$PROFILE_ROOT/requirements.txt" <<'REQ'
jupyterlab
numpy
scipy
pandas
matplotlib
rdkit
deepchem
pubchempy
REQ
      ;;
    Biologie)
      cat > "$PROFILE_ROOT/requirements.txt" <<'REQ'
jupyterlab
numpy
pandas
matplotlib
biopython
scanpy
napari
scikit-image
REQ
      ;;
    Bioinformatik)
      cat > "$PROFILE_ROOT/requirements.txt" <<'REQ'
jupyterlab
numpy
pandas
matplotlib
biopython
polars
pyarrow
snakemake
REQ
      ;;
    Molekuelsimulation)
      cat > "$PROFILE_ROOT/requirements.txt" <<'REQ'
jupyterlab
numpy
scipy
pandas
matplotlib
mdtraj
openmm
nglview
REQ
      ;;
    Robotik_Labor)
      cat > "$PROFILE_ROOT/requirements.txt" <<'REQ'
jupyterlab
numpy
pandas
matplotlib
pyserial
pymodbus
paho-mqtt
opencv-python
REQ
      ;;
    Materialwissenschaft)
      cat > "$PROFILE_ROOT/requirements.txt" <<'REQ'
jupyterlab
numpy
scipy
pandas
matplotlib
pymatgen
matminer
ase
REQ
      ;;
  esac
}

log "Freier Speicher vor Start: $(free_gb) GB"
log "GPU-Erkennung:"
detect_gpu | sed 's/^/[science:gpu] /'

mkdir -p "$PROFILE_ROOT"/{data,notebooks,papers,outputs,dashboards,agents,src,k8s,home_assistant,voice}
write_requirements

if command -v python3 >/dev/null 2>&1; then
  python3 -m venv "$PROFILE_ROOT/.venv"
  "$PROFILE_ROOT/.venv/bin/python" -m pip install --upgrade pip wheel
  if [ "${SCIENCE_INSTALL_PYTHON_DEPS:-0}" = "1" ]; then
    "$PROFILE_ROOT/.venv/bin/pip" install -r "$PROFILE_ROOT/requirements.txt"
  else
    log "Python-Dependencies nicht installiert. Aktivieren mit SCIENCE_INSTALL_PYTHON_DEPS=1."
  fi
else
  log "python3 nicht gefunden. Bitte Python installieren."
fi

if [ "${SCIENCE_CLONE_GITHUB:-0}" = "1" ]; then
  clone_github_projects
else
  log "GitHub-Projekte nicht geklont. Aktivieren mit SCIENCE_CLONE_GITHUB=1."
fi

cat > "$PROFILE_ROOT/README.md" <<EOF
# $PROFILE_KEY Science Lab

Lokaler Profilordner fuer $PROFILE_KEY.

- notebooks/: JupyterLab-Analysen
- papers/: PDFs und Paper-Notizen
- src/: optionale GitHub-Clones
- dashboards/: wissenschaftliche Dashboards
- k8s/: Kubernetes-Offloading-Manifeste
- home_assistant/: Sensorintegration
- voice/: Whisper-Sprachsteuerung
EOF

log "Freier Speicher nach Ende: $(free_gb) GB"
log "Profil vorbereitet: $PROFILE_ROOT"

