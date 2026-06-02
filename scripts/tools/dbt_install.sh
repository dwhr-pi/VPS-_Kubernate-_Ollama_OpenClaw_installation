#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="dbt"
TOOL_DIR="${TOOL_DIR:-/opt/dbt_core}"
DBT_REPO_URL="${DBT_REPO_URL:-https://github.com/dbt-labs/dbt-core.git}"
DBT_GIT_REF="${DBT_GIT_REF:-v1.11.11}"
DBT_MIN_LINUX_FREE_MB="${DBT_MIN_LINUX_FREE_MB:-4096}"
DBT_MIN_WINDOWS_FREE_MB="${DBT_MIN_WINDOWS_FREE_MB:-20480}"

free_mb_for_path() {
  df -Pm "${1:-/}" 2>/dev/null | awk 'NR==2 {print $4}'
}

preflight_dbt() {
  local linux_free_mb
  local windows_free_mb

  linux_free_mb="$(free_mb_for_path / || true)"
  echo "dbt-core wird aus GitHub geklont und auf einen stabilen Ref gesetzt: ${DBT_GIT_REF}"
  echo "Hintergrund: Der bewegliche main-Branch kann ein neues/experimentelles Layout enthalten."
  echo "Installiert wird nur ein erkannter Python-Paketpfad, bevorzugt der Unterordner 'core'."
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

checkout_dbt_ref() {
  if [[ ! -d "$TOOL_DIR/.git" ]]; then
    git clone --depth 1 --branch "$DBT_GIT_REF" "$DBT_REPO_URL" "$TOOL_DIR"
    return
  fi

  git -C "$TOOL_DIR" fetch origin --tags --prune
  if ! git -C "$TOOL_DIR" checkout --detach "$DBT_GIT_REF"; then
    echo "Fehler: dbt Git-Ref konnte nicht ausgecheckt werden: ${DBT_GIT_REF}"
    echo "Bitte pruefe den Ref oder setze DBT_GIT_REF auf einen existierenden stabilen Tag, z. B. v1.11.11."
    return 1
  fi
}

detect_dbt_python_package_dir() {
  if [[ -f "$TOOL_DIR/core/pyproject.toml" ]] && grep -q 'name = "dbt-core"' "$TOOL_DIR/core/pyproject.toml"; then
    printf '%s\n' "$TOOL_DIR/core"
    return 0
  fi

  if [[ -f "$TOOL_DIR/pyproject.toml" ]] && grep -q 'name = "dbt-core"' "$TOOL_DIR/pyproject.toml"; then
    if grep -q 'Development Status :: 3 - Alpha' "$TOOL_DIR/pyproject.toml"; then
      echo "Fehler: Der ausgecheckte dbt-Ref nutzt ein Alpha-/Fusion-Layout im Repository-Root." >&2
      echo "Fuer das Setup bitte einen stabilen dbt-core-Tag verwenden, z. B. DBT_GIT_REF=v1.11.11." >&2
      return 1
    fi
    printf '%s\n' "$TOOL_DIR"
    return 0
  fi

  echo "Fehler: Kein installierbares dbt-core Python-Paket im ausgecheckten Ref gefunden." >&2
  echo "Erwartet wurde entweder $TOOL_DIR/core/pyproject.toml oder ein stabiler Root-pyproject.toml." >&2
  return 1
}

install_dbt_core_from_github() {
  local dbt_package_dir

  begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"

  if ! ensure_user_workspace || ! require_disk_mb "$DBT_MIN_LINUX_FREE_MB" / || ! preflight_dbt; then
    end_measurement "failed"
    return 1
  fi

  ensure_base_apt_packages git python3 python3-venv python3-pip python3-dev build-essential pkg-config

  sudo mkdir -p "$(dirname "$TOOL_DIR")"
  sudo chown -R "$USER":"$USER" "$(dirname "$TOOL_DIR")"

  if ! checkout_dbt_ref; then
    end_measurement "failed"
    return 1
  fi

  if ! dbt_package_dir="$(detect_dbt_python_package_dir)"; then
    end_measurement "failed"
    return 1
  fi
  echo "Installiere dbt-core aus: $dbt_package_dir"

  python3 -m venv "$TOOL_DIR/.venv"
  # shellcheck disable=SC1091
  source "$TOOL_DIR/.venv/bin/activate"
  pip install --upgrade pip setuptools wheel

  # Wichtig: Bei stabilen dbt-1.x-Tags liegt das Python-Paket im Unterordner
  # core. Der bewegliche main-Branch kann ein anderes Layout enthalten und
  # wird deshalb nicht als Standard verwendet.
  pip install -e "$dbt_package_dir"

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
