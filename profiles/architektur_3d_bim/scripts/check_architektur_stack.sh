#!/usr/bin/env bash
set -euo pipefail

echo "Pruefe Architektur_3D_BIM Stack..."

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $cmd gefunden: $(command -v "$cmd")"
  else
    echo "[HINWEIS] $cmd nicht gefunden."
  fi
}

check_cmd freecad
check_cmd FreeCAD
check_cmd blender
check_cmd openscad
check_cmd qgis
check_cmd colmap
check_cmd meshroom
check_cmd python3
check_cmd pip3

if python3 - <<'PY' >/dev/null 2>&1
import importlib.util
raise SystemExit(0 if importlib.util.find_spec("ifcopenshell") else 1)
PY
then
  echo "[OK] Python-Modul ifcopenshell importierbar."
else
  echo "[HINWEIS] Python-Modul ifcopenshell nicht importierbar."
fi

if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "[OK] Ollama erreichbar unter http://127.0.0.1:11434"
else
  echo "[HINWEIS] Ollama lokal nicht erreichbar."
fi

echo "Check abgeschlossen. Hinweise sind keine Fehler."

