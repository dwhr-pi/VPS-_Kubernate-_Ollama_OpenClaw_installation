#!/usr/bin/env bash
# Gemeinsame Schutzlogik fuer Git-basierte Tool-Installer.
# Repariert abgebrochene Clones, ohne Inhalte blind zu loeschen.

setup_repair_backup_root() {
  printf '%s\n' "${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/setup_repair_backups"
}

backup_broken_git_target() {
  local target_dir="$1"
  local reason="$2"
  local tool_name="${3:-tool}"
  local backup_root backup_dir timestamp safe_tool

  timestamp="$(date +%Y%m%d_%H%M%S)"
  safe_tool="$(printf '%s' "$tool_name" | tr -c 'A-Za-z0-9_.-' '_')"
  backup_root="$(setup_repair_backup_root)"
  backup_dir="${backup_root}/${safe_tool}_${timestamp}"

  mkdir -p "$backup_root"
  printf 'Hinweis: Sichere problematischen Git-Zielordner wegen: %s\n' "$reason"
  printf '  Quelle: %s\n' "$target_dir"
  printf '  Backup: %s\n' "$backup_dir"
  mv "$target_dir" "$backup_dir"
}

repair_git_target_for_clone() {
  local target_dir="$1"
  local expected_repo_url="$2"
  local tool_name="${3:-tool}"
  local origin_url=""

  if [ ! -e "$target_dir" ]; then
    return 0
  fi

  if [ -d "$target_dir/.git" ]; then
    origin_url="$(git -C "$target_dir" remote get-url origin 2>/dev/null || true)"
    if [ -n "$expected_repo_url" ] && [ -n "$origin_url" ] && [ "$origin_url" != "$expected_repo_url" ]; then
      backup_broken_git_target "$target_dir" "Git-Origin passt nicht (${origin_url} != ${expected_repo_url})" "$tool_name"
    fi
    return 0
  fi

  if [ -d "$target_dir" ] && [ -z "$(find "$target_dir" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
    printf 'Hinweis: Entferne leeren Zielordner nach abgebrochenem Clone: %s\n' "$target_dir"
    rmdir "$target_dir"
    return 0
  fi

  backup_broken_git_target "$target_dir" "Ziel existiert, ist aber kein Git-Repository" "$tool_name"
}

clone_or_update_git_target() {
  local tool_name="$1"
  local repo_url="$2"
  local target_dir="$3"

  repair_git_target_for_clone "$target_dir" "$repo_url" "$tool_name"

  if [ -d "$target_dir/.git" ]; then
    if GIT_TERMINAL_PROMPT=0 git -C "$target_dir" fetch origin --prune && \
       GIT_TERMINAL_PROMPT=0 git -C "$target_dir" pull --ff-only; then
      return 0
    fi
    backup_broken_git_target "$target_dir" "Git-Update fehlgeschlagen" "$tool_name"
  fi

  printf 'Klone %s aus GitHub: %s\n' "$tool_name" "$repo_url"
  GIT_TERMINAL_PROMPT=0 git clone "$repo_url" "$target_dir"
}

