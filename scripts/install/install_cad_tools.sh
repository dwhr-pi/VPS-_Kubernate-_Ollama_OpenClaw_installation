#!/usr/bin/env bash
set -euo pipefail

CAD_HOME="${CAD_HOME:-$HOME/.openclaw_ultimate_user_data/cad_konstrukteur}"
VENV_DIR="${CAD_VENV_DIR:-$CAD_HOME/venv}"
LOG_DIR="$CAD_HOME/logs"
LOG_FILE="$LOG_DIR/install_cad_tools.log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

install_apt_packages() {
    if ! have_cmd apt-get; then
        log "Kein apt-get gefunden. Bitte FreeCAD/OpenSCAD/Python manuell installieren."
        return 0
    fi

    local packages=(python3 python3-venv python3-pip openscad freecad)
    if [ "${CAD_INSTALL_BLENDER:-0}" = "1" ]; then
        packages+=(blender)
    fi

    log "Installiere/pruefe apt-Pakete: ${packages[*]}"
    sudo apt-get update
    sudo apt-get install -y "${packages[@]}"
}

install_python_packages() {
    if ! have_cmd python3; then
        log "python3 fehlt, ueberspringe Python-venv."
        return 0
    fi

    if [ ! -d "$VENV_DIR" ]; then
        log "Erstelle Python venv: $VENV_DIR"
        python3 -m venv "$VENV_DIR"
    fi

    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
    python -m pip install --upgrade pip wheel setuptools

    log "Installiere optionale Python-CAD-Pakete in venv."
    if ! python -m pip install numpy trimesh meshio cadquery; then
        log "Hinweis: CadQuery/OCP-Wheels sind nicht auf jeder Plattform sauber verfuegbar."
        log "Alternative: CadQuery ueber conda/mamba oder Systempakete nachinstallieren."
    fi
}

main() {
    log "Starte CAD-Tool-Installation"
    log "CAD_HOME=$CAD_HOME"
    install_apt_packages
    install_python_packages
    log "Fertig. Pruefung starten mit: bash scripts/check/check_cad_tools.sh"
    log "Logdatei: $LOG_FILE"
}

main "$@"
