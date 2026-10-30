#!/usr/bin/env bash
set -euo pipefail
MT_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
MT_URL=https://github.com/OpenMOSS/MOSS-TTS.git
MT_COMMIT=934d6826b084c46a0d033402174d5f8ac4ed2519
MT_VERSION=0.1.0

mt_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$MT_ROOT/"*)
    echo 'MOSS-TTS-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  MT_BASE="$root/tools/moss_tts"
  MT_SOURCE="$MT_BASE/source"
  MT_VENV="$MT_BASE/venv"
  MT_MARKER="$MT_BASE/source-built"
  MT_LOGS="$root/install_logs"
  MT_PYTHON="${MOSS_TTS_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$MT_BASE" "$MT_SOURCE" "$MT_SOURCE/.git" "$MT_VENV" "$MT_VENV/bin" "$MT_VENV/pyvenv.cfg" "$MT_MARKER" "$MT_LOGS" "$MT_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'MOSS-TTS: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

mt_source_ok() {
  [[ -d "$MT_SOURCE/.git" ]] &&
    [[ "$(git -C "$MT_SOURCE" rev-parse --show-toplevel)" == "$MT_SOURCE" ]] &&
    [[ "$(git -C "$MT_SOURCE" remote get-url origin)" == "$MT_URL" ]] &&
    [[ "$(git -C "$MT_SOURCE" rev-parse HEAD)" == "$MT_COMMIT" ]] &&
    [[ -z "$(git -C "$MT_SOURCE" status --porcelain --untracked-files=all)" ]]
}

mt_metadata() {
  "$MT_VENV/bin/python" -I -B - "$MT_SOURCE" "$MT_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("moss-tts")
assert d.version == "0.1.0"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('moss-tts 0.1.0: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

mt_probe() {
  [[ -f "$MT_MARKER" && "$(<"$MT_MARKER")" == "$MT_COMMIT base" && -x "$MT_VENV/bin/python" ]] || return 1
  mt_source_ok && mt_metadata
}

mt_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'MOSS-TTS: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$MT_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,13)' || {
    echo 'MOSS-TTS: vorhandenes Python 3.10-3.12 verwenden; Ubuntu-Python 3.12 passt.' >&2
    return 1
  }
  [[ ! -e "$MT_VENV" || -f "$MT_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$MT_VENV" ]]; then
    "$MT_PYTHON" -I -B - "$MT_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

mt_resources() {
  local mount="$MT_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$MT_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 1024 || return 1
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'MOSS-TTS: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

mt_python_core_ok() {
  "$MT_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

mt_python_venv_ok() {
  "$MT_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

mt_venv_package() {
  "$MT_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

mt_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$MT_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

mt_prepare_python() {
  local package answer='' policy="${MOSS_TTS_INSTALL_VENV_DEPS:-ask}"
  mt_python_core_ok || {
    echo 'MOSS-TTS: Python 3.10-3.12 mit SSL erforderlich; MOSS_TTS_PYTHON_BIN pruefen.' >&2
    return 1
  }
  mt_python_venv_ok && return 0
  echo 'MOSS-TTS: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(mt_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder MOSS_TTS_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  { command -v apt-get >/dev/null && command -v sudo >/dev/null; } || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. MOSS-TTS selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung MOSS_TTS_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'MOSS_TTS_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  mt_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  mt_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $MT_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

mt_fetch() {
  if [[ -e "$MT_SOURCE" ]]; then
    mt_source_ok || {
      echo 'MOSS-TTS-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$MT_SOURCE"
    git -C "$MT_SOURCE" remote add origin "$MT_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$MT_SOURCE" fetch --depth 1 origin "$MT_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$MT_SOURCE" checkout --detach FETCH_HEAD
  fi
  mt_source_ok || return 1
  [[ -f "$MT_SOURCE/pyproject.toml" && -d "$MT_SOURCE/moss_tts_delay" && -f "$MT_SOURCE/LICENSE" ]] || {
    echo 'Erwartetes MOSS-TTS-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

mt_install_package() {
  rm -f -- "$MT_MARKER"
  "$MT_PYTHON" -I -B -m venv "$MT_VENV"
  # Only the pinned local package is built. GPU runtime is not resolved here.
  "$MT_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
    --no-deps "$MT_SOURCE"
  mt_metadata
  mt_source_ok || return 1
  printf '%s\n' "$MT_COMMIT base" >"$MT_MARKER"
  echo 'MOSS-TTS aus GitHub in privater venv installiert. Nur Basis-Metadatenpaket und GitHub-Checkout ohne Runtime-Abhaengigkeiten/Submodule. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

mt_deactivate() {
  rm -f -- "$MT_MARKER"
  source "$MT_ROOT/scripts/helpers/native_tool_status.sh"
  native_tool_sync_status MOSS_TTS "${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" || return 1
  echo 'MOSS-TTS-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

moss_tts_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log
  mt_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "MOSS-TTS $MT_VERSION: GitHub $MT_URL; Commit $MT_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Checkout + Metadatenpaket --no-deps, keine betriebsbereite TTS-Laufzeit.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if mt_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
      else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      mt_probe || {
        echo 'MOSS-TTS fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein MOSS-/Torch-Import, CLI/WebUI oder Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'MOSS-TTS: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${MOSS_TTS_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'Automatische GPU-Runtime nicht freigegeben: MOSS-TTS benoetigt separat gewaehlten Torch-/llama.cpp-Pfad, Audio-Tokenizer und Modelle. Siehe docs/tools/moss-tts.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "MOSS-TTS: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$MT_PYTHON" >/dev/null || {
      echo 'MOSS-TTS: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    mt_preflight || return 1
    if [[ "$mode" == install ]] && mt_probe >/dev/null 2>&1; then
      echo 'MOSS-TTS-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    mt_resources || return 1
  elif [[ ! -d "$MT_BASE" ]]; then
    mt_deactivate
    return $?
  fi
  mkdir -p "$MT_BASE" "$MT_LOGS"
  exec 9>"$MT_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere MOSS-TTS-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$MT_LOGS/moss_tts_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "MOSS-TTS-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $MT_COMMIT"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "MOSS-TTS-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    mt_deactivate
    return 0
  fi
  mt_prepare_python || return 1
  mt_fetch
  df -Pk "$MT_BASE"
  mt_install_package
  source "$MT_ROOT/scripts/helpers/native_tool_status.sh"
  native_tool_sync_status MOSS_TTS "${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
  df -Pk "$MT_BASE"
)
