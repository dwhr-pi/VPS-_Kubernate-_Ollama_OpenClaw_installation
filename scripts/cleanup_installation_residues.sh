#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

APPLY=false
CLEAN_APT=false
CLEAN_DOCKER=false
CLEAN_DOCKER_VOLUMES=false
CLEAN_CACHES=false
CLEAN_OPT_TOOLS=false
SHOW_OPT=true
YES=false

usage() {
  cat <<'EOF'
Installationsreste sicher aufraeumen.

Standard: Trockenlauf, es wird nichts geloescht.

Optionen:
  --dry-run              Nur anzeigen, was bereinigt werden koennte
  --apply                Bereinigung ausfuehren, fragt zur Sicherheit nach
  --yes                  Nachfrage bei --apply ueberspringen
  --all                  Apt, Docker und Paket-Caches pruefen/bereinigen
  --apt                  apt autoremove/autoclean ausfuehren
  --docker               Docker-Container, dangling Images und Build-Cache bereinigen
  --docker-volumes       Docker-Volumes bereinigen (riskant, nur explizit)
  --caches               Paket-/Build-Caches im Home-Verzeichnis bereinigen
  --opt-tools            Bekannte /opt-Toolreste einzeln per Ja/Nein entfernen
  --no-opt-report        /opt-Verzeichnisgroessen nicht anzeigen
  -h, --help             Hilfe anzeigen

Empfohlen:
  bash scripts/cleanup_installation_residues.sh --dry-run --all
  bash scripts/cleanup_installation_residues.sh --apply --all
  bash scripts/cleanup_installation_residues.sh --apply --opt-tools
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) APPLY=false ;;
    --apply) APPLY=true ;;
    --yes) YES=true ;;
    --all)
      CLEAN_APT=true
      CLEAN_DOCKER=true
      CLEAN_CACHES=true
      ;;
    --apt) CLEAN_APT=true ;;
    --docker) CLEAN_DOCKER=true ;;
    --docker-volumes) CLEAN_DOCKER=true; CLEAN_DOCKER_VOLUMES=true ;;
    --caches) CLEAN_CACHES=true ;;
    --opt-tools) CLEAN_OPT_TOOLS=true ;;
    --no-opt-report) SHOW_OPT=false ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unbekannte Option: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if ! $CLEAN_APT && ! $CLEAN_DOCKER && ! $CLEAN_CACHES && ! $CLEAN_OPT_TOOLS; then
  CLEAN_APT=true
  CLEAN_DOCKER=true
  CLEAN_CACHES=true
fi

ensure_user_workspace
USER_DIAGNOSTIC_DIR="${USER_DIAGNOSTIC_DIR:-${USER_WORKSPACE_DIR}/diagnostic_reports}"
mkdir -p "$USER_DIAGNOSTIC_DIR"
REPORT_FILE="$USER_DIAGNOSTIC_DIR/$(date +%Y%m%d_%H%M%S)_cleanup_installation_residues.md"

write_report() {
  printf '%s\n' "$*" >>"$REPORT_FILE"
}

run_or_show() {
  local label="$1"
  shift
  echo
  echo "==> $label"
  printf '    %q' "$@"
  echo
  write_report ""
  write_report "### $label"
  write_report '```bash'
  write_report "$*"
  write_report '```'

  if $APPLY; then
    "$@"
  else
    echo "    Trockenlauf: nicht ausgefuehrt."
  fi
}

confirm_step() {
  local prompt="$1"
  local answer

  if ! $APPLY || $YES; then
    return 0
  fi

  read -r -p "$prompt [j/N]: " answer
  case "${answer,,}" in
    j|ja|y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

cache_dir_size() {
  local dir="$1"
  if [ -e "$dir" ]; then
    du -sh "$dir" 2>/dev/null | awk '{print $1}'
  else
    echo "-"
  fi
}

remove_cache_dir() {
  local dir="$1"
  case "$dir" in
    "$HOME"/.cache/*|"$HOME"/.npm/*|"$HOME"/.local/share/pnpm/*|"$HOME"/.pnpm-store|"$HOME"/.bun/install/cache|"$HOME"/.cargo/registry|"$HOME"/.cargo/git)
      if [ -e "$dir" ]; then
        if confirm_step "Cache wirklich entfernen: $dir ($(cache_dir_size "$dir"))?"; then
          run_or_show "Cache entfernen: $dir ($(cache_dir_size "$dir"))" rm -rf "$dir"
        else
          echo "    Uebersprungen: $dir"
        fi
      fi
      ;;
    *)
      echo "Ueberspringe unsicheren Cache-Pfad: $dir"
      ;;
  esac
}

remove_opt_tool_dir() {
  local dir="$1"

  case "$dir" in
    /opt/containerd|/opt/clawhub|/opt/bun|/opt/actionlint|/opt/comfyui|/opt/autogpt|/opt/aider|/opt/airbyte|/opt/openmanus|/opt/activepieces|/opt/apache_tika|/opt/kimi2|/opt/ruflo)
      if [ -e "$dir" ]; then
        if confirm_step "/opt-Toolrest wirklich entfernen: $dir ($(cache_dir_size "$dir"))?"; then
          run_or_show "/opt-Toolrest entfernen: $dir ($(cache_dir_size "$dir"))" sudo rm -rf "$dir"
        else
          echo "    Uebersprungen: $dir"
        fi
      fi
      ;;
    *)
      echo "Ueberspringe unsicheren /opt-Pfad: $dir"
      ;;
  esac
}

docker_base_cmd() {
  if docker info >/dev/null 2>&1; then
    echo "docker"
    return 0
  fi
  if command -v sudo >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1; then
    echo "sudo docker"
    return 0
  fi
  return 1
}

confirm_apply() {
  if ! $APPLY || $YES; then
    return 0
  fi

  echo
  echo "Sicherheitsabfrage: Diese Bereinigung kann Paket-Caches, Docker-Zwischenimages und ungenutzte Abhaengigkeiten entfernen."
  echo "Modelle und Projektordner werden NICHT geloescht."
  echo "/opt-Tool-Verzeichnisse werden nur mit --opt-tools und jeweils eigener Ja/Nein-Abfrage geloescht."
  read -r -p "Tippe BEREINIGEN zum Fortfahren: " answer
  if [ "$answer" != "BEREINIGEN" ]; then
    echo "Abgebrochen. Es wurde nichts geloescht."
    exit 0
  fi
}

main() {
  local free_before free_after
  free_before="$(snapshot_disk_mb /)"

  {
    echo "# Installationsreste bereinigen"
    echo
    echo "- Zeitpunkt: $(date -Is)"
    echo "- Modus: $($APPLY && echo apply || echo dry-run)"
    echo "- Freier Linux-/WSL-Speicher vorher: ${free_before} MB"
  } >"$REPORT_FILE"

  echo "Installationsreste bereinigen"
  echo "Report: $REPORT_FILE"
  echo "Freier Linux-/WSL-Speicher vorher: ${free_before} MB"
  if is_command_available df && [ -d /mnt/c ]; then
    df -h /mnt/c 2>/dev/null | awk 'NR==2 {print "Freier Windows-Host-Speicher C:: " $4}'
  fi

  confirm_apply

  if $CLEAN_APT; then
    if command -v apt-get >/dev/null 2>&1; then
      run_or_show "Nicht mehr benoetigte apt-Abhaengigkeiten entfernen" sudo apt-get autoremove -y
      run_or_show "apt Download-Cache bereinigen" sudo apt-get autoclean
    else
      echo "apt-get nicht vorhanden, apt-Bereinigung uebersprungen."
    fi
  fi

  if $CLEAN_DOCKER; then
    if docker_cmd="$(docker_base_cmd)"; then
      echo
      echo "Docker Speicheruebersicht:"
      # shellcheck disable=SC2086
      $docker_cmd system df || true
      # shellcheck disable=SC2086
      run_or_show "Docker gestoppte Container bereinigen" $docker_cmd container prune -f
      # shellcheck disable=SC2086
      run_or_show "Docker dangling Images bereinigen" $docker_cmd image prune -f
      # shellcheck disable=SC2086
      run_or_show "Docker Build-Cache bereinigen" $docker_cmd builder prune -f
      if $CLEAN_DOCKER_VOLUMES; then
        # shellcheck disable=SC2086
        run_or_show "Docker ungenutzte Volumes bereinigen (riskant)" $docker_cmd volume prune -f
      else
        echo "Docker-Volumes werden bewusst nicht geloescht. Fuer Volumes: --docker-volumes explizit setzen."
      fi
    else
      echo "Docker ist nicht nutzbar oder nicht installiert, Docker-Bereinigung uebersprungen."
    fi
  fi

  if $CLEAN_CACHES; then
    echo
    echo "Paket-/Build-Caches im Home-Verzeichnis:"
    local caches=(
      "$HOME/.cache/pip"
      "$HOME/.npm/_cacache"
      "$HOME/.pnpm-store"
      "$HOME/.local/share/pnpm/store"
      "$HOME/.cache/yarn"
      "$HOME/.cache/bun"
      "$HOME/.bun/install/cache"
      "$HOME/.cache/go-build"
      "$HOME/.cargo/registry"
      "$HOME/.cargo/git"
    )
    local cache
    for cache in "${caches[@]}"; do
      echo "  - $cache: $(cache_dir_size "$cache")"
      remove_cache_dir "$cache"
    done

    echo
    echo "Nicht automatisch geloescht: Ollama-Modelle, HuggingFace-Modelle, Projektordner und /opt-Tools."
  fi

  if $CLEAN_OPT_TOOLS; then
    echo
    echo "Bekannte /opt-Toolreste:"
    echo "Docker-Volumes werden bewusst nicht geloescht. Fuer Volumes: --docker-volumes explizit setzen."
    write_report ""
    write_report "## Bekannte /opt-Toolreste"
    local opt_dirs=(
      "/opt/containerd"
      "/opt/clawhub"
      "/opt/bun"
      "/opt/actionlint"
      "/opt/comfyui"
      "/opt/autogpt"
      "/opt/aider"
      "/opt/airbyte"
      "/opt/openmanus"
      "/opt/activepieces"
      "/opt/apache_tika"
      "/opt/kimi2"
      "/opt/ruflo"
    )
    local opt_dir
    for opt_dir in "${opt_dirs[@]}"; do
      echo "  - $opt_dir: $(cache_dir_size "$opt_dir")"
      write_report "- $opt_dir: $(cache_dir_size "$opt_dir")"
      remove_opt_tool_dir "$opt_dir"
    done
  fi

  if $SHOW_OPT && [ -d /opt ]; then
    echo
    echo "Groesse bekannter /opt-Verzeichnisse (nur Bericht, keine Loeschung):"
    write_report ""
    write_report "## /opt-Verzeichnisse"
    du -sh /opt/* 2>/dev/null | sort -h | tail -n 30 | tee -a "$REPORT_FILE" || true
  fi

  free_after="$(snapshot_disk_mb /)"
  echo
  echo "Freier Linux-/WSL-Speicher nachher: ${free_after} MB"
  write_report ""
  write_report "- Freier Linux-/WSL-Speicher nachher: ${free_after} MB"
}

main "$@"
