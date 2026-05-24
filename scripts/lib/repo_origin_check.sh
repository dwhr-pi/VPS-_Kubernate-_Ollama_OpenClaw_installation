#!/usr/bin/env bash
# Gemeinsame Repo-Herkunftsprüfung fuer Diagnoseberichte.
# Diese Datei repariert nichts und nimmt keine Aenderungen vor.

ORIGINAL_SETUP_REPO_URL="https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation"

normalize_git_remote_url() {
  local url="${1:-}"

  url="${url%.git}"
  url="${url#git@github.com:}"
  url="${url#https://github.com/}"
  url="${url#http://github.com/}"
  url="${url#ssh://git@github.com/}"
  url="${url%/}"
  printf '%s' "$url" | tr '[:upper:]' '[:lower:]'
}

print_repo_origin_report() {
  local repo_dir="${1:-.}"
  local expected_normalized
  local origin_url=""
  local upstream_url=""
  local origin_normalized=""
  local upstream_normalized=""
  local head_sha=""
  local branch_name=""
  local tracking_branch=""
  local status_label="unknown"

  expected_normalized="$(normalize_git_remote_url "$ORIGINAL_SETUP_REPO_URL")"

  if [ ! -d "$repo_dir/.git" ]; then
    echo "## Setup-Repo-Herkunft"
    echo
    echo "- Status: unknown"
    echo "- Hinweis: Unter \`$repo_dir\` wurde kein Git-Repository gefunden."
    echo
    return 0
  fi

  origin_url="$(git -C "$repo_dir" remote get-url origin 2>/dev/null || true)"
  upstream_url="$(git -C "$repo_dir" remote get-url upstream 2>/dev/null || true)"
  origin_normalized="$(normalize_git_remote_url "$origin_url")"
  upstream_normalized="$(normalize_git_remote_url "$upstream_url")"
  head_sha="$(git -C "$repo_dir" rev-parse --short HEAD 2>/dev/null || true)"
  branch_name="$(git -C "$repo_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  tracking_branch="$(git -C "$repo_dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"

  if [ "$origin_normalized" = "$expected_normalized" ]; then
    status_label="original"
  elif [ "$upstream_normalized" = "$expected_normalized" ]; then
    status_label="fork_with_original_upstream"
  else
    status_label="fork_or_unknown_source"
  fi

  echo "## Setup-Repo-Herkunft"
  echo
  echo "- Status: $status_label"
  echo "- Erwartetes Original: \`$ORIGINAL_SETUP_REPO_URL\`"
  echo "- origin: \`${origin_url:-nicht gesetzt}\`"
  echo "- upstream: \`${upstream_url:-nicht gesetzt}\`"
  echo "- Branch: \`${branch_name:-unbekannt}\`"
  echo "- Tracking: \`${tracking_branch:-nicht gesetzt}\`"
  echo "- HEAD: \`${head_sha:-unbekannt}\`"
  echo

  case "$status_label" in
    original)
      echo "Hinweis: Dieses Setup scheint direkt vom Original-Repository installiert zu sein."
      ;;
    fork_with_original_upstream)
      echo "Warnung: Dieses Setup scheint aus einem Fork installiert zu sein, hat aber das Original als upstream gesetzt."
      echo
      echo "Support-Hinweis: Automatische Selbstheilung via Update wird fuer Forks nicht als Reparaturgarantie angeboten, weil lokale Fork-Aenderungen vom Originalsetup nicht sicher bewertet oder ueberschrieben werden koennen."
      ;;
    *)
      echo "Warnung: Dieses Setup stammt nicht eindeutig vom Original-Repository."
      echo
      echo "Support-Hinweis: Automatische Selbstheilung via Update wird fuer Forks oder unbekannte Quellen nicht angeboten. Bitte pruefe den Fork manuell oder gleiche ihn bewusst mit dem Original ab."
      ;;
  esac
  echo
}
