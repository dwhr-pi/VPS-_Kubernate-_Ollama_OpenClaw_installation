#!/usr/bin/env bash
set -euo pipefail
BP_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
BP_URL=https://github.com/spotify/basic-pitch.git
BP_COMMIT=9991303bba609a3b93089d13ec80d1d495083596
BP_VERSION=0.4.0

bp_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$BP_ROOT/"*)
    echo 'Basic Pitch-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  BP_BASE="$root/tools/basic_pitch"
  BP_SOURCE="$BP_BASE/source"
  BP_VENV="$BP_BASE/venv"
  BP_MARKER="$BP_BASE/source-built"
  BP_LOGS="$root/install_logs"
  BP_PYTHON="${BASIC_PITCH_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$BP_BASE" "$BP_SOURCE" "$BP_SOURCE/.git" "$BP_VENV" "$BP_VENV/bin" "$BP_VENV/pyvenv.cfg" "$BP_MARKER" "$BP_LOGS" "$BP_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Basic Pitch: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

bp_source_ok() {
  local top state
  [[ -d "$BP_SOURCE/.git" && ! -e "$BP_SOURCE/.env" && ! -L "$BP_SOURCE/.env" ]] || return 1
  top="$(git -C "$BP_SOURCE" rev-parse --show-toplevel)" || return 1
  state="$(git -C "$BP_SOURCE" status --porcelain --untracked-files=all)" || return 1
  [[ "$top" -ef "$BP_SOURCE" &&
    "$(git -C "$BP_SOURCE" remote get-url origin)" == "$BP_URL" &&
    "$(git -C "$BP_SOURCE" rev-parse HEAD)" == "$BP_COMMIT" &&
    -z "$state" ]]
}

bp_metadata() {
  "$BP_VENV/bin/python" -I -B - "$BP_SOURCE" "$BP_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("basic-pitch")
assert d.version == "0.4.0"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('basic_pitch 0.4.0 / Basic Pitch: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

bp_probe() {
  [[ -f "$BP_MARKER" && -x "$BP_VENV/bin/python" ]] || return 1
  local flavor
  flavor="$(<"$BP_MARKER")"
  [[ "$flavor" == "$BP_COMMIT base" || "$flavor" == "$BP_COMMIT runtime" ]] || return 1
  bp_source_ok && bp_metadata || return 1
  if [[ "$flavor" == "$BP_COMMIT runtime" ]]; then
    "$BP_VENV/bin/python" -I -B -m pip --isolated check || return 1
  fi
}

bp_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'Basic Pitch: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$BP_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,13)' || {
    echo 'Basic Pitch: Basispaket braucht Python 3.10-3.12; BASIC_PITCH_PYTHON_BIN setzen.' >&2
    return 1
  }
  if [[ "${BASIC_PITCH_INSTALL_RUNTIME:-0}" == 1 ]]; then
    "$BP_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,12)' || {
      echo 'Basic Pitch Runtime: Python 3.10/3.11 erforderlich; vorhandenes Python mit BASIC_PITCH_PYTHON_BIN auswaehlen. Kein System-Python-Umbau.' >&2
      return 1
    }
  fi
  [[ ! -e "$BP_VENV" || -f "$BP_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$BP_VENV" ]]; then
    "$BP_PYTHON" -I -B - "$BP_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

bp_resources() {
  local mount="$BP_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$BP_ROOT/scripts/lib/resource_check.sh"
  if [[ "${BASIC_PITCH_INSTALL_RUNTIME:-0}" == 1 ]]; then
    require_ram_mb 4096 || return 1
    available="$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 2048 ]] || {
      echo 'Basic Pitch Runtime: mindestens 2 GiB aktuell freien RAM schaffen.' >&2
      return 1
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=8192 require_disk_mb 8192 "$mount"
    return $?
  fi
  require_ram_mb 1024 || return 1
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'Basic Pitch: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

bp_python_core_ok() {
  "$BP_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

bp_python_venv_ok() {
  "$BP_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

bp_venv_package() {
  "$BP_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

bp_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$BP_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

bp_prepare_python() {
  local package answer='' policy="${BASIC_PITCH_INSTALL_VENV_DEPS:-ask}"
  bp_python_core_ok || {
    echo 'Basic Pitch: Python 3.10-3.12 mit SSL erforderlich; BASIC_PITCH_PYTHON_BIN pruefen.' >&2
    return 1
  }
  bp_python_venv_ok && return 0
  echo 'Basic Pitch: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(bp_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder BASIC_PITCH_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  { command -v apt-get >/dev/null && command -v sudo >/dev/null; } || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. Basic Pitch selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung BASIC_PITCH_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'BASIC_PITCH_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  bp_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  bp_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $BP_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

bp_fetch() {
  if [[ -e "$BP_SOURCE" ]]; then
    bp_source_ok || {
      echo 'Basic Pitch-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$BP_SOURCE" || return 1
    git -C "$BP_SOURCE" remote add origin "$BP_URL" || return 1
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$BP_SOURCE" fetch --depth 1 origin "$BP_COMMIT" || return 1
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$BP_SOURCE" checkout --detach FETCH_HEAD || return 1
  fi
  bp_source_ok || return 1
  [[ -f "$BP_SOURCE/pyproject.toml" && -f "$BP_SOURCE/basic_pitch/__init__.py" && -f "$BP_SOURCE/LICENSE" && -f "$BP_SOURCE/basic_pitch/saved_models/icassp_2022/nmp.onnx" && -f "$BP_SOURCE/basic_pitch/saved_models/icassp_2022/nmp.tflite" ]] || {
    echo 'Erwartetes Basic Pitch-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

bp_install_package() (
  set -euo pipefail
  local flavor=base constraints=''
  trap 'if [[ -n "$constraints" ]]; then rm -f -- "$constraints"; fi' EXIT
  rm -f -- "$BP_MARKER"
  "$BP_PYTHON" -I -B -m venv "$BP_VENV" || return 1
  local -a options=(--no-deps)
  if [[ "${BASIC_PITCH_INSTALL_RUNTIME:-0}" == 1 ]]; then
    constraints="$(mktemp "$BP_BASE/runtime_constraints_XXXXXX")" || return 1
    # Older TF/TFLite wheels require NumPy 1.x; no CUDA/system-driver changes.
    printf '%s\n' 'numpy==1.26.4' 'librosa==0.10.2.post1' >"$constraints"
    options=(--constraint "$constraints" "--only-binary=numpy,scipy,numba,llvmlite,tensorflow,tflite-runtime")
    flavor=runtime
  fi
  "$BP_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --disable-pip-version-check --index-url https://pypi.org/simple \
    "${options[@]}" "$BP_SOURCE" || return 1
  if [[ "$flavor" == runtime ]]; then
    "$BP_VENV/bin/python" -I -B -m pip --isolated check || return 1
  fi
  bp_metadata || return 1
  bp_source_ok || return 1
  printf '%s %s\n' "$BP_COMMIT" "$flavor" >"$BP_MARKER"
  echo "Basic Pitch aus GitHub installiert ($flavor). Keine CLI, Audioverarbeitung oder Dienste gestartet; Inferenz ungetestet."
)

bp_deactivate() {
  rm -f -- "$BP_MARKER"
  echo 'Basic Pitch-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

basic_pitch_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN GEMINI_API_KEY GOOGLE_API_KEY WANDB_API_KEY
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log dependencies=false
  bp_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Basic Pitch $BP_VERSION: GitHub $BP_URL; Commit $BP_COMMIT; private Basis-venv ohne Docker."
      echo 'Basis: 1 GiB RAM/512 MiB frei, 2 GiB Disk/Windows-C:, Paket --no-deps. Kleine Upstream-Modelle sind im Repo enthalten.'
      echo 'Optional BASIC_PITCH_INSTALL_RUNTIME=1 + INSTALL_HEAVY_TOOLS=1: Python 3.10/3.11, 4 GiB RAM/2 GiB frei, 8 GiB Disk/Windows-C:.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if bp_probe >/dev/null 2>&1; then
        if [[ "$(<"$BP_MARKER")" == "$BP_COMMIT runtime" ]]; then dependencies=true; fi
        printf '{"installed":true,"scope":"github-package","runtime_dependencies":%s,"inference_tested":false}\n' "$dependencies"
      else echo '{"installed":false,"scope":"github-package","runtime_dependencies":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      bp_probe || {
        echo 'Basic Pitch fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent; bei Runtime auch pip check. Keine Basic-Pitch-/TensorFlow-Imports oder Audio-/Modelltests.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Basic Pitch: nur Paketverwaltung, kein Audio-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  [[ "${BASIC_PITCH_INSTALL_RUNTIME:-0}" =~ ^[01]$ ]] || {
    echo 'BASIC_PITCH_INSTALL_RUNTIME muss 0 oder 1 sein.' >&2
    return 2
  }
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${BASIC_PITCH_INSTALL_RUNTIME:-0}" == 1 && "${INSTALL_HEAVY_TOOLS:-0}" != 1 ]]; then
    echo 'Basic Pitch Runtime erfordert BASIC_PITCH_INSTALL_RUNTIME=1 und INSTALL_HEAVY_TOOLS=1.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "Basic Pitch: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$BP_PYTHON" >/dev/null || {
      echo 'Basic Pitch: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    bp_preflight || return 1
    if [[ "$mode" == install ]] && bp_probe >/dev/null 2>&1 && { [[ "${BASIC_PITCH_INSTALL_RUNTIME:-0}" == 0 ]] || [[ "$(<"$BP_MARKER")" == "$BP_COMMIT runtime" ]]; }; then
      echo 'Basic Pitch-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    bp_resources || return 1
  elif [[ ! -d "$BP_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$BP_BASE" "$BP_LOGS"
  exec 9>"$BP_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Basic Pitch-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$BP_LOGS/basic_pitch_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Basic Pitch-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $BP_COMMIT"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "Basic Pitch-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    bp_deactivate
    return 0
  fi
  bp_prepare_python || return 1
  bp_fetch || return 1
  df -Pk "$BP_BASE"
  bp_install_package || return 1
  df -Pk "$BP_BASE"
)
