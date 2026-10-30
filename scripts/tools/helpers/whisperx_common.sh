#!/usr/bin/env bash
set -euo pipefail
WX_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
WX_URL=https://github.com/m-bain/whisperX.git
WX_COMMIT=3ccc17b8de34f305300f8a3fd3c9f76ba820c0d0
WX_VERSION=3.8.6

wx_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$WX_ROOT/"*)
    echo 'WhisperX-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  WX_BASE="$root/tools/whisperx"
  WX_SOURCE="$WX_BASE/source"
  WX_VENV="$WX_BASE/venv"
  WX_MARKER="$WX_BASE/source-built"
  WX_LOGS="$root/install_logs"
  WX_PYTHON="${WHISPERX_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$WX_BASE" "$WX_SOURCE" "$WX_SOURCE/.git" "$WX_VENV" "$WX_VENV/bin" "$WX_VENV/pyvenv.cfg" "$WX_MARKER" "$WX_LOGS" "$WX_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'WhisperX: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

wx_source_ok() {
  local top state
  [[ -d "$WX_SOURCE/.git" && ! -e "$WX_SOURCE/.env" && ! -L "$WX_SOURCE/.env" ]] || return 1
  top="$(git -C "$WX_SOURCE" rev-parse --show-toplevel)" || return 1
  state="$(git -C "$WX_SOURCE" status --porcelain --untracked-files=all)" || return 1
  [[ "$top" -ef "$WX_SOURCE" &&
    "$(git -C "$WX_SOURCE" remote get-url origin)" == "$WX_URL" &&
    "$(git -C "$WX_SOURCE" rev-parse HEAD)" == "$WX_COMMIT" &&
    -z "$state" ]]
}

wx_metadata() {
  "$WX_VENV/bin/python" -I -B - "$WX_SOURCE" "$WX_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("whisperx")
assert d.version == "3.8.6"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('whisperx 3.8.6 / WhisperX: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

wx_probe() {
  [[ -f "$WX_MARKER" && -x "$WX_VENV/bin/python" ]] || return 1
  local flavor
  flavor="$(<"$WX_MARKER")"
  [[ "$flavor" == "$WX_COMMIT base" || "$flavor" == "$WX_COMMIT runtime" ]] || return 1
  wx_source_ok && wx_metadata || return 1
  if [[ "$flavor" == "$WX_COMMIT runtime" ]]; then
    wx_torch_constraints >/dev/null || return 1
    "$WX_VENV/bin/python" -I -B -m pip --isolated check || return 1
  fi
}

wx_torch_constraints() {
  [[ -x "$WX_VENV/bin/python" ]] || return 1
  "$WX_VENV/bin/python" -I -B - "$WX_VENV" <<'PY'
from importlib.metadata import version
from pathlib import Path
import re
import sys
assert sys.prefix != sys.base_prefix and Path(sys.prefix).resolve() == Path(sys.argv[1]).resolve()
versions = {name: version(name) for name in ('torch', 'torchaudio', 'torchvision')}
for value in versions.values():
    assert re.fullmatch(r'[0-9][A-Za-z0-9.+!-]{0,127}', value)
assert versions['torch'].split('+')[0] == versions['torchaudio'].split('+')[0]
assert versions['torch'].split('+')[-1] == versions['torchaudio'].split('+')[-1]
assert versions['torch'].split('+')[0].startswith('2.8.')
assert versions['torchvision'].split('+')[0].startswith('0.23.')
# Torch/audio/vision must share a local CPU/CUDA suffix, or all be plain versions.
suffixes = {value.partition('+')[2] for value in versions.values()}
assert len(suffixes) == 1, 'CPU/CUDA-Wheels duerfen nicht gemischt werden'
for name, value in versions.items():
    print(name + '==' + value)
PY
}

wx_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'WhisperX: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$WX_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,14)' || {
    echo 'WhisperX: Basispaket braucht Python 3.10-3.13; WHISPERX_PYTHON_BIN setzen.' >&2
    return 1
  }
  if [[ "${WHISPERX_INSTALL_RUNTIME:-0}" == 1 ]]; then
    [[ "$(uname -m)" == x86_64 ]] || {
      echo 'WhisperX Runtime: automatischer pip-Pfad nur Linux x86_64; ARM64/torchcodec/uv-Override gesondert pruefen.' >&2
      return 1
    }
    command -v ffmpeg >/dev/null || {
      echo 'WhisperX Runtime: ffmpeg fehlt; separat einrichten.' >&2
      return 1
    }
    wx_torch_constraints >/dev/null || {
      echo 'WhisperX Runtime: zuerst Basispaket und passende Torch-/torchaudio-2.8.x-/torchvision-0.23.x-Wheels in dieser venv einrichten. Siehe docs/tools/whisperx.md.' >&2
      return 1
    }
  fi
  [[ ! -e "$WX_VENV" || -f "$WX_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$WX_VENV" ]]; then
    "$WX_PYTHON" -I -B - "$WX_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

wx_resources() {
  local mount="$WX_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$WX_ROOT/scripts/lib/resource_check.sh"
  if [[ "${WHISPERX_INSTALL_RUNTIME:-0}" == 1 ]]; then
    require_ram_mb 8192 || return 1
    available="$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 4096 ]] || {
      echo 'WhisperX Runtime: mindestens 4 GiB aktuell freien RAM schaffen.' >&2
      return 1
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=20480 require_disk_mb 20480 "$mount"
    return $?
  fi
  require_ram_mb 1024 || return 1
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'WhisperX: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

wx_python_core_ok() {
  "$WX_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,14)'
}

wx_python_venv_ok() {
  "$WX_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

wx_venv_package() {
  "$WX_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 14)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

wx_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$WX_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

wx_prepare_python() {
  local package answer='' policy="${WHISPERX_INSTALL_VENV_DEPS:-ask}"
  wx_python_core_ok || {
    echo 'WhisperX: Python 3.10-3.13 mit SSL erforderlich; WHISPERX_PYTHON_BIN pruefen.' >&2
    return 1
  }
  wx_python_venv_ok && return 0
  echo 'WhisperX: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(wx_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder WHISPERX_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  command -v apt-get >/dev/null && command -v sudo >/dev/null || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. WhisperX selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung WHISPERX_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'WHISPERX_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  wx_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  wx_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $WX_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

wx_fetch() {
  if [[ -e "$WX_SOURCE" ]]; then
    wx_source_ok || {
      echo 'WhisperX-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$WX_SOURCE" || return 1
    git -C "$WX_SOURCE" remote add origin "$WX_URL" || return 1
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$WX_SOURCE" fetch --depth 1 origin "$WX_COMMIT" || return 1
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$WX_SOURCE" checkout --detach FETCH_HEAD || return 1
  fi
  wx_source_ok || return 1
  [[ -f "$WX_SOURCE/pyproject.toml" && -f "$WX_SOURCE/whisperx/__init__.py" && -f "$WX_SOURCE/LICENSE" && -f "$WX_SOURCE/whisperx/assets/pytorch_model.bin" ]] || {
    echo 'Erwartetes WhisperX-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

wx_install_package() (
  set -euo pipefail
  local flavor=base constraints=''
  trap 'if [[ -n "$constraints" ]]; then rm -f -- "$constraints"; fi' EXIT
  rm -f -- "$WX_MARKER"
  "$WX_PYTHON" -I -B -m venv "$WX_VENV" || return 1
  local -a options=(--no-deps)
  if [[ "${WHISPERX_INSTALL_RUNTIME:-0}" == 1 ]]; then
    constraints="$(mktemp "$WX_BASE/runtime_constraints_XXXXXX")" || return 1
    wx_torch_constraints >"$constraints" || return 1
    printf '%s\n' 'numpy>=2.1,<3' 'transformers<5' >>"$constraints"
    options=(--constraint "$constraints" --only-binary=torch,torchaudio,torchvision,torchcodec,triton,ctranslate2,numpy,scipy,numba,llvmlite)
    flavor=runtime
  fi
  "$WX_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --disable-pip-version-check --index-url https://pypi.org/simple \
    "${options[@]}" "$WX_SOURCE" || return 1
  if [[ "$flavor" == runtime ]]; then
    "$WX_VENV/bin/python" -I -B -m pip --isolated check || return 1
  fi
  wx_metadata || return 1
  wx_source_ok || return 1
  printf '%s %s\n' "$WX_COMMIT" "$flavor" >"$WX_MARKER"
  echo "WhisperX aus GitHub installiert ($flavor). Keine CLI, Audioverarbeitung oder Dienste gestartet; Inferenz ungetestet."
)

wx_deactivate() {
  rm -f -- "$WX_MARKER"
  echo 'WhisperX-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

whisperx_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN GEMINI_API_KEY GOOGLE_API_KEY WANDB_API_KEY
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log dependencies=false
  wx_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "WhisperX $WX_VERSION: GitHub $WX_URL; Commit $WX_COMMIT; private Basis-venv ohne Docker."
      echo 'Basis: 1 GiB RAM/512 MiB frei, 2 GiB Disk/Windows-C:, Paket --no-deps. Upstream-VAD-Modell ist im Repo enthalten; keine ASR-/Alignment-Downloads.'
      echo 'Optional WHISPERX_INSTALL_RUNTIME=1 + INSTALL_HEAVY_TOOLS=1: vorhandene Torch-2.8.x-Wheels, ffmpeg, Linux x86_64, 8 GiB RAM/4 GiB frei, 20 GiB Disk/Windows-C:.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if wx_probe >/dev/null 2>&1; then
        if [[ "$(<"$WX_MARKER")" == "$WX_COMMIT runtime" ]]; then dependencies=true; fi
        printf '{"installed":true,"scope":"github-package","runtime_dependencies":%s,"inference_tested":false}\n' "$dependencies"
      else echo '{"installed":false,"scope":"github-package","runtime_dependencies":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      wx_probe || {
        echo 'WhisperX fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent; bei Runtime auch pip check. Keine WhisperX-/Torch-Imports oder Audio-/Modelltests.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'WhisperX: nur Paketverwaltung, kein Audio-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  [[ "${WHISPERX_INSTALL_RUNTIME:-0}" =~ ^[01]$ ]] || {
    echo 'WHISPERX_INSTALL_RUNTIME muss 0 oder 1 sein.' >&2
    return 2
  }
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${WHISPERX_INSTALL_RUNTIME:-0}" == 1 && "${INSTALL_HEAVY_TOOLS:-0}" != 1 ]]; then
    echo 'WhisperX Runtime erfordert WHISPERX_INSTALL_RUNTIME=1 und INSTALL_HEAVY_TOOLS=1.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "WhisperX: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$WX_PYTHON" >/dev/null || {
      echo 'WhisperX: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    wx_preflight || return 1
    if [[ "$mode" == install ]] && wx_probe >/dev/null 2>&1 && { [[ "${WHISPERX_INSTALL_RUNTIME:-0}" == 0 ]] || [[ "$(<"$WX_MARKER")" == "$WX_COMMIT runtime" ]]; }; then
      echo 'WhisperX-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    wx_resources || return 1
  elif [[ ! -d "$WX_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$WX_BASE" "$WX_LOGS"
  exec 9>"$WX_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere WhisperX-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$WX_LOGS/whisperx_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "WhisperX-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $WX_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "WhisperX-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    wx_deactivate
    return 0
  fi
  wx_prepare_python || return 1
  wx_fetch || return 1
  df -Pk "$WX_BASE"
  wx_install_package || return 1
  df -Pk "$WX_BASE"
)
