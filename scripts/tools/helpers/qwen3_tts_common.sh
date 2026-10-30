#!/usr/bin/env bash
set -euo pipefail
QT_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
QT_URL=https://github.com/QwenLM/Qwen3-TTS.git
QT_COMMIT=022e286b98fbec7e1e916cb940cdf532cd9f488e
QT_VERSION=0.1.1

qt_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$QT_ROOT/"*)
    echo 'Qwen3-TTS-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  QT_BASE="$root/tools/qwen3_tts"
  QT_SOURCE="$QT_BASE/source"
  QT_VENV="$QT_BASE/venv"
  QT_MARKER="$QT_BASE/source-built"
  QT_LOGS="$root/install_logs"
  QT_PYTHON="${QWEN3_TTS_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$QT_BASE" "$QT_SOURCE" "$QT_SOURCE/.git" "$QT_VENV" "$QT_VENV/bin" "$QT_VENV/pyvenv.cfg" "$QT_MARKER" "$QT_LOGS" "$QT_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Qwen3-TTS: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

qt_source_ok() {
  [[ -d "$QT_SOURCE/.git" ]] &&
    [[ "$(git -C "$QT_SOURCE" rev-parse --show-toplevel)" == "$QT_SOURCE" ]] &&
    [[ "$(git -C "$QT_SOURCE" remote get-url origin)" == "$QT_URL" ]] &&
    [[ "$(git -C "$QT_SOURCE" rev-parse HEAD)" == "$QT_COMMIT" ]] &&
    [[ -z "$(git -C "$QT_SOURCE" status --porcelain --untracked-files=all)" ]]
}

qt_metadata() {
  "$QT_VENV/bin/python" -I -B - "$QT_SOURCE" "$QT_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("qwen-tts")
assert d.version == "0.1.1"
assert any(e.group == 'console_scripts' and e.name == 'qwen-tts-demo' and e.value == 'qwen_tts.cli.demo:main' for e in d.entry_points)
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('qwen-tts 0.1.1: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

qt_probe() {
  local flavor
  [[ -f "$QT_MARKER" && -x "$QT_VENV/bin/python" ]] || return 1
  flavor="$(<"$QT_MARKER")"
  [[ "$flavor" == "$QT_COMMIT package" || "$flavor" == "$QT_COMMIT runtime" ]] || return 1
  qt_source_ok && qt_metadata || return 1
  if [[ "$flavor" == "$QT_COMMIT runtime" ]]; then
    qt_torch_constraints >/dev/null && "$QT_VENV/bin/python" -I -B -m pip --isolated check || return 1
  fi
}

qt_torch_constraints() {
  [[ -x "$QT_VENV/bin/python" ]] || {
    echo 'Zuerst Basispaket installieren, dann passende Torch/torchaudio-Wheels in genau dieser venv einrichten. Siehe docs/tools/qwen3-tts.md.' >&2
    return 1
  }
  "$QT_VENV/bin/python" -I -B - "$QT_VENV" <<'PY'
from importlib.metadata import version
from pathlib import Path
import re
import sys
assert sys.prefix != sys.base_prefix and Path(sys.prefix).resolve() == Path(sys.argv[1]).resolve()
torch = version('torch')
audio = version('torchaudio')
assert all(re.fullmatch(r'[0-9][A-Za-z0-9.+!-]{0,127}', v) for v in (torch, audio))
assert torch.split('+')[0] == audio.split('+')[0], 'Torch und torchaudio muessen zusammenpassen'
print('torch==' + torch)
print('torchaudio==' + audio)
PY
}

qt_runtime_preflight() {
  [[ "${INSTALL_HEAVY_TOOLS:-0}" == 1 ]] || {
    echo 'Runtime-Abhaengigkeiten brauchen INSTALL_HEAVY_TOOLS=1 und QWEN3_TTS_INSTALL_RUNTIME=1.' >&2
    return 2
  }
  qt_torch_constraints >/dev/null || {
    echo 'Passende Torch-/torchaudio-Metadaten fehlen. Kein automatischer CUDA-/Treiber-/Torch-Umbau.' >&2
    return 1
  }
}

qt_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'Qwen3-TTS: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$QT_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,13)' || {
    echo 'Qwen3-TTS: vorhandenes Python 3.10-3.12 verwenden; Ubuntu-Python 3.12 passt.' >&2
    return 1
  }
  [[ ! -e "$QT_VENV" || -f "$QT_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$QT_VENV" ]]; then
    "$QT_PYTHON" -I -B - "$QT_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

qt_resources() {
  local mount="$QT_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$QT_ROOT/scripts/lib/resource_check.sh"
  if [[ "${QWEN3_TTS_INSTALL_RUNTIME:-0}" == 1 ]]; then
    require_ram_mb 8192
    available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
    [[ "$available" =~ ^[0-9]+$ && "$available" -ge 4096 ]] || {
      echo 'Runtime: mindestens 4 GiB verfuegbaren RAM freimachen.' >&2
      return 1
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=20480 require_disk_mb 20480 "$mount"
    return 0
  fi
  require_ram_mb 1024
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'Qwen3-TTS: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

qt_python_core_ok() {
  "$QT_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

qt_python_venv_ok() {
  "$QT_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

qt_venv_package() {
  "$QT_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

qt_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$QT_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

qt_prepare_python() {
  local package answer='' policy="${QWEN3_TTS_INSTALL_VENV_DEPS:-ask}"
  qt_python_core_ok || {
    echo 'Qwen3-TTS: Python 3.10-3.12 mit SSL erforderlich; QWEN3_TTS_PYTHON_BIN pruefen.' >&2
    return 1
  }
  qt_python_venv_ok && return 0
  echo 'Qwen3-TTS: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(qt_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder QWEN3_TTS_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  command -v apt-get >/dev/null && command -v sudo >/dev/null || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. Qwen3-TTS selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung QWEN3_TTS_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'QWEN3_TTS_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  qt_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  qt_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $QT_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

qt_fetch() {
  if [[ -e "$QT_SOURCE" ]]; then
    qt_source_ok || {
      echo 'Qwen3-TTS-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$QT_SOURCE"
    git -C "$QT_SOURCE" remote add origin "$QT_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$QT_SOURCE" fetch --depth 1 origin "$QT_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$QT_SOURCE" checkout --detach FETCH_HEAD
  fi
  qt_source_ok || return 1
  [[ -f "$QT_SOURCE/pyproject.toml" && -f "$QT_SOURCE/qwen_tts/__init__.py" ]] || {
    echo 'Erwartetes Qwen3-TTS-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

qt_install_package() (
  set -euo pipefail
  local flavor=package constraints=''
  trap 'if [[ -n "$constraints" ]]; then rm -f -- "$constraints"; fi' EXIT
  rm -f -- "$QT_MARKER"
  "$QT_PYTHON" -I -B -m venv "$QT_VENV"
  if [[ "${QWEN3_TTS_INSTALL_RUNTIME:-0}" == 1 ]]; then
    constraints="$(mktemp "$QT_BASE/torch_constraints_XXXXXX")"
    qt_torch_constraints >"$constraints"
    # Prevent pip from replacing the explicitly selected Torch/torchaudio builds.
    "$QT_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
      --disable-pip-version-check --index-url https://pypi.org/simple \
      --constraint "$constraints" --only-binary=torch,torchaudio,onnxruntime,numpy,scipy "$QT_SOURCE"
    "$QT_VENV/bin/python" -I -B -m pip --isolated check
    flavor=runtime
  else
    "$QT_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
      --disable-pip-version-check --index-url https://pypi.org/simple \
      --no-deps "$QT_SOURCE"
  fi
  qt_metadata
  qt_source_ok || return 1
  printf '%s %s\n' "$QT_COMMIT" "$flavor" >"$QT_MARKER"
  echo "Qwen3-TTS aus GitHub installiert ($flavor). Keine Modelle/Referenzaudios/Trainingsjobs oder Dienste gestartet; Inferenz nicht getestet."
)

qt_deactivate() {
  rm -f -- "$QT_MARKER"
  echo 'Qwen3-TTS-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

qwen3_tts_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log flavor=package dependencies=false
  qt_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Qwen3-TTS $QT_VERSION: GitHub $QT_URL; Commit $QT_COMMIT; private Basis-venv ohne Docker."
      echo 'Standard --no-deps: 1 GiB RAM/512 MiB verfuegbar, 2 GiB Disk/Windows-C:.'
      echo 'Optional Runtime: QWEN3_TTS_INSTALL_RUNTIME=1 + INSTALL_HEAVY_TOOLS=1, vorinstalliertes Torch/torchaudio; 8 GiB RAM/4 GiB frei, 20 GiB Disk/Windows-C:. Keine Gewichte/Demo/Training.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if qt_probe >/dev/null 2>&1; then
        if [[ "$(<"$QT_MARKER")" == "$QT_COMMIT runtime" ]]; then dependencies=true; fi
        printf '{"installed":true,"runtime_dependencies":%s,"inference_tested":false,"models_checked":false}\n' "$dependencies"
      else echo '{"installed":false,"runtime_dependencies":false,"inference_tested":false,"models_checked":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      qt_probe || {
        echo 'Qwen3-TTS fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent; package ohne Runtime-Abhaengigkeiten, runtime mit pip check. Kein qwen_tts/Torch-Import oder Inferenztest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Qwen3-TTS: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "Qwen3-TTS: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$QT_PYTHON" >/dev/null || {
      echo 'Qwen3-TTS: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    [[ "${QWEN3_TTS_INSTALL_RUNTIME:-0}" == 0 || "${QWEN3_TTS_INSTALL_RUNTIME:-0}" == 1 ]] || return 2
    if [[ "${QWEN3_TTS_INSTALL_RUNTIME:-0}" == 1 ]]; then
      flavor=runtime
      qt_runtime_preflight || return $?
    fi
    qt_preflight || return 1
    if [[ "$mode" == install && -f "$QT_MARKER" && "$(<"$QT_MARKER")" == "$QT_COMMIT $flavor" ]] && qt_probe >/dev/null 2>&1; then
      echo 'Qwen3-TTS-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    qt_resources || return 1
  elif [[ ! -d "$QT_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$QT_BASE" "$QT_LOGS"
  exec 9>"$QT_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Qwen3-TTS-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$QT_LOGS/qwen3_tts_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Qwen3-TTS-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $QT_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "Qwen3-TTS-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    qt_deactivate
    return 0
  fi
  qt_prepare_python || return 1
  qt_fetch
  df -Pk "$QT_BASE"
  qt_install_package
  df -Pk "$QT_BASE"
)
