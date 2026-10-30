#!/usr/bin/env bash
set -euo pipefail
HFD_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
HFD_URL=https://github.com/huggingface/datasets.git
HFD_COMMIT=efe6ea4f88260b1a5066f28a9c90d82365a29f42
HFD_VERSION=5.1.0

hfd_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$HFD_ROOT/"*)
    echo 'HF-Datasets-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  HFD_BASE="$root/tools/hf_datasets"
  HFD_SOURCE="$HFD_BASE/source"
  HFD_VENV="$HFD_BASE/venv"
  HFD_MARKER="$HFD_BASE/source-built"
  HFD_LOGS="$root/install_logs"
  HFD_PYTHON="${HF_DATASETS_PYTHON_BIN:-python3}"
  # Standard venv Python symlinks are allowed, not redirecting directories.
  for path in "$root" "$HFD_BASE" "$HFD_SOURCE" "$HFD_SOURCE/.git" "$HFD_VENV" "$HFD_VENV/bin" "$HFD_MARKER" "$HFD_LOGS" "$HFD_BASE/operation.lock"; do
    [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
      echo 'HF Datasets: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
  done
}

hfd_source_ok() {
  [[ -d "$HFD_SOURCE/.git" ]] &&
    [[ "$(git -C "$HFD_SOURCE" rev-parse --show-toplevel)" == "$HFD_SOURCE" ]] &&
    [[ "$(git -C "$HFD_SOURCE" remote get-url origin)" == "$HFD_URL" ]] &&
    [[ "$(git -C "$HFD_SOURCE" rev-parse HEAD)" == "$HFD_COMMIT" ]] &&
    [[ -z "$(git -C "$HFD_SOURCE" status --porcelain --untracked-files=all)" ]]
}

hfd_metadata() {
  "$HFD_VENV/bin/python" -I -B -c \
    'from importlib.metadata import version; assert version("datasets") == "5.1.0"'
}

hfd_probe() {
  [[ -f "$HFD_MARKER" && "$(<"$HFD_MARKER")" == "$HFD_COMMIT base" && -x "$HFD_VENV/bin/python" ]] || return 1
  hfd_source_ok && hfd_metadata && "$HFD_VENV/bin/python" -I -B -m pip --isolated check
}

hfd_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'HF Datasets: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$HFD_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,14)' || {
    echo 'HF Datasets: vorhandenes Python 3.10-3.13 verwenden; Ubuntu-Python 3.12 passt.' >&2
    return 1
  }
  [[ ! -e "$HFD_VENV" || -f "$HFD_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
}

hfd_resources() {
  local mount="$HFD_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$HFD_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 2048
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 1024 ]] || {
    echo 'HF Datasets: mindestens 1024 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=4096 require_disk_mb 4096 "$mount"
}

hfd_prepare_python() (
  # Reuse existing narrowly scoped Ubuntu/Debian ensurepip repair in isolation.
  # shellcheck source=agent_framework_common.sh
  source "$HFD_ROOT/scripts/tools/helpers/agent_framework_common.sh"
  AGENT_FRAMEWORK_AUTO_VENV="${HF_DATASETS_AUTO_VENV:-1}" af_prepare_venv "$HFD_PYTHON"
)

hfd_fetch() {
  if [[ -e "$HFD_SOURCE" ]]; then
    hfd_source_ok || {
      echo 'HF-Datasets-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$HFD_SOURCE"
    git -C "$HFD_SOURCE" remote add origin "$HFD_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$HFD_SOURCE" fetch --depth 1 origin "$HFD_COMMIT"
    git -c core.hooksPath=/dev/null -C "$HFD_SOURCE" checkout --detach FETCH_HEAD
  fi
  hfd_source_ok || return 1
  [[ -f "$HFD_SOURCE/setup.py" && -f "$HFD_SOURCE/src/datasets/__init__.py" ]] || {
    echo 'Erwartetes HF-Datasets-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

hfd_install_package() {
  rm -f -- "$HFD_MARKER"
  "$HFD_PYTHON" -I -B -m venv "$HFD_VENV"
  # GitHub supplies datasets itself; PyPI supplies build/runtime dependencies only.
  "$HFD_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --disable-pip-version-check --index-url https://pypi.org/simple \
    --only-binary=pyarrow,numpy,pandas "$HFD_SOURCE"
  "$HFD_VENV/bin/python" -I -B -m pip --isolated check
  hfd_metadata
  hfd_source_ok || return 1
  printf '%s\n' "$HFD_COMMIT base" >"$HFD_MARKER"
  echo 'HF Datasets aus GitHub in privater venv installiert. Keine Datensaetze, Modelle, Decoder oder Trainingsjobs gestartet.'
}

hfd_deactivate() {
  rm -f -- "$HFD_MARKER"
  echo 'HF-Datasets-Setup-Marker deaktiviert; Quelle, venv, Datensaetze, Cache, Token und Logs bleiben erhalten.'
}

hf_datasets_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" program log
  hfd_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "HF Datasets $HFD_VERSION: GitHub $HFD_URL; Commit $HFD_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 2 GiB gesamt, 1 GiB verfuegbar, 4 GiB Disk/Windows-C:. Keine Decoder-/Training-Extras.'
      echo 'Dry-Run ohne Download, Installation, Datensatz-/Token-/Trainingszugriff.'
      return 0
      ;;
    status | --status)
      if hfd_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","datasets_checked":false,"training_enabled":false}'
      else echo '{"installed":false,"scope":"github-base-package","datasets_checked":false,"training_enabled":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      hfd_probe || {
        echo 'HF Datasets fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Commit und Paketmetadaten konsistent. Kein datasets-Import, Hub-/Dataset-/Decoder- oder Trainingstest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'HF Datasets: nur Paketverwaltung, kein Download-/Login-/Trainingstart.' >&2
      return 2
      ;;
  esac
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "HF Datasets: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$HFD_PYTHON" >/dev/null || {
      echo 'HF Datasets: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    hfd_preflight || return 1
    if [[ "$mode" == install ]] && hfd_probe >/dev/null 2>&1; then
      echo 'HF-Datasets-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    hfd_resources || return 1
  elif [[ ! -d "$HFD_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$HFD_BASE" "$HFD_LOGS"
  exec 9>"$HFD_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere HF-Datasets-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$HFD_LOGS/hf_datasets_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "HF-Datasets-Installer: 2026-10-16-github-base-package; Aktion: $mode; Pin: $HFD_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "HF-Datasets-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    hfd_deactivate
    return 0
  fi
  hfd_prepare_python
  hfd_fetch
  df -Pk "$HFD_BASE"
  hfd_install_package
  df -Pk "$HFD_BASE"
)
