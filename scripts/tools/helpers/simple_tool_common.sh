#!/usr/bin/env bash
set -euo pipefail

HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$HELPER_DIR/../../lib/common.sh"
# shellcheck source=../../lib/resource_check.sh
source "$HELPER_DIR/../../lib/resource_check.sh"
# shellcheck source=../../lib/git_target_repair.sh
source "$HELPER_DIR/../../lib/git_target_repair.sh"

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
    ensure_base_apt_packages git python3 python3-venv python3-pip python3-dev build-essential pkg-config
    sudo mkdir -p "$(dirname "$install_dir")"
    sudo chown -R "$USER":"$USER" "$(dirname "$install_dir")"
    clone_or_update_git_target "$tool_name" "$repo_url" "$install_dir"
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
    ensure_base_apt_packages git nodejs npm build-essential pkg-config
    sudo mkdir -p "$(dirname "$install_dir")"
    sudo chown -R "$USER":"$USER" "$(dirname "$install_dir")"
    clone_or_update_git_target "$tool_name" "$repo_url" "$install_dir"
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

ensure_docker_compose_available() {
  local arch
  local compose_url
  local plugin_dir="/usr/local/lib/docker/cli-plugins"

  ensure_base_apt_packages git ca-certificates curl

  if docker version >/dev/null 2>&1 || sudo docker version >/dev/null 2>&1; then
    log_info "Docker ist bereits vorhanden."
  elif apt-cache policy docker-ce 2>/dev/null | grep -q 'Candidate: [0-9]'; then
    log_warn "Docker.com-Repository erkannt. Installiere Docker Engine aus docker-ce-Paketen statt Ubuntu docker.io."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    if dpkg -s containerd.io >/dev/null 2>&1; then
      log_error "containerd.io ist installiert, aber docker-ce ist nicht als apt-Kandidat verfuegbar."
      log_error "Ubuntu docker.io wuerde mit containerd.io kollidieren. Docker wird nicht automatisch installiert."
      log_error "Bitte Docker-Repository reparieren oder Docker bewusst manuell installieren."
      return 1
    fi
    log_warn "Kein Docker.com-Repository erkannt. Verwende Ubuntu docker.io als Fallback."
    sudo apt-get update
    sudo apt-get install -y docker.io
  fi

  if docker compose version >/dev/null 2>&1 || sudo docker compose version >/dev/null 2>&1; then
    return 0
  fi

  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)
      arch="x86_64"
      ;;
    aarch64|arm64)
      arch="aarch64"
      ;;
    *)
      log_error "Docker Compose GitHub-Release fuer Architektur '$arch' ist im Installer nicht hinterlegt."
      return 1
      ;;
  esac

  compose_url="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${arch}"
  log_warn "docker-compose-plugin ist nicht auf jedem Ubuntu-Repo verfuegbar. Installiere Docker Compose als CLI-Plugin aus GitHub: ${compose_url}"
  sudo mkdir -p "$plugin_dir"
  sudo curl -fsSL "$compose_url" -o "$plugin_dir/docker-compose"
  sudo chmod 0755 "$plugin_dir/docker-compose"

  docker compose version >/dev/null 2>&1 || sudo docker compose version >/dev/null 2>&1
}

run_docker_compose() {
  if docker compose version >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    docker compose "$@"
  else
    log_warn "Docker-Daemon ist fuer den aktuellen User nicht direkt nutzbar. Verwende sudo docker compose."
    sudo docker compose "$@"
  fi
}

clone_or_update_github_source() {
  local repo_url="$1"
  local target_dir="$2"

  repair_git_target_for_clone "$target_dir" "$repo_url" "GitHub_Source"

  if [ -d "$target_dir/.git" ]; then
    if git -C "$target_dir" fetch origin --prune && git -C "$target_dir" pull --ff-only; then
      return 0
    fi
    log_warn "Git-Update fuer $target_dir fehlgeschlagen. Lokale Kopie wird neu geklont."
    rm -rf "$target_dir"
  elif [ -e "$target_dir" ]; then
    log_warn "Unvollstaendige Quelle unter $target_dir gefunden. Raeume vor neuem Clone auf."
    rm -rf "$target_dir"
  fi

  log_info "Klone Quelle aus GitHub: $repo_url"
  if git clone --depth 1 --filter=blob:none "$repo_url" "$target_dir"; then
    return 0
  fi

  log_warn "Erster Clone-Versuch fehlgeschlagen. Versuche erneut mit HTTP/1.1 gegen HTTP/2-Abbrueche."
  rm -rf "$target_dir"
  git -c http.version=HTTP/1.1 clone --depth 1 --filter=blob:none "$repo_url" "$target_dir"
}

install_git_docker_tool() {
  local tool_name="$1"
  local repo_url="$2"
  local install_dir="$3"
  local compose_content="$4"
  begin_measurement "tool_install_${tool_name}" "Tool installieren: ${tool_name}"
  if ensure_user_workspace && require_disk_mb 2048 /; then
    ensure_docker_compose_available
    sudo systemctl enable --now docker || true
    sudo mkdir -p "$install_dir"
    sudo chown -R "$USER":"$USER" "$install_dir"
    if ! clone_or_update_github_source "$repo_url" "$install_dir/source"; then
      log_error "GitHub-Clone fuer ${tool_name} ist fehlgeschlagen. Docker Compose wird nicht gestartet."
      end_measurement "failed"
      return 1
    fi
    printf '%s\n' "$compose_content" > "$install_dir/docker-compose.yml"
    (cd "$install_dir" && run_docker_compose up -d)
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
    (cd "$install_dir" && run_docker_compose down -v) || true
  fi
  rm -rf "$install_dir"
  mark_tool_removed "$tool_name"
  log_success "${tool_name} entfernt."
  end_measurement "success"
}
