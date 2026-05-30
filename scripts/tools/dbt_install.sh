#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="dbt"
TOOL_DIR="${TOOL_DIR:-/opt/dbt_core}"
DBT_REPO_URL="${DBT_REPO_URL:-https://github.com/dbt-labs/dbt-core.git}"
DBT_MIN_LINUX_FREE_MB="${DBT_MIN_LINUX_FREE_MB:-4096}"
DBT_MIN_WINDOWS_FREE_MB="${DBT_MIN_WINDOWS_FREE_MB:-20480}"

free_mb_for_path() {
  df -Pm "${1:-/}" 2>/dev/null | awk 'NR==2 {print $4}'
}

preflight_dbt() {
  local linux_free_mb
  local windows_free_mb

  linux_free_mb="$(free_mb_for_path / || true)"
  echo "dbt-core wird aus GitHub geklont, aber aus dem Unterordner 'core' installiert."
  echo "Hintergrund: Der Repository-Root ist ein Monorepo/Flat-Layout und darf nicht direkt per pip install -e installiert werden."
  echo "Freier Linux-/WSL-Speicher: ${linux_free_mb:-unbekannt} MB"

  if [[ -n "${linux_free_mb:-}" && "$linux_free_mb" -lt "$DBT_MIN_LINUX_FREE_MB" ]]; then
    echo "Fehler: Zu wenig Linux-/WSL-Speicher fuer dbt. Benoetigt mindestens ${DBT_MIN_LINUX_FREE_MB} MB."
    return 1
  fi

  if [[ -d /mnt/c ]]; then
    windows_free_mb="$(free_mb_for_path /mnt/c || true)"
    echo "Freier Windows-Host-Speicher (C:): ${windows_free_mb:-unbekannt} MB"
    if [[ -n "${windows_free_mb:-}" && "$windows_free_mb" -lt "$DBT_MIN_WINDOWS_FREE_MB" ]]; then
      echo "Warnung: Windows-C: hat weniger als ${DBT_MIN_WINDOWS_FREE_MB} MB frei. WSL-VHDX-Wachstum kann Python-Installationen stoeren."
    fi
  fi
}

install_dbt_core_from_github() {
  begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"

  if ! ensure_user_workspace || ! require_disk_mb "$DBT_MIN_LINUX_FREE_MB" / || ! preflight_dbt; then
    end_measurement "failed"
    return 1
  fi

  ensure_base_apt_packages git python3 python3-venv python3-pip python3-dev build-essential pkg-config

  sudo mkdir -p "$(dirname "$TOOL_DIR")"
  sudo chown -R "$USER":"$USER" "$(dirname "$TOOL_DIR")"

  if [[ ! -d "$TOOL_DIR/.git" ]]; then
    git clone "$DBT_REPO_URL" "$TOOL_DIR"
  else
    git -C "$TOOL_DIR" fetch origin --prune
    git -C "$TOOL_DIR" pull --ff-only || true
  fi

  if [[ ! -f "$TOOL_DIR/core/pyproject.toml" ]]; then
    echo "Fehler: Erwarteter dbt-core Unterordner fehlt: $TOOL_DIR/core"
    echo "Das dbt-core Repository-Layout hat sich moeglicherweise geaendert."
    end_measurement "failed"
    return 1
  fi

  python3 -m venv "$TOOL_DIR/.venv"
  # shellcheck disable=SC1091
  source "$TOOL_DIR/.venv/bin/activate"
  pip install --upgrade pip setuptools wheel

  # Wichtig: Nicht den Repo-Root installieren. Der Root enthaelt mehrere Top-Level-
  # Verzeichnisse (core, docker, schemas) und setuptools bricht sonst ab.
  pip install -e "$TOOL_DIR/core"

  if ! command -v dbt >/dev/null 2>&1; then
    echo "Fehler: dbt Kommando wurde in der venv nicht gefunden."
    deactivate || true
    end_measurement "failed"
    return 1
  fi

  dbt --version || true
  echo "Hinweis: dbt-core ist installiert. Fuer echte Projekte wird meist ein Adapter benoetigt, z. B. dbt-postgres, dbt-duckdb, dbt-bigquery oder dbt-snowflake."
  echo "Adapter bitte bewusst passend zum Zielsystem installieren, nicht automatisch."

  deactivate || true
  mark_tool_installed "$TOOL_NAME"
  log_success "${TOOL_NAME} installiert."
  end_measurement "success"
}

install_dbt_core_from_github
