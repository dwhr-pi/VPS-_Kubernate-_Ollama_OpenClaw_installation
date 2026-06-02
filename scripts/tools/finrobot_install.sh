#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="FinRobot"
INSTALL_DIR="${FINROBOT_INSTALL_DIR:-/opt/finrobot}"
REPO_URL="$(get_custom_repo_url "FINROBOT" "https://github.com/AI4Finance-Foundation/FinRobot.git")"
CPYTHON_VERSION="${FINROBOT_CPYTHON_VERSION:-3.11.9}"
CPYTHON_REPO_URL="${FINROBOT_CPYTHON_REPO_URL:-https://github.com/python/cpython.git}"
CPYTHON_BASE_DIR="${FINROBOT_CPYTHON_BASE_DIR:-/opt/openclaw-python}"
CPYTHON_PREFIX="${CPYTHON_BASE_DIR}/python-${CPYTHON_VERSION}"
CPYTHON_BIN="${CPYTHON_PREFIX}/bin/python3.11"
FINROBOT_MIN_LINUX_FREE_MB="${FINROBOT_MIN_LINUX_FREE_MB:-20480}"
FINROBOT_MIN_WINDOWS_FREE_MB="${FINROBOT_MIN_WINDOWS_FREE_MB:-20480}"
FINROBOT_RECOMMENDED_WINDOWS_FREE_MB="${FINROBOT_RECOMMENDED_WINDOWS_FREE_MB:-51200}"
FINROBOT_PIP_NO_CACHE="${FINROBOT_PIP_NO_CACHE:-true}"
FINROBOT_PREINSTALL_CPU_TORCH="${FINROBOT_PREINSTALL_CPU_TORCH:-true}"

usage() {
  cat <<'USAGE'
FinRobot Installer

FinRobot benoetigt Python >=3.10 und <3.12. Ubuntu 24.04 liefert standardmaessig
Python 3.12; damit bricht FinRobot beim pip-Build mit
"requires a different Python: 3.12.x not in '<3.12,>=3.10'" ab.

Optionen:
  --check      Nur Python-Kompatibilitaet und vorhandene Installation pruefen.
  --dry-run    Anzeigen, was installiert wuerde.
  --help       Hilfe anzeigen.

Umgebungsvariablen:
  FINROBOT_PYTHON_BIN   Expliziter Python-Pfad, z. B. /usr/bin/python3.11
  FINROBOT_INSTALL_DIR  Installationsziel, Standard: /opt/finrobot
  FINROBOT_REPO_URL     Alternative GitHub-Quelle
  FINROBOT_CPYTHON_VERSION  CPython-Version fuer lokalen Build, Standard: 3.11.9
  FINROBOT_CPYTHON_BASE_DIR Build-/Installationsbasis, Standard: /opt/openclaw-python
  FINROBOT_MIN_LINUX_FREE_MB   Mindestfreier Linux-/WSL-Speicher, Standard: 20480
  FINROBOT_MIN_WINDOWS_FREE_MB Mindestfreier Windows-C:-Speicher bei WSL, Standard: 20480
  FINROBOT_PREINSTALL_CPU_TORCH CPU-only PyTorch vorinstallieren, Standard: true
USAGE
}

log_finrobot() {
  printf '%s\n' "$*"
}

ensure_sudo_ready_for_long_build() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    run_cmd sudo -v >&2
    return 0
  fi

  log_finrobot "Pruefe sudo-Berechtigung vor dem langen CPython-Build." >&2
  log_finrobot "Hinweis: Wenn das Passwort falsch eingegeben wird, bricht der Installer jetzt sofort ab und nicht erst nach dem Build." >&2
  if ! sudo -v; then
    log_finrobot "Fehler: sudo-Authentifizierung fehlgeschlagen. Bitte Tastaturlayout/CapsLock pruefen und erneut starten." >&2
    return 1
  fi
}

python_version_ok() {
  "$1" - <<'PY'
import sys
raise SystemExit(0 if (3, 10) <= sys.version_info < (3, 12) else 1)
PY
}

python_version_text() {
  "$1" - <<'PY'
import sys
print(".".join(map(str, sys.version_info[:3])))
PY
}

find_compatible_python() {
  local candidate
  if [ -n "${FINROBOT_PYTHON_BIN:-}" ]; then
    if command -v "$FINROBOT_PYTHON_BIN" >/dev/null 2>&1 && python_version_ok "$FINROBOT_PYTHON_BIN"; then
      printf '%s\n' "$FINROBOT_PYTHON_BIN"
      return 0
    fi
    log_finrobot "Fehler: FINROBOT_PYTHON_BIN ist gesetzt, aber nicht kompatibel: $FINROBOT_PYTHON_BIN" >&2
    return 1
  fi

  for candidate in python3.11 python3.10; do
    if command -v "$candidate" >/dev/null 2>&1 && python_version_ok "$candidate"; then
      command -v "$candidate"
      return 0
    fi
  done

  return 1
}

print_python_help() {
  local default_version="unbekannt"
  if command -v python3 >/dev/null 2>&1; then
    default_version="$(python_version_text python3 2>/dev/null || true)"
  fi

  cat <<EOF
Fehler: Kein kompatibles Python fuer FinRobot gefunden.

FinRobot benoetigt Python >=3.10 und <3.12.
Gefundenes Standard-python3: ${default_version}

Ubuntu 24.04/Noble nutzt standardmaessig Python 3.12. Das ist fuer FinRobot
aktuell nicht kompatibel. Bitte installiere oder verwende Python 3.10/3.11
und starte danach z. B.:

  FINROBOT_PYTHON_BIN=/usr/bin/python3.11 bash scripts/tools/finrobot_install.sh

Keine automatische Installation von Fremd-Python wird vorgenommen, damit das
System-Python nicht beschaedigt wird.
EOF
}

print_python_build_notice() {
  local default_version="unbekannt"
  if command -v python3 >/dev/null 2>&1; then
    default_version="$(python_version_text python3 2>/dev/null || true)"
  fi

  cat <<EOF
Kein vorhandenes kompatibles Python fuer FinRobot gefunden.

FinRobot benoetigt Python >=3.10 und <3.12.
Gefundenes Standard-python3: ${default_version}

Das Setup baut jetzt ein isoliertes CPython ${CPYTHON_VERSION} aus GitHub und
installiert es unter:

  ${CPYTHON_PREFIX}

/usr/bin/python3 bleibt unveraendert.
EOF
}

build_local_cpython() {
  local src_dir="${CPYTHON_BASE_DIR}/src/cpython-${CPYTHON_VERSION}"
  local jobs
  jobs="$(nproc 2>/dev/null || printf '2')"

  log_finrobot "Kein kompatibles Python gefunden. Baue isoliertes CPython ${CPYTHON_VERSION} fuer FinRobot." >&2
  log_finrobot "Quelle: ${CPYTHON_REPO_URL} Tag v${CPYTHON_VERSION}" >&2
  log_finrobot "Ziel:   ${CPYTHON_PREFIX}" >&2
  log_finrobot "Hinweis: Das System-Python wird nicht ersetzt." >&2

  if [ "${DRY_RUN:-0}" = "1" ]; then
    run_cmd ensure_base_apt_packages git build-essential pkg-config libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev uuid-dev >&2
    run_cmd sudo -v >&2
    run_cmd sudo mkdir -p "$CPYTHON_BASE_DIR/src" >&2
    run_cmd sudo chown -R "$USER:$USER" "$CPYTHON_BASE_DIR" >&2
    run_cmd git clone --depth 1 --branch "v${CPYTHON_VERSION}" "$CPYTHON_REPO_URL" "$src_dir" >&2
    run_cmd bash -lc "cd '$src_dir' && ./configure --prefix='$CPYTHON_PREFIX' --with-ensurepip=install" >&2
    run_cmd bash -lc "cd '$src_dir' && make -j '$jobs'" >&2
    run_cmd bash -lc "cd '$src_dir' && make altinstall" >&2
    printf '%s\n' "$CPYTHON_BIN"
    return 0
  fi

  ensure_base_apt_packages git build-essential pkg-config libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev uuid-dev >&2
  ensure_sudo_ready_for_long_build
  sudo mkdir -p "$CPYTHON_BASE_DIR/src" >&2
  sudo chown -R "$USER":"$USER" "$CPYTHON_BASE_DIR" >&2

  if [ -x "$CPYTHON_BIN" ] && python_version_ok "$CPYTHON_BIN"; then
    log_finrobot "Isoliertes CPython ist bereits vorhanden: $CPYTHON_BIN ($(python_version_text "$CPYTHON_BIN"))" >&2
    printf '%s\n' "$CPYTHON_BIN"
    return 0
  fi

  if [ ! -d "$src_dir/.git" ]; then
    git clone --depth 1 --branch "v${CPYTHON_VERSION}" "$CPYTHON_REPO_URL" "$src_dir" >&2
  else
    git -C "$src_dir" fetch --depth 1 origin "v${CPYTHON_VERSION}" >&2
    git -C "$src_dir" checkout "v${CPYTHON_VERSION}" >&2
  fi

  (
    cd "$src_dir"
    ./configure --prefix="$CPYTHON_PREFIX" --with-ensurepip=install
    make -j "$jobs"
    make altinstall
  ) >&2

  if ! [ -x "$CPYTHON_BIN" ] || ! python_version_ok "$CPYTHON_BIN"; then
    log_finrobot "Fehler: Gebautes CPython ist nicht nutzbar oder nicht kompatibel: $CPYTHON_BIN" >&2
    return 1
  fi

  printf '%s\n' "$CPYTHON_BIN"
}

run_cmd() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    printf '[dry-run] %q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

free_mb_for_path() {
  df -Pm "${1:-/}" 2>/dev/null | awk 'NR==2 {print $4}'
}

is_wsl2() {
  grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

require_min_free_mb() {
  local label="$1"
  local actual="$2"
  local required="$3"

  if [ -z "${actual:-}" ]; then
    log_finrobot "Warnung: ${label} konnte nicht ermittelt werden."
    return 0
  fi

  if [ "$actual" -lt "$required" ]; then
    log_finrobot "Fehler: ${label} ist zu niedrig fuer FinRobot."
    log_finrobot "${label}: ${actual} MB frei, erforderlich: ${required} MB."
    log_finrobot "FinRobot zieht viele Python-/ML-Abhaengigkeiten. Bei zu wenig Speicher endet pip oft mit Input/output error."
    return 1
  fi
}

preflight_finrobot_resources() {
  local linux_free_mb
  local windows_free_mb

  linux_free_mb="$(free_mb_for_path / || true)"
  log_finrobot "Freier Linux-/WSL-Speicher: ${linux_free_mb:-unbekannt} MB"
  require_min_free_mb "Linux-/WSL-Speicher" "${linux_free_mb:-}" "$FINROBOT_MIN_LINUX_FREE_MB"

  if is_wsl2 && [ -d /mnt/c ]; then
    windows_free_mb="$(free_mb_for_path /mnt/c || true)"
    log_finrobot "Freier Windows-Host-Speicher (C:): ${windows_free_mb:-unbekannt} MB"
    require_min_free_mb "Windows-C:-Speicher" "${windows_free_mb:-}" "$FINROBOT_MIN_WINDOWS_FREE_MB"
    if [ -n "${windows_free_mb:-}" ] && [ "$windows_free_mb" -lt "$FINROBOT_RECOMMENDED_WINDOWS_FREE_MB" ]; then
      log_finrobot "Warnung: Empfohlen sind ${FINROBOT_RECOMMENDED_WINDOWS_FREE_MB} MB Windows-C:-Speicher, damit WSL-VHDX, pip und ML-Wheels nicht kollidieren."
    fi
  fi
}

preinstall_cpu_torch_if_safe() {
  local arch
  arch="$(uname -m)"

  if [ "$FINROBOT_PREINSTALL_CPU_TORCH" != "true" ]; then
    log_finrobot "CPU-only PyTorch Vorinstallation wurde deaktiviert."
    return 0
  fi

  case "$arch" in
    x86_64|amd64)
      log_finrobot "Installiere CPU-only PyTorch vorab, damit pip keine grossen CUDA-/NVIDIA-Wheels fuer FinRobot zieht."
      pip install --index-url https://download.pytorch.org/whl/cpu torch
      ;;
    *)
      log_finrobot "Warnung: CPU-only PyTorch Vorinstallation ist fuer Architektur '$arch' nicht automatisch hinterlegt."
      log_finrobot "Der Installer faehrt fort, kann aber je nach pip-Aufloesung grosse ML-Abhaengigkeiten laden."
      ;;
  esac
}

main() {
  local mode="install"
  DRY_RUN=0

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --check|--status)
        mode="check"
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log_finrobot "Unbekannte Option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [ "$mode" = "check" ]; then
    local check_python_bin=""
    if ! check_python_bin="$(find_compatible_python)"; then
      print_python_help >&2
      exit 1
    fi
    log_finrobot "FinRobot-kompatibles Python gefunden: $check_python_bin ($(python_version_text "$check_python_bin"))"
    if [ -x "$INSTALL_DIR/.venv/bin/python" ]; then
      log_finrobot "FinRobot-Venv vorhanden: $INSTALL_DIR/.venv"
    else
      log_finrobot "FinRobot ist noch nicht installiert."
    fi
    exit 0
  fi

  begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"

  if ! ensure_user_workspace || ! require_disk_mb "$FINROBOT_MIN_LINUX_FREE_MB" / || ! preflight_finrobot_resources; then
    end_measurement "failed"
    return 1
  fi

  local python_bin=""
  if ! python_bin="$(find_compatible_python)"; then
    print_python_build_notice
    if ! python_bin="$(build_local_cpython)"; then
      end_measurement "failed"
      return 1
    fi
  fi

  log_finrobot "FinRobot-kompatibles Python wird verwendet: $python_bin ($(python_version_text "$python_bin" 2>/dev/null || printf 'dry-run'))"

  ensure_base_apt_packages git build-essential pkg-config

  log_finrobot "Installiere FinRobot aus GitHub: $REPO_URL"
  log_finrobot "Ziel: $INSTALL_DIR"

  if [ "$DRY_RUN" = "1" ]; then
    run_cmd sudo mkdir -p "$(dirname "$INSTALL_DIR")"
    run_cmd git clone "$REPO_URL" "$INSTALL_DIR"
    run_cmd "$python_bin" -m venv "$INSTALL_DIR/.venv"
    run_cmd "$INSTALL_DIR/.venv/bin/pip" install --upgrade pip setuptools wheel
    run_cmd "$INSTALL_DIR/.venv/bin/pip" install -e "$INSTALL_DIR"
    end_measurement "success"
    exit 0
  fi

  sudo mkdir -p "$(dirname "$INSTALL_DIR")"
  sudo chown -R "$USER":"$USER" "$(dirname "$INSTALL_DIR")"

  if [ ! -d "$INSTALL_DIR/.git" ]; then
    git clone "$REPO_URL" "$INSTALL_DIR"
  else
    git -C "$INSTALL_DIR" fetch origin --prune
    git -C "$INSTALL_DIR" pull --ff-only || true
  fi

  "$python_bin" -m venv "$INSTALL_DIR/.venv"
  # shellcheck disable=SC1091
  source "$INSTALL_DIR/.venv/bin/activate"
  if [ "$FINROBOT_PIP_NO_CACHE" = "true" ]; then
    export PIP_NO_CACHE_DIR=1
  fi
  pip install --upgrade pip setuptools wheel
  preinstall_cpu_torch_if_safe
  pip install -e "$INSTALL_DIR"
  deactivate || true

  mark_tool_installed "$TOOL_NAME"
  log_success "${TOOL_NAME} installiert."
  end_measurement "success"
}

main "$@"
