#!/usr/bin/env bash
set -euo pipefail
KE_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
KE_URL=https://github.com/showlab/Kiwi-Edit.git
KE_COMMIT=178f3f4f8221d7598fcc21875c847d6cf6323c4e
KE_VERSION=2.0.4

ke_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$KE_ROOT/"*)
    echo 'Kiwi Edit-Daten nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  KE_BASE="$root/tools/kiwi_edit"
  KE_SOURCE="$KE_BASE/source"
  KE_VENV="$KE_BASE/venv"
  KE_MARKER="$KE_BASE/source-built"
  KE_LOGS="$root/install_logs"
  KE_PYTHON="${KIWI_EDIT_PYTHON_BIN:-python3}"
  # Allow the normal venv Python symlink, not redirecting directories.
  local index=0
  local -a paths=("$root" "$KE_BASE" "$KE_SOURCE" "$KE_SOURCE/.git" "$KE_VENV" "$KE_VENV/bin" "$KE_VENV/pyvenv.cfg" "$KE_MARKER" "$KE_LOGS" "$KE_BASE/operation.lock") resolved=()
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Kiwi Edit: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

ke_source_ok() {
  [[ -d "$KE_SOURCE/.git" && ! -e "$KE_SOURCE/.env" && ! -L "$KE_SOURCE/.env" ]] &&
    [[ "$(git -C "$KE_SOURCE" rev-parse --show-toplevel)" == "$KE_SOURCE" ]] &&
    [[ "$(git -C "$KE_SOURCE" remote get-url origin)" == "$KE_URL" ]] &&
    [[ "$(git -C "$KE_SOURCE" rev-parse HEAD)" == "$KE_COMMIT" ]] &&
    [[ "$(git -C "$KE_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
    [[ "$(git -C "$KE_SOURCE" sparse-checkout list)" == "$(ke_sparse_patterns)" ]] &&
    [[ -z "$(git -C "$KE_SOURCE" status --porcelain --untracked-files=all)" ]]
}

ke_metadata() {
  "$KE_VENV/bin/python" -I -B - "$KE_SOURCE" "$KE_VENV" <<'PY'
from importlib.metadata import distribution
import json
from pathlib import Path
import sys
from urllib.parse import unquote, urlparse
assert sys.prefix != sys.base_prefix
assert Path(sys.prefix).resolve() == Path(sys.argv[2]).resolve()
d = distribution("diffsynth")
assert d.version == "2.0.4"
origin = urlparse(json.loads(d.read_text("direct_url.json"))["url"])
assert origin.scheme == "file" and origin.netloc == ""
assert Path(unquote(origin.path)).resolve() == Path(sys.argv[1]).resolve()
print('diffsynth 2.0.4 / Kiwi Edit: Metadaten/Quellpfad geprueft, kein SDK-Import.')
PY
}

ke_probe() {
  [[ -f "$KE_MARKER" && "$(<"$KE_MARKER")" == "$KE_COMMIT base" && -x "$KE_VENV/bin/python" ]] || return 1
  ke_source_ok && ke_metadata
}

ke_preflight() {
  case "$(uname -m)" in x86_64 | aarch64) ;; *)
    echo 'Kiwi Edit: automatischer Wheel-Pfad nur Linux x86_64/ARM64.' >&2
    return 1
    ;;
  esac
  "$KE_PYTHON" -I -B -c 'import sys; assert (3,10,1) <= sys.version_info < (3,13)' || {
    echo 'Kiwi Edit: fuer das Basispaket Python 3.10.1-3.12 verwenden; GPU-Wheels aus Upstream brauchen gesonderte Pruefung.' >&2
    return 1
  }
  [[ ! -e "$KE_VENV" || -f "$KE_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Verzeichnis; nichts ueberschrieben.' >&2
    return 1
  }
  if [[ -e "$KE_VENV" ]]; then
    "$KE_PYTHON" -I -B - "$KE_VENV/pyvenv.cfg" <<'PY' || return 1
from pathlib import Path
import sys
assert 'include-system-site-packages = false' in Path(sys.argv[1]).read_text()
PY
  fi
}

ke_resources() {
  local mount="$KE_BASE" available
  while [[ ! -d "$mount" ]]; do
    mount="${mount%/*}"
    [[ -n "$mount" ]] || mount=/
  done
  # shellcheck source=../../lib/resource_check.sh
  source "$KE_ROOT/scripts/lib/resource_check.sh"
  require_ram_mb 1024 || return 1
  available="$(awk '/^MemAvailable:/ {printf "%d\n", $2/1024}' /proc/meminfo)"
  [[ "$available" =~ ^[0-9]+$ && "$available" -ge 512 ]] || {
    echo 'Kiwi Edit: mindestens 512 MiB aktuell verfuegbaren RAM freimachen; kein Swap-/WSL-Umbau.' >&2
    return 1
  }
  REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 2048 "$mount"
}

ke_python_core_ok() {
  "$KE_PYTHON" -I -B -c 'import sys, ssl; assert (3,10,1) <= sys.version_info < (3,13)'
}

ke_python_venv_ok() {
  "$KE_PYTHON" -I -B -c 'import venv, ensurepip' >/dev/null 2>&1
}

ke_venv_package() {
  "$KE_PYTHON" -I -B - <<'PY'
from pathlib import Path
import sys
expected = Path('/usr/bin/python%d.%d' % sys.version_info[:2])
assert sys.prefix == sys.base_prefix, 'Keine Paket-Reparatur innerhalb einer venv'
assert Path(sys.executable).resolve() == expected.resolve(), 'Kein Ubuntu-Systeminterpreter'
assert (3, 10, 1) <= sys.version_info < (3, 13)
print('python%d.%d-venv' % sys.version_info[:2])
PY
}

ke_install_venv_package() {
  # shellcheck source=../../lib/apt_lock_wait.sh
  source "$KE_ROOT/scripts/lib/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return 1
  run_apt_with_lock_wait install -y --no-install-recommends "$1"
}

ke_prepare_python() {
  local package answer='' policy="${KIWI_EDIT_INSTALL_VENV_DEPS:-ask}"
  ke_python_core_ok || {
    echo 'Kiwi Edit: Python 3.10.1-3.12 mit SSL erforderlich; KIWI_EDIT_PYTHON_BIN pruefen.' >&2
    return 1
  }
  ke_python_venv_ok && return 0
  echo 'Kiwi Edit: Dem gewaehlten Python fehlt venv/ensurepip.'
  package="$(ke_venv_package)" || {
    echo 'Privates/fremdes Python: dessen venv/ensurepip separat reparieren oder KIWI_EDIT_PYTHON_BIN passend setzen; kein System-Python ersetzt.' >&2
    return 1
  }
  { command -v apt-get >/dev/null && command -v sudo >/dev/null; } || {
    echo "Keine apt/sudo-Reparatur verfuegbar. $package separat einrichten." >&2
    return 1
  }
  echo "Notwendiges Systempaket: $package. Kiwi Edit selbst bleibt aus GitHub, ohne Docker."
  case "$policy" in
    1) ;;
    ask)
      if [[ -t 0 ]]; then
        read -r -p "$package mit sudo installieren? [(j)a/(N)ein]: " answer || answer=''
      fi
      [[ "$answer" == j || "$answer" == J ]] || {
        echo 'Nicht installiert. Nach Zustimmung KIWI_EDIT_INSTALL_VENV_DEPS=1 mit --repair verwenden.' >&2
        return 1
      }
      ;;
    0)
      echo 'Installation von venv-Systempaketen deaktiviert.' >&2
      return 1
      ;;
    *)
      echo 'KIWI_EDIT_INSTALL_VENV_DEPS: nur ask, 0 oder 1 erlaubt.' >&2
      return 2
      ;;
  esac
  ke_install_venv_package "$package" || {
    echo "Installation von $package fehlgeschlagen; kein Clone/Build." >&2
    return 1
  }
  ke_python_venv_ok || {
    echo "venv/ensurepip fehlt weiterhin fuer $KE_PYTHON; kein Clone/Build." >&2
    return 1
  }
  echo 'venv/ensurepip verfuegbar; kein System-Python ersetzt.'
}

ke_sparse_patterns() {
  cat <<'PATTERNS'
/README.md
/.gitignore
/LICENSE
/pyproject.toml
/diffsynth/
/demo.py
/diffusers_demo.py
/train.py
/scripts/
/utils/
!*.pt
!*.pth
!*.onnx
!*.bin
!*.safetensors
!*.pkl
!*.npy
!*.npz
!*.mp4
!*.webm
!*.mov
!*.wav
!*.mp3
!*.flac
!*.png
!*.jpg
!*.jpeg
!*.gif
!*.webp
!*.ipynb
!*.ckpt
!*.zip
!*.tar.gz
!.env
!.env.*
PATTERNS
}

ke_sparse_checkout() {
  ke_sparse_patterns | git -C "$KE_SOURCE" sparse-checkout set --no-cone --stdin
}

ke_fetch() {
  if [[ -e "$KE_SOURCE" ]]; then
    ke_source_ok || {
      echo 'Kiwi Edit-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$KE_SOURCE"
    git -C "$KE_SOURCE" remote add origin "$KE_URL"
    ke_sparse_checkout
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$KE_SOURCE" fetch --filter=blob:none --depth 1 origin "$KE_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$KE_SOURCE" checkout --detach FETCH_HEAD
  fi
  ke_source_ok || return 1
  [[ -f "$KE_SOURCE/pyproject.toml" && -f "$KE_SOURCE/diffsynth/__init__.py" && -f "$KE_SOURCE/LICENSE" ]] || {
    echo 'Erwartetes Kiwi Edit-Paketlayout fehlt; kein anderer Installationspfad.' >&2
    return 1
  }
}

ke_install_package() {
  rm -f -- "$KE_MARKER"
  "$KE_PYTHON" -I -B -m venv "$KE_VENV"
  # Only the pinned local package is built. GPU runtime is not resolved here.
  "$KE_VENV/bin/python" -I -B -m pip --isolated install --no-cache-dir \
    --use-pep517 --disable-pip-version-check --index-url https://pypi.org/simple \
    --no-deps "$KE_SOURCE"
  ke_metadata
  ke_source_ok || return 1
  printf '%s\n' "$KE_COMMIT base" >"$KE_MARKER"
  echo 'Kiwi Edit aus GitHub in privater venv installiert. Nur Basispaket ohne Runtime-Abhaengigkeiten. Keine Checkpoints/Referenzaudios, CLI/WebUI oder Inferenz gestartet.'
}

ke_deactivate() {
  rm -f -- "$KE_MARKER"
  echo 'Kiwi Edit-Setup-Marker deaktiviert; Quelle, venv, eigene Daten, Cache, Token und Logs bleiben erhalten.'
}

kiwi_edit_main() (
  set -euo pipefail
  umask 077
  unset HF_TOKEN HUGGING_FACE_HUB_TOKEN GEMINI_API_KEY GOOGLE_API_KEY WANDB_API_KEY
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program log
  ke_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Kiwi Edit $KE_VERSION: GitHub $KE_URL; Commit $KE_COMMIT; private Basis-venv ohne Docker."
      echo 'Reserve: 1 GiB gesamt, 512 MiB verfuegbar, 2 GiB Disk/Windows-C:. Nur Paket --no-deps, keine betriebsbereite Video-Laufzeit.'
      echo 'Dry-Run ohne Download, Installation, API-/Token-/Uploadzugriff.'
      return 0
      ;;
    status | --status)
      if ke_probe >/dev/null 2>&1; then
        echo '{"installed":true,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'
      else echo '{"installed":false,"scope":"github-base-package","runtime_dependencies":false,"models_checked":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      ke_probe || {
        echo 'Kiwi Edit fehlt/deaktiviert oder Quelle/Pakete inkonsistent; --repair verwenden.' >&2
        return 1
      }
      echo 'Pin/Paketmetadaten konsistent, Runtime-Abhaengigkeiten fehlen absichtlich. Kein DiffSynth-/Torch-Import, CLI/WebUI oder Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Kiwi Edit: nur Paketverwaltung, kein Modell-/Demo-/Trainingstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${KIWI_EDIT_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'Automatische GPU-Runtime nicht freigegeben: Kiwi-Edit-Upstream verwendet Python 3.10/CUDA 12.8 sowie Torch 2.7.0; Modelle und trust_remote_code separat pruefen. Siehe docs/tools/kiwi-edit.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git flock; do command -v "$program" >/dev/null || {
    echo "Kiwi Edit: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    command -v "$KE_PYTHON" >/dev/null || {
      echo 'Kiwi Edit: Python fehlt; Basis separat einrichten.' >&2
      return 1
    }
    ke_preflight || return 1
    if [[ "$mode" == install ]] && ke_probe >/dev/null 2>&1; then
      echo 'Kiwi Edit-Basispaket bereits konsistent; keine Installation.'
      return 0
    fi
    ke_resources || return 1
  elif [[ ! -d "$KE_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$KE_BASE" "$KE_LOGS"
  exec 9>"$KE_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Kiwi Edit-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$KE_LOGS/kiwi_edit_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Kiwi Edit-Installer: 2026-10-19-venv-dependency-repair; Aktion: $mode; Pin: $KE_COMMIT"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "Kiwi Edit-Fehler ($rc); Dateien erhalten. Log: $log. Nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    ke_deactivate
    return 0
  fi
  ke_prepare_python || return 1
  ke_fetch
  df -Pk "$KE_BASE"
  ke_install_package
  df -Pk "$KE_BASE"
)
