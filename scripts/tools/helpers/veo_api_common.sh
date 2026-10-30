#!/usr/bin/env bash
set -euo pipefail
VA_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
VA_URL=https://github.com/googleapis/python-genai.git
VA_COMMIT=6bbead9ec73eee0b2557c4bf07406d3574b01533
VA_VERSION=2.31.0

va_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$VA_ROOT/"*)
    echo 'Veo-API-SDK-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  VA_BASE="$root/tools/veo_api"
  VA_SOURCE="$VA_BASE/source"
  VA_VENV="$VA_BASE/venv"
  VA_MARKER="$VA_BASE/source-built"
  VA_LOGS="$root/install_logs"
  VA_PYTHON="${VEO_API_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$VA_BASE" "$VA_SOURCE" "$VA_SOURCE/.git" "$VA_VENV" "$VA_VENV/bin" "$VA_VENV/pyvenv.cfg" "$VA_MARKER" "$VA_LOGS" "$VA_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Veo API SDK: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

va_source_ok() {
  [[ -d "$VA_SOURCE/.git" ]] &&
    [[ "$(git -C "$VA_SOURCE" rev-parse --show-toplevel)" == "$VA_SOURCE" ]] &&
    [[ "$(git -C "$VA_SOURCE" remote get-url origin)" == "$VA_URL" ]] &&
    [[ "$(git -C "$VA_SOURCE" rev-parse HEAD)" == "$VA_COMMIT" ]] &&
    [[ -z "$(git -C "$VA_SOURCE" status --porcelain --untracked-files=all)" ]]
}

va_metadata() {
  "$VA_VENV/bin/python" -I -B - "$VA_SOURCE" "$VA_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("google-genai")
assert d.version == "2.31.0"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('google-genai 2.31.0: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

va_probe() {
  [[ -f "$VA_MARKER" && "$(<"$VA_MARKER")" == "$VA_COMMIT base" && -x "$VA_VENV/bin/python" ]] || return 1
  va_source_ok && va_metadata && "$VA_VENV/bin/python" -I -B -m pip --isolated check
}

va_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'Veo API SDK: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$VA_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,14)' || {
    echo 'Veo API SDK: vorhandenes Python 3.10-3.13 verwenden; Ubuntu-Python 3.12 passt.' >&2
    return 1
  }
  [[ ! -e "$VA_VENV" || -f "$VA_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$VA_VENV" ]]; then
    "$VA_PYTHON" -I -B - "$VA_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

va_resources() {
  local mount="$VA_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$VA_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 1024
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'Veo API SDK: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

va_python_core_ok() {
  "$VA_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,14)'
}

va_python_venv_ok() {
  "$VA_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

va_venv_package() {
  "$VA_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 14)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

va_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$VA_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

va_prepare_python() {
  local package answer='' policy="${VEO_API_INSTALL_VENV_DEPS:-ask}"
  va_python_core_ok || {
    echo 'Veo API SDK: Python 3.10-3.13 mit SSL erforderlich; VEO_API_PYTHON_BIN pruefen.' >&2
    return 1
  }
  va_python_venv_ok && return 0
  echo 'Veo API SDK: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(va_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder VEO_API_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  { command -v apt-get >/dev/null && command -v sudo >/dev/null; } || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. Das SDK selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung VEO_API_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'VEO_API_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  va_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  va_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $VA_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

va_fetch() {
  if [[ -e "$VA_SOURCE" ]]; then
    va_source_ok || {
      echo 'Veo-API-SDK-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$VA_SOURCE"
    git -C "$VA_SOURCE" remote add origin "$VA_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$VA_SOURCE" fetch --depth 1 origin "$VA_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$VA_SOURCE" checkout --detach FETCH_HEAD
  fi
  va_source_ok || return 1
  [[ -f "$VA_SOURCE/pyproject.toml" && -f "$VA_SOURCE/google/genai/__init__.py" && -f "$VA_SOURCE/setup.cfg" ]] || {
    echo 'Erwartetes Veo-API-SDK-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

va_install_package() {
  rm -f -- "$VA_MARKER"
  "$VA_PYTHON" -I -B -m venv "$VA_VENV"
  # GitHub supplies the SDK; PyPI supplies build/runtime wheels, no extras.
  "$VA_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --disable-pip-version-check --index-url https://pypi.org/simple \
    --only-binary=:all: "$VA_SOURCE"
  "$VA_VENV/bin/python" -I -B -m pip --isolated check
  va_metadata
  va_source_ok || return 1
  printf '%s\n' "$VA_COMMIT base" >"$VA_MARKER"
  echo 'Veo API SDK aus GitHub in privater venv installiert. Keine Google-API-Anfragen, Uploads, API-Keys, Modelle oder kostenpflichtigen Videojobs.'
}

va_deactivate() {
  rm -f -- "$VA_MARKER"
  echo 'Veo-API-SDK-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

veo_api_main() (
  set -euo pipefail
  umask 077
  unset GOOGLE_API_KEY GEMINI_API_KEY GOOGLE_APPLICATION_CREDENTIALS
  unset GOOGLE_CLOUD_PROJECT GOOGLE_CLOUD_LOCATION GOOGLE_GENAI_USE_VERTEXAI GOOGLE_GENAI_USE_ENTERPRISE
  local mode="${1:-install}" program log
  va_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Veo API SDK $VA_VERSION: GitHub $VA_URL; Commit $VA_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Keine local-tokenizer/aiohttp/pyopenssl-Extras oder Videomodelle.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if va_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","cloud_checked":false,"cloud_called":false}'
      else echo '{"installed":false,"scope":"github-base-package","cloud_checked":false,"cloud_called":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      va_probe || {
        echo 'Veo API SDK fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Commit und Paketmetadaten konsistent. Kein SDK-Import, Login, API-Auftrag, Upload oder Tokenzugriff.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Veo API SDK: nur Paketverwaltung, kein API-/Login-/Uploadstart.' >&2
      return 2
      ;;
  esac
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "Veo API SDK: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$VA_PYTHON" >/dev/null || {
      echo 'Veo API SDK: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    va_preflight || return 1
    if [[ "$mode" == install ]] && va_probe >/dev/null 2>&1; then
      echo 'Veo-API-SDK-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    va_resources || return 1
  elif [[ ! -d "$VA_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$VA_BASE" "$VA_LOGS"
  exec 9>"$VA_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Veo-API-SDK-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$VA_LOGS/veo_api_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Veo-API-SDK-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $VA_COMMIT"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "Veo-API-SDK-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    va_deactivate
    return 0
  fi
  va_prepare_python || return 1
  va_fetch
  df -Pk "$VA_BASE"
  va_install_package
  df -Pk "$VA_BASE"
)
