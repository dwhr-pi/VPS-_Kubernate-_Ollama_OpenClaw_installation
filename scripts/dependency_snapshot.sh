#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_WORKSPACE_DIR="${USER_WORKSPACE_DIR:-$HOME/.openclaw_ultimate_user_data}"
REPORT_DIR="${REPORT_DIR:-$USER_WORKSPACE_DIR/diagnostic_reports}"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/$(date '+%Y%m%d_%H%M%S')_dependency_snapshot.md"

human_du() {
  local path="$1"
  [ -e "$path" ] || return 0
  if command -v timeout >/dev/null 2>&1; then
    timeout 8s du -sh "$path" 2>/dev/null || echo "timeout/kein Zugriff: $path"
  else
    du -sh "$path" 2>/dev/null || true
  fi
}

{
  echo "# Abhaengigkeiten- und Speicher-Snapshot"
  echo
  echo "- Datum: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "- Repo: $ROOT_DIR"
  echo

  echo "## Dateisystem"
  df -h "$HOME" "$ROOT_DIR" 2>/dev/null || df -h
  echo

  echo "## Grosse Standardorte"
  for p in /opt "$HOME/.cache" "$HOME/.npm" "$HOME/.pnpm-store" "$HOME/.local/share/pnpm" "$HOME/.cache/pip" "$HOME/.cache/huggingface" "$HOME/.cache/torch" "$HOME/.ollama" "$HOME/ai-stack" "$USER_WORKSPACE_DIR"; do
    human_du "$p"
  done | sort -h
  echo

  echo "## /opt Details"
  if [ -d /opt ]; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 15s sh -c 'du -sh /opt/* 2>/dev/null | sort -h' || echo "Timeout bei /opt Details."
    else
      du -sh /opt/* 2>/dev/null | sort -h || true
    fi
  fi
  echo

  echo "## Apt"
  if command -v apt-mark >/dev/null 2>&1; then
    echo "### Manuell markierte Pakete"
    if command -v timeout >/dev/null 2>&1; then
      timeout 10s apt-mark showmanual 2>/dev/null | sort || echo "Timeout bei apt-mark showmanual."
    else
      apt-mark showmanual 2>/dev/null | sort
    fi
  else
    echo "apt-mark nicht verfuegbar."
  fi
  echo

  echo "## Python venvs"
  if command -v timeout >/dev/null 2>&1; then
    timeout 12s find /opt "$HOME" -maxdepth 4 -type f -path '*/venv/bin/python' 2>/dev/null || true
  else
    find /opt "$HOME" -maxdepth 4 -type f -path '*/venv/bin/python' 2>/dev/null || true
  fi | sort | while read -r py; do
    venv_dir="$(dirname "$(dirname "$py")")"
    if command -v timeout >/dev/null 2>&1; then
      count="$(timeout 5s "$py" -m pip freeze 2>/dev/null | wc -l | tr -d ' ')"
    else
      count="$("$py" -m pip freeze 2>/dev/null | wc -l | tr -d ' ')"
    fi
    echo "### $venv_dir"
    echo
    echo "- Pakete: $count"
    if command -v timeout >/dev/null 2>&1; then
      timeout 8s "$py" -m pip freeze 2>/dev/null | sed 's/^/- /' || true
    else
      "$py" -m pip freeze 2>/dev/null | sed 's/^/- /' || true
    fi
    echo
  done

  echo "## Node"
  command -v node >/dev/null 2>&1 && echo "- node: $(node --version)" || true
  command -v npm >/dev/null 2>&1 && echo "- npm: $(npm --version)" || true
  command -v pnpm >/dev/null 2>&1 && echo "- pnpm: $(pnpm --version)" || true
  echo
  if command -v npm >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 10s npm list -g --depth=0 2>/dev/null || echo "Timeout bei npm global list."
    else
      npm list -g --depth=0 2>/dev/null || true
    fi
  fi
  echo
  if command -v pnpm >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 8s pnpm store path 2>/dev/null || echo "Timeout bei pnpm store path."
    else
      pnpm store path 2>/dev/null || true
    fi
  fi
  echo

  echo "## Container"
  if command -v docker >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 8s docker system df 2>/dev/null || true
      timeout 8s docker images 2>/dev/null || true
    else
      docker system df 2>/dev/null || true
      docker images 2>/dev/null || true
    fi
  elif command -v podman >/dev/null 2>&1; then
    if command -v timeout >/dev/null 2>&1; then
      timeout 8s podman system df 2>/dev/null || true
      timeout 8s podman images 2>/dev/null || true
    else
      podman system df 2>/dev/null || true
      podman images 2>/dev/null || true
    fi
  else
    echo "Docker/Podman nicht verfuegbar."
  fi
} > "$REPORT_FILE"

echo "Snapshot erstellt: $REPORT_FILE"
sed -n '1,80p' "$REPORT_FILE"
