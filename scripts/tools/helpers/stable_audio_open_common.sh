#!/usr/bin/env bash
set -euo pipefail
SA_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
SA_URL=https://github.com/Stability-AI/stable-audio-tools.git
SA_COMMIT=3241adba4fc2a85cf5b29d9eb68d42f40a28e820
SA_VERSION=0.0.20
source "$SA_ROOT/scripts/lib/private_cpython310.sh"

sa_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$SA_ROOT/"*)
    echo 'Stable Audio Open-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  SA_BASE="$root/tools/stable_audio_open"
  SA_SOURCE="$SA_BASE/source"
  SA_VENV="$SA_BASE/venv"
  SA_MARKER="$SA_BASE/source-built"
  SA_LOGS="$root/install_logs"
  SA_PYTHON="${STABLE_AUDIO_OPEN_PYTHON_BIN:-python3.10}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$SA_BASE" "$SA_SOURCE" "$SA_SOURCE/.git" "$SA_VENV" "$SA_VENV/bin" "$SA_VENV/pyvenv.cfg" "$SA_MARKER" "$SA_LOGS" "$SA_BASE/operation.lock" "$SA_BASE/runtime" "$SA_BASE/runtime/python-3.10.22" "$SA_BASE/runtime/python-3.10.22/bin") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Stable Audio Open: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

sa_source_ok() {
  [[ -d "$SA_SOURCE/.git" ]] &&
    [[ "$(git -C "$SA_SOURCE" rev-parse --show-toplevel)" == "$SA_SOURCE" ]] &&
    [[ "$(git -C "$SA_SOURCE" remote get-url origin)" == "$SA_URL" ]] &&
    [[ "$(git -C "$SA_SOURCE" rev-parse HEAD)" == "$SA_COMMIT" ]] &&
    [[ -z "$(git -C "$SA_SOURCE" status --porcelain --untracked-files=all)" ]]
}

sa_metadata() {
  "$SA_VENV/bin/python" -I -B - "$SA_SOURCE" "$SA_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("stable-audio-tools")
assert d.version == "0.0.20"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('stable-audio-tools 0.0.20 / Stable Audio Open: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

sa_probe() {
  [[ -f "$SA_MARKER" && "$(<"$SA_MARKER")" == "$SA_COMMIT base" && -x "$SA_VENV/bin/python" ]] || return 1
  sa_source_ok && sa_metadata
}

sa_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'Stable Audio Open: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$SA_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,11)' || {
    echo 'Stable Audio Open: Python 3.10 erforderlich (Upstream >=3.10,<3.11); STABLE_AUDIO_OPEN_PYTHON_BIN setzen. Python 3.11/3.12 wird nicht verwendet.' >&2
    return 1
  }
  [[ ! -e "$SA_VENV" || -f "$SA_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$SA_VENV" ]]; then
    "$SA_PYTHON" -I -B - "$SA_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

sa_resources() {
  local mount="$SA_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$SA_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 1024 || return 1
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'Stable Audio Open: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

sa_prepare_python() {
  "$SA_PYTHON" -I -B -c 'import venv, ensurepip, ssl' || {
    echo 'venv/ensurepip/SSL fehlt. Zum ausgewaehlten Python passendes venv-Paket separat einrichten, dann --repair; kein System-Python ersetzt.' >&2
    return 1
  }
}

sa_python_build_resources() {
  source "$SA_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 4096 || return 1
  local available
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 2048 ]] || {
    echo 'CPython-Build: mindestens 2048 MiB aktuell freien RAM freimachen.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=8192 require_disk_mb 8192 "$SA_BASE"
}

sa_select_python() {
  local candidate answer="" consent="${STABLE_AUDIO_OPEN_BUILD_PYTHON:-ask}"
  if [[ -n "${STABLE_AUDIO_OPEN_PYTHON_BIN:-}" ]]; then
    command -v "$SA_PYTHON" >/dev/null && private_cpython310_ok "$SA_PYTHON" || {
      echo 'Explizites STABLE_AUDIO_OPEN_PYTHON_BIN ist nicht nutzbar (Python 3.10 + venv/SSL erforderlich). Keine automatische Ersetzung.' >&2
      return 1
    }
    return 0
  fi
  for candidate in "$SA_BASE/runtime/python-3.10.22/bin/python3.10" python3.10 python3; do
    if command -v "$candidate" >/dev/null && private_cpython310_ok "$candidate" >/dev/null 2>&1; then
      SA_PYTHON="$candidate"
      return 0
    fi
  done
  echo 'Python 3.10 fehlt. Optional isoliertes CPython 3.10.22 aus GitHub bauen; System-Python bleibt unveraendert.'
  case "$consent" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p 'CPython bauen (zeit-/speicherintensiv; ggf. sudo fuer Buildbibliotheken)? [(j)a/(N)ein]: ' answer || return 1
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Build nicht freigegeben. STABLE_AUDIO_OPEN_BUILD_PYTHON=1 erlaubt den Build, =0 sperrt ihn.' >&2
        return 1
      }
      ;;
    0)
      echo 'Privater Python-Build deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'STABLE_AUDIO_OPEN_BUILD_PYTHON: ask, 0 oder 1 erwartet.' >&2
      return 2
      ;;
  esac
  sa_python_build_resources || return 1
  SA_PYTHON="$(build_private_cpython310 "$SA_BASE")" || return $?
  private_cpython310_ok "$SA_PYTHON"
}

sa_fetch() {
  if [[ -e "$SA_SOURCE" ]]; then
    sa_source_ok || {
      echo 'Stable Audio Open-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$SA_SOURCE"
    git -C "$SA_SOURCE" remote add origin "$SA_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$SA_SOURCE" fetch --depth 1 origin "$SA_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$SA_SOURCE" checkout --detach FETCH_HEAD
  fi
  sa_source_ok || return 1
  [[ -f "$SA_SOURCE/pyproject.toml" && -f "$SA_SOURCE/stable_audio_tools/__init__.py" && -f "$SA_SOURCE/LICENSE" ]] || {
    echo 'Erwartetes Stable Audio Open-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

sa_install_package() {
  rm -f -- "$SA_MARKER"
  "$SA_PYTHON" -I -B -m venv "$SA_VENV"
  # Only the pinned local package is built. GPU runtime is not resolved here.
  "$SA_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
    --no-deps "$SA_SOURCE"
  sa_metadata
  sa_source_ok || return 1
  printf '%s\n' "$SA_COMMIT base" >"$SA_MARKER"
  echo 'Stable Audio Open aus GitHub in privater venv installiert. Nur Basispaket ohne Runtime-Abhaengigkeiten. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

sa_deactivate() {
  rm -f -- "$SA_MARKER"
  echo 'Stable Audio Open-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

stable_audio_open_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log
  sa_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Stable Audio Open $SA_VERSION: GitHub $SA_URL; Commit $SA_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Nur Paket --no-deps, keine betriebsbereite Audio-Laufzeit.'
      echo 'Fehlendes Python 3.10: GitHub-Build nur bestaetigt oder STABLE_AUDIO_OPEN_BUILD_PYTHON=1; zusaetzlich 4 GiB RAM/2 GiB frei/8 GiB Disk, ein Buildjob.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if sa_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
      else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      sa_probe || {
        echo 'Stable Audio Open fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein Stable-Audio-/Torch-Import, CLI/WebUI oder Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Stable Audio Open: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${STABLE_AUDIO_OPEN_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'Automatische GPU-Runtime nicht freigegeben: stable-audio-tools 0.0.20 verlangt Python 3.10, torch==2.7.1 und torchaudio==2.7.1; GPU-/Wheel-Pfad separat testen. Siehe docs/tools/stable-audio-open.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "Stable Audio Open: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    if [[ "$mode" == install ]] && sa_probe >/dev/null 2>&1; then
      echo 'Stable Audio Open-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    sa_resources || return 1
  elif [[ ! -d "$SA_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$SA_BASE" "$SA_LOGS"
  exec 9>"$SA_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Stable Audio Open-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$SA_LOGS/stable_audio_open_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Stable Audio Open-Installer: 2026-10-18-private-python310; Aktion: $mode; Pin: $SA_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "Stable Audio Open-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    sa_deactivate
    return 0
  fi
  sa_select_python || return $?
  sa_preflight || return 1
  sa_prepare_python
  sa_fetch
  df -Pk "$SA_BASE"
  sa_install_package
  df -Pk "$SA_BASE"
)
