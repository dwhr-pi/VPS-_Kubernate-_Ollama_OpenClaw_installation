#!/usr/bin/env bash
set -euo pipefail

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$HELPER_DIR/../../lib/common.sh"
# shellcheck source=../../lib/resource_check.sh
source "$HELPER_DIR/../../lib/resource_check.sh"

install_apt_tool() {
  local tool_name="$1"
  shift
  local packages=("$@")
  begin_measurement "tool_install_${tool_name}" "Tool installieren: ${tool_name}"
  if ensure_user_workspace && require_disk_mb 512 / && \
     { log_info "Installiere ${tool_name} via apt: ${packages[*]}"; sudo apt-get update; sudo apt-get install -y "${packages[@]}"; }; then
    mark_tool_installed "$tool_name"
    log_success "${tool_name} installiert."
    end_measurement "success"
  else
    end_measurement "failed"
    return 1
  fi
}

uninstall_apt_tool() {
  local tool_name="$1"
  shift
  local packages=("$@")
  begin_measurement "tool_uninstall_${tool_name}" "Tool deinstallieren: ${tool_name}"
  log_info "Deinstalliere ${tool_name} via apt: ${packages[*]}"
  sudo apt-get remove -y "${packages[@]}" || true
  sudo apt-get autoremove -y || true
  mark_tool_removed "$tool_name"
  log_success "${tool_name} entfernt."
  end_measurement "success"
}

install_git_python_tool() {
  local tool_name="$1"
  local repo_url="$2"
  local install_dir="$3"
  local extra_cmd="${4:-}"
  begin_measurement "tool_install_${tool_name}" "Tool installieren: ${tool_name}"
  if ensure_user_workspace && require_disk_mb 1024 /; then
    sudo mkdir -p "$(dirname "$install_dir")"
    sudo chown -R "$USER":"$USER" "$(dirname "$install_dir")"
    if [ ! -d "$install_dir/.git" ]; then
      git clone "$repo_url" "$install_dir"
    else
      git -C "$install_dir" fetch origin --prune
      git -C "$install_dir" pull --ff-only || true
    fi
    python3 -m venv "$install_dir/.venv"
    # shellcheck disable=SC1091
    source "$install_dir/.venv/bin/activate"
    pip install --upgrade pip setuptools wheel
    if [ -f "$install_dir/pyproject.toml" ] || [ -f "$install_dir/setup.py" ]; then
      pip install -e "$install_dir"
    elif [ -f "$install_dir/requirements.txt" ]; then
      pip install -r "$install_dir/requirements.txt"
    fi
    if [ -n "$extra_cmd" ]; then
      bash -lc "source '$install_dir/.venv/bin/activate' && cd '$install_dir' && $extra_cmd"
    fi
    deactivate || true
    mark_tool_installed "$tool_name"
    log_success "${tool_name} installiert."
    end_measurement "success"
  else
    end_measurement "failed"
    return 1
  fi
}

uninstall_git_python_tool() {
  local tool_name="$1"
  local install_dir="$2"
  begin_measurement "tool_uninstall_${tool_name}" "Tool deinstallieren: ${tool_name}"
  rm -rf "$install_dir"
  mark_tool_removed "$tool_name"
  log_success "${tool_name} entfernt."
  end_measurement "success"
}

install_git_node_tool() {
  local tool_name="$1"
  local repo_url="$2"
  local install_dir="$3"
  local extra_cmd="${4:-npm install}"
  begin_measurement "tool_install_${tool_name}" "Tool installieren: ${tool_name}"
  if ensure_user_workspace && require_disk_mb 1024 /; then
    sudo mkdir -p "$(dirname "$install_dir")"
    sudo chown -R "$USER":"$USER" "$(dirname "$install_dir")"
    if [ ! -d "$install_dir/.git" ]; then
      git clone "$repo_url" "$install_dir"
    else
      git -C "$install_dir" fetch origin --prune
      git -C "$install_dir" pull --ff-only || true
    fi
    bash -lc "cd '$install_dir' && $extra_cmd"
    mark_tool_installed "$tool_name"
    log_success "${tool_name} installiert."
    end_measurement "success"
  else
    end_measurement "failed"
    return 1
  fi
}

uninstall_git_node_tool() {
  local tool_name="$1"
  local install_dir="$2"
  begin_measurement "tool_uninstall_${tool_name}" "Tool deinstallieren: ${tool_name}"
  rm -rf "$install_dir"
  mark_tool_removed "$tool_name"
  log_success "${tool_name} entfernt."
  end_measurement "success"
}

install_git_docker_tool() {
  local tool_name="$1"
  local repo_url="$2"
  local install_dir="$3"
  local compose_content="$4"
  begin_measurement "tool_install_${tool_name}" "Tool installieren: ${tool_name}"
  if ensure_user_workspace && require_disk_mb 2048 /; then
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose-plugin
    sudo systemctl enable --now docker || true
    sudo mkdir -p "$install_dir"
    sudo chown -R "$USER":"$USER" "$install_dir"
    if [ ! -d "$install_dir/source/.git" ]; then
      git clone "$repo_url" "$install_dir/source"
    else
      git -C "$install_dir/source" fetch origin --prune
      git -C "$install_dir/source" pull --ff-only || true
    fi
    printf '%s\n' "$compose_content" > "$install_dir/docker-compose.yml"
    (cd "$install_dir" && docker compose up -d)
    mark_tool_installed "$tool_name"
    log_success "${tool_name} installiert."
    end_measurement "success"
  else
    end_measurement "failed"
    return 1
  fi
}

uninstall_git_docker_tool() {
  local tool_name="$1"
  local install_dir="$2"
  begin_measurement "tool_uninstall_${tool_name}" "Tool deinstallieren: ${tool_name}"
  if [ -f "$install_dir/docker-compose.yml" ]; then
    (cd "$install_dir" && docker compose down -v) || true
  fi
  rm -rf "$install_dir"
  mark_tool_removed "$tool_name"
  log_success "${tool_name} entfernt."
  end_measurement "success"
}
