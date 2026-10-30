#!/usr/bin/env bash
set -euo pipefail
FC_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
FC_URL=https://github.com/fal-ai/fal.git
FC_COMMIT=80ddb1d8f2f4b0a28a0323fd3c1d96e34c849eb5
FC_VERSION=1.0.3

fc_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$FC_ROOT/"*)
    echo 'Fal-Client-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  FC_BASE="$root/tools/fal_client"
  FC_SOURCE="$FC_BASE/source"
  FC_VENV="$FC_BASE/venv"
  FC_MARKER="$FC_BASE/source-built"
  FC_LOGS="$root/install_logs"
  FC_PYTHON="${FAL_CLIENT_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$FC_BASE" "$FC_SOURCE" "$FC_SOURCE/.git" "$FC_VENV" "$FC_VENV/bin" "$FC_VENV/pyvenv.cfg" "$FC_MARKER" "$FC_LOGS" "$FC_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Fal Client: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

fc_source_ok() {
  [[ -d "$FC_SOURCE/.git" ]] &&
    [[ "$(git -C "$FC_SOURCE" rev-parse --show-toplevel)" == "$FC_SOURCE" ]] &&
    [[ "$(git -C "$FC_SOURCE" remote get-url origin)" == "$FC_URL" ]] &&
    [[ "$(git -C "$FC_SOURCE" rev-parse HEAD)" == "$FC_COMMIT" ]] &&
    [[ -z "$(git -C "$FC_SOURCE" status --porcelain --untracked-files=all)" ]]
}

fc_metadata() {
  "$FC_VENV/bin/python" -I -B - "$FC_SOURCE/projects/fal_client" "$FC_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("fal-client")
assert d.version == "1.0.3"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('fal-client 1.0.3: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

fc_probe() {
  [[ -f "$FC_MARKER" && "$(<"$FC_MARKER")" == "$FC_COMMIT base" && -x "$FC_VENV/bin/python" ]] || return 1
  fc_source_ok && fc_metadata && "$FC_VENV/bin/python" -I -B -m pip --isolated check
}

fc_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'Fal Client: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$FC_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,14)' || {
    echo 'Fal Client: vorhandenes Python 3.10-3.13 verwenden; Ubuntu-Python 3.12 passt.' >&2
    return 1
  }
  [[ ! -e "$FC_VENV" || -f "$FC_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$FC_VENV" ]]; then
    "$FC_PYTHON" -I -B - "$FC_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

fc_resources() {
  local mount="$FC_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$FC_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 1024
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'Fal Client: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

fc_python_core_ok() {
  "$FC_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,14)'
}

fc_python_venv_ok() {
  "$FC_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

fc_venv_package() {
  "$FC_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 14)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

fc_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$FC_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

fc_prepare_python() {
  local package answer='' policy="${FAL_CLIENT_INSTALL_VENV_DEPS:-ask}"
  fc_python_core_ok || {
    echo 'Fal Client: Python 3.10-3.13 mit SSL erforderlich; FAL_CLIENT_PYTHON_BIN pruefen.' >&2
    return 1
  }
  fc_python_venv_ok && return 0
  echo 'Fal Client: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(fc_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder FAL_CLIENT_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  command -v apt-get >/dev/null && command -v sudo >/dev/null || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. Fal Client selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung FAL_CLIENT_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'FAL_CLIENT_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  fc_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  fc_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $FC_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

fc_fetch() {
  if [[ -e "$FC_SOURCE" ]]; then
    fc_source_ok || {
      echo 'Fal-Client-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$FC_SOURCE"
    git -C "$FC_SOURCE" remote add origin "$FC_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$FC_SOURCE" fetch --depth 1 origin "$FC_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$FC_SOURCE" checkout --detach FETCH_HEAD
  fi
  fc_source_ok || return 1
  [[ -f "$FC_SOURCE/projects/fal_client/pyproject.toml" && -f "$FC_SOURCE/projects/fal_client/src/fal_client/__init__.py" ]] || {
    echo 'Erwartetes Fal-Client-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

fc_install_package() {
  rm -f -- "$FC_MARKER"
  "$FC_PYTHON" -I -B -m venv "$FC_VENV"
  # A shallow commit has no SCM tags: version is tied to the verified tag's pin.
  # Only fal_client is installed, not the separate serverless deployment SDK.
  export SETUPTOOLS_SCM_PRETEND_VERSION_FOR_FAL_CLIENT="$FC_VERSION"
  "$FC_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --disable-pip-version-check --index-url https://pypi.org/simple \
    --only-binary=:all: "$FC_SOURCE/projects/fal_client"
  "$FC_VENV/bin/python" -I -B -m pip --isolated check
  fc_metadata
  fc_source_ok || return 1
  printf '%s\n' "$FC_COMMIT base" >"$FC_MARKER"
  echo 'Fal Client aus GitHub in privater venv installiert. Keine fal.ai-Anfragen, Uploads, API-Keys, Modelle oder kostenpflichtigen Jobs.'
}

fc_deactivate() {
  rm -f -- "$FC_MARKER"
  echo 'Fal-Client-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

fal_client_main() (
  set -euo pipefail
  umask 077
  unset FAL_KEY FAL_KEY_ID FAL_KEY_SECRET
  local mode="${1:-install}" program log
  fc_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Fal Client $FC_VERSION: GitHub $FC_URL; Commit $FC_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Keine Deployment-/Dev-/Test-Extras.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if fc_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","cloud_checked":false,"cloud_called":false}'
      else echo '{"installed":false,"scope":"github-base-package","cloud_checked":false,"cloud_called":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      fc_probe || {
        echo 'Fal Client fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Commit und Paketmetadaten konsistent. Kein SDK-Import, Login, API-Auftrag, Upload oder Tokenzugriff.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Fal Client: nur Paketverwaltung, kein API-/Login-/Uploadstart.' >&2
      return 2
      ;;
  esac
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "Fal Client: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$FC_PYTHON" >/dev/null || {
      echo 'Fal Client: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    fc_preflight || return 1
    if [[ "$mode" == install ]] && fc_probe >/dev/null 2>&1; then
      echo 'Fal-Client-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    fc_resources || return 1
  elif [[ ! -d "$FC_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$FC_BASE" "$FC_LOGS"
  exec 9>"$FC_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Fal-Client-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$FC_LOGS/fal_client_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Fal-Client-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $FC_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "Fal-Client-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    fc_deactivate
    return 0
  fi
  fc_prepare_python || return 1
  fc_fetch
  df -Pk "$FC_BASE"
  fc_install_package
  df -Pk "$FC_BASE"
)
