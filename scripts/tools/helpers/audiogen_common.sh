#!/usr/bin/env bash
set -euo pipefail
AG_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AG_URL=https://github.com/facebookresearch/audiocraft.git
AG_COMMIT=72cb16f9fb239e9cf03f7bd997198c7d7a67a01c
AG_VERSION=1.3.0

ag_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$AG_ROOT/"*)
    echo 'AudioGen-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  AG_BASE="$root/tools/audiogen"
  AG_SOURCE="$AG_BASE/source"
  AG_VENV="$AG_BASE/venv"
  AG_MARKER="$AG_BASE/source-built"
  AG_LOGS="$root/install_logs"
  AG_PYTHON="${AUDIOGEN_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$AG_BASE" "$AG_SOURCE" "$AG_SOURCE/.git" "$AG_VENV" "$AG_VENV/bin" "$AG_VENV/pyvenv.cfg" "$AG_MARKER" "$AG_LOGS" "$AG_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'AudioGen: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

ag_source_ok() {
  [[ -d "$AG_SOURCE/.git" ]] &&
    [[ "$(git -C "$AG_SOURCE" rev-parse --show-toplevel)" == "$AG_SOURCE" ]] &&
    [[ "$(git -C "$AG_SOURCE" remote get-url origin)" == "$AG_URL" ]] &&
    [[ "$(git -C "$AG_SOURCE" rev-parse HEAD)" == "$AG_COMMIT" ]] &&
    [[ -z "$(git -C "$AG_SOURCE" status --porcelain --untracked-files=all)" ]]
}

ag_metadata() {
  "$AG_VENV/bin/python" -I -B - "$AG_SOURCE" "$AG_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("audiocraft")
assert d.version == "1.3.0"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('audiocraft 1.3.0 / AudioGen: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

ag_probe() {
  [[ -f "$AG_MARKER" && "$(<"$AG_MARKER")" == "$AG_COMMIT base" && -x "$AG_VENV/bin/python" ]] || return 1
  ag_source_ok && ag_metadata
}

ag_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'AudioGen: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$AG_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,13)' || {
    echo 'AudioGen: vorhandenes Python 3.10-3.12 verwenden; Ubuntu-Python 3.12 passt.' >&2
    return 1
  }
  [[ ! -e "$AG_VENV" || -f "$AG_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$AG_VENV" ]]; then
    "$AG_PYTHON" -I -B - "$AG_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

ag_resources() {
  local mount="$AG_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$AG_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 1024 || return 1
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'AudioGen: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

ag_python_core_ok() {
  "$AG_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

ag_python_venv_ok() {
  "$AG_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

ag_venv_package() {
  "$AG_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

ag_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$AG_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

ag_prepare_python() {
  local package answer='' policy="${AUDIOGEN_INSTALL_VENV_DEPS:-ask}"
  ag_python_core_ok || {
    echo 'AudioGen: Python 3.10-3.12 mit SSL erforderlich; AUDIOGEN_PYTHON_BIN pruefen.' >&2
    return 1
  }
  ag_python_venv_ok && return 0
  echo 'AudioGen: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(ag_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder AUDIOGEN_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  command -v apt-get >/dev/null && command -v sudo >/dev/null || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. AudioGen selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung AUDIOGEN_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'AUDIOGEN_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  ag_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  ag_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $AG_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

ag_fetch() {
  if [[ -e "$AG_SOURCE" ]]; then
    ag_source_ok || {
      echo 'AudioGen-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$AG_SOURCE"
    git -C "$AG_SOURCE" remote add origin "$AG_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$AG_SOURCE" fetch --depth 1 origin "$AG_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$AG_SOURCE" checkout --detach FETCH_HEAD
  fi
  ag_source_ok || return 1
  [[ -f "$AG_SOURCE/setup.py" && -f "$AG_SOURCE/audiocraft/models/audiogen.py" && -f "$AG_SOURCE/LICENSE" ]] || {
    echo 'Erwartetes AudioGen-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

ag_install_package() {
  rm -f -- "$AG_MARKER"
  "$AG_PYTHON" -I -B -m venv "$AG_VENV"
  # Only the pinned local package is built. Legacy runtime is not resolved here.
  "$AG_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
    --no-deps "$AG_SOURCE"
  ag_metadata
  ag_source_ok || return 1
  printf '%s\n' "$AG_COMMIT base" >"$AG_MARKER"
  echo 'AudioGen aus GitHub in privater venv installiert. Nur Basispaket ohne Runtime-Abhaengigkeiten. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

ag_deactivate() {
  rm -f -- "$AG_MARKER"
  echo 'AudioGen-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

audiogen_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log
  ag_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "AudioGen $AG_VERSION: GitHub $AG_URL; Commit $AG_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Nur Paket --no-deps, keine betriebsbereite Audio-Laufzeit.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if ag_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
      else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      ag_probe || {
        echo 'AudioGen fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein AudioCraft-/Torch-Import, CLI/WebUI oder Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'AudioGen: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${AUDIOGEN_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'Automatische Legacy-Runtime nicht freigegeben: AudioCraft 1.3.0 verlangt torch==2.1.0, PyAV==11.0.0 und xformers<0.0.23. Siehe docs/tools/audiogen.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "AudioGen: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$AG_PYTHON" >/dev/null || {
      echo 'AudioGen: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    ag_preflight || return 1
    if [[ "$mode" == install ]] && ag_probe >/dev/null 2>&1; then
      echo 'AudioGen-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    ag_resources || return 1
  elif [[ ! -d "$AG_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$AG_BASE" "$AG_LOGS"
  exec 9>"$AG_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere AudioGen-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$AG_LOGS/audiogen_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "AudioGen-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $AG_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "AudioGen-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    ag_deactivate
    return 0
  fi
  ag_prepare_python || return 1
  ag_fetch
  df -Pk "$AG_BASE"
  ag_install_package
  df -Pk "$AG_BASE"
)
