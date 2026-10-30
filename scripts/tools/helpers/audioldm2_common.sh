#!/usr/bin/env bash
set -euo pipefail
AD_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AD_URL=https://github.com/haoheliu/AudioLDM2.git
AD_COMMIT=b5786c5dc0ae8f766337fdc1b67ab6046586d14d
AD_VERSION=0.1.0

ad_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$AD_ROOT/"*)
    echo 'AudioLDM2-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  AD_BASE="$root/tools/audioldm2"
  AD_SOURCE="$AD_BASE/source"
  AD_VENV="$AD_BASE/venv"
  AD_MARKER="$AD_BASE/source-built"
  AD_LOGS="$root/install_logs"
  AD_PYTHON="${AUDIOLDM2_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$AD_BASE" "$AD_SOURCE" "$AD_SOURCE/.git" "$AD_VENV" "$AD_VENV/bin" "$AD_VENV/pyvenv.cfg" "$AD_MARKER" "$AD_LOGS" "$AD_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'AudioLDM2: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

ad_source_ok() {
  [[ -d "$AD_SOURCE/.git" ]] &&
    [[ "$(git -C "$AD_SOURCE" rev-parse --show-toplevel)" == "$AD_SOURCE" ]] &&
    [[ "$(git -C "$AD_SOURCE" remote get-url origin)" == "$AD_URL" ]] &&
    [[ "$(git -C "$AD_SOURCE" rev-parse HEAD)" == "$AD_COMMIT" ]] &&
    [[ -z "$(git -C "$AD_SOURCE" status --porcelain --untracked-files=all)" ]]
}

ad_metadata() {
  "$AD_VENV/bin/python" -I -B - "$AD_SOURCE" "$AD_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("audioldm2")
assert d.version == "0.1.0"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('audioldm2 0.1.0: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

ad_probe() {
  [[ -f "$AD_MARKER" && "$(<"$AD_MARKER")" == "$AD_COMMIT base" && -x "$AD_VENV/bin/python" ]] || return 1
  ad_source_ok && ad_metadata
}

ad_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'AudioLDM2: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$AD_PYTHON" -I -B -c 'import sys; assert (3,10) <= sys.version_info < (3,13)' || {
    echo 'AudioLDM2: vorhandenes Python 3.10-3.12 verwenden; Ubuntu-Python 3.12 passt.' >&2
    return 1
  }
  [[ ! -e "$AD_VENV" || -f "$AD_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$AD_VENV" ]]; then
    "$AD_PYTHON" -I -B - "$AD_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

ad_resources() {
  local mount="$AD_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$AD_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 1024
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'AudioLDM2: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

ad_python_core_ok() {
  "$AD_PYTHON" -I -B -c 'import sys, ssl; assert (3,10) <= sys.version_info < (3,13)'
}

ad_python_venv_ok() {
  "$AD_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

ad_venv_package() {
  "$AD_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

ad_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$AD_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

ad_prepare_python() {
  local package answer='' policy="${AUDIOLDM2_INSTALL_VENV_DEPS:-ask}"
  ad_python_core_ok || {
    echo 'AudioLDM2: Python 3.10-3.12 mit SSL erforderlich; AUDIOLDM2_PYTHON_BIN pruefen.' >&2
    return 1
  }
  ad_python_venv_ok && return 0
  echo 'AudioLDM2: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(ad_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder AUDIOLDM2_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  command -v apt-get >/dev/null && command -v sudo >/dev/null || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. AudioLDM2 selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung AUDIOLDM2_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'AUDIOLDM2_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  ad_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  ad_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $AD_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

ad_fetch() {
  if [[ -e "$AD_SOURCE" ]]; then
    ad_source_ok || {
      echo 'AudioLDM2-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$AD_SOURCE"
    git -C "$AD_SOURCE" remote add origin "$AD_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$AD_SOURCE" fetch --depth 1 origin "$AD_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 git -c core.hooksPath=/dev/null -C "$AD_SOURCE" checkout --detach FETCH_HEAD
  fi
  ad_source_ok || return 1
  [[ -f "$AD_SOURCE/setup.py" && -f "$AD_SOURCE/audioldm2/__init__.py" && -f "$AD_SOURCE/LICENSE" ]] || {
    echo 'Erwartetes AudioLDM2-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

ad_install_package() {
  rm -f -- "$AD_MARKER"
  "$AD_PYTHON" -I -B -m venv "$AD_VENV"
  # Only the pinned local package is built. Legacy runtime is not resolved here.
  "$AD_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
    --no-deps "$AD_SOURCE"
  ad_metadata
  ad_source_ok || return 1
  printf '%s\n' "$AD_COMMIT base" >"$AD_MARKER"
  echo 'AudioLDM2 aus GitHub in privater venv installiert. Nur Basispaket ohne Runtime-Abhaengigkeiten. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

ad_deactivate() {
  rm -f -- "$AD_MARKER"
  echo 'AudioLDM2-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

audioldm2_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log
  ad_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "AudioLDM2 $AD_VERSION: GitHub $AD_URL; Commit $AD_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Nur Paket --no-deps, keine betriebsbereite Audio-Laufzeit.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if ad_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
      else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      ad_probe || {
        echo 'AudioLDM2 fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein Audioldm-/Torch-Import, CLI/WebUI oder Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'AudioLDM2: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${AUDIOLDM2_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'Automatische Legacy-Runtime nicht freigegeben: NumPy<=1.23.5, Gradio<4 und ungepinnter Diffusers-Git-Pfad. Siehe docs/tools/audioldm2.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "AudioLDM2: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$AD_PYTHON" >/dev/null || {
      echo 'AudioLDM2: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    ad_preflight || return 1
    if [[ "$mode" == install ]] && ad_probe >/dev/null 2>&1; then
      echo 'AudioLDM2-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    ad_resources || return 1
  elif [[ ! -d "$AD_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$AD_BASE" "$AD_LOGS"
  exec 9>"$AD_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere AudioLDM2-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$AD_LOGS/audioldm2_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "AudioLDM2-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $AD_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "AudioLDM2-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    ad_deactivate
    return 0
  fi
  ad_prepare_python || return 1
  ad_fetch
  df -Pk "$AD_BASE"
  ad_install_package
  df -Pk "$AD_BASE"
)
