#!/usr/bin/env bash
set -euo pipefail

CAD_HOME="${CAD_HOME:-$HOME/.openclaw_ultimate_user_data/cad_konstrukteur}"
VENV_DIR="${CAD_VENV_DIR:-$CAD_HOME/venv}"
WORKSPACE_DIR="${CAD_WORKSPACE_DIR:-$(pwd)}"

ok() { printf '[OK] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { printf '[FEHLT] %s\n' "$*"; }

check_cmd() {
    if command -v "$1" >/dev/null 2>&1; then
        ok "$1 vorhanden: $(command -v "$1")"
    else
        fail "$1 nicht gefunden"
    fi
}

check_cmd freecad || true
check_cmd freecadcmd || true
check_cmd openscad || true
check_cmd blender || true
check_cmd python3 || true
check_cmd pip3 || true

if [ -d "$VENV_DIR" ]; then
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
    if python - <<'PY'
import cadquery
print(cadquery.__version__)
PY
    then
        ok "cadquery in venv importierbar"
    else
        warn "cadquery in venv nicht importierbar"
    fi
else
    warn "CAD venv nicht gefunden: $VENV_DIR"
fi

if [ -w "$WORKSPACE_DIR" ]; then
    ok "Workspace beschreibbar: $WORKSPACE_DIR"
else
    warn "Workspace nicht beschreibbar: $WORKSPACE_DIR"
fi

if command -v curl >/dev/null 2>&1 && curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    ok "Ollama erreichbar unter http://127.0.0.1:11434"
else
    warn "Ollama unter http://127.0.0.1:11434 nicht erreichbar"
fi

if [ -d "$HOME/.openclaw_ultimate_user_data" ] || [ -d "/opt/openclaw" ]; then
    ok "OpenClaw-/Setup-Konfigurationspfad gefunden"
else
    warn "Kein OpenClaw-Konfigurationspfad gefunden"
fi

if command -v openscad >/dev/null 2>&1 && [ -f "profiles/cad_konstrukteur/examples/openscad_case_example.scad" ]; then
    mkdir -p cad_exports
    if openscad -o cad_exports/check_openscad_case.stl profiles/cad_konstrukteur/examples/openscad_case_example.scad >/tmp/cad_openscad_check.log 2>&1; then
        ok "OpenSCAD Export-Test erfolgreich: cad_exports/check_openscad_case.stl"
    else
        warn "OpenSCAD Export-Test fehlgeschlagen. Details: /tmp/cad_openscad_check.log"
    fi
else
    warn "OpenSCAD Export-Test uebersprungen"
fi
