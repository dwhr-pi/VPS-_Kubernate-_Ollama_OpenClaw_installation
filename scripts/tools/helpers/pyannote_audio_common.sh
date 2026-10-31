#!/usr/bin/env bash
set -euo pipefail
PA_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
PA_URL=https://github.com/pyannote/pyannote-audio.git
PA_COMMIT=78c0d16a5f558adb1024d112e6857b3204b450b3
PA_TAG=4.0.4

pa_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$PA_ROOT/"*)
    echo 'Pyannote-Workspace nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  PA_BASE="$root/tools/pyannote_audio"
  PA_SOURCE="$PA_BASE/source"
  PA_VENV="$PA_BASE/venv"
  PA_MARKER="$PA_BASE/source-ready"
  PA_RUNTIME_MARKER="$PA_BASE/runtime-ready"
  PA_LOGS="$root/install_logs"
  for path in "$root" "$PA_BASE" "$PA_SOURCE" "$PA_SOURCE/.git" "$PA_VENV" "$PA_MARKER" "$PA_RUNTIME_MARKER" "$PA_LOGS" "$PA_BASE/operation.lock" "$PA_BASE/runtime-constraints.txt"; do
    [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
      echo 'Pyannote: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
  done
}

pa_source_ok() {
  [[ -d "$PA_SOURCE/.git" ]] &&
    [[ "$(git -C "$PA_SOURCE" rev-parse --show-toplevel)" == "$PA_SOURCE" ]] &&
    [[ "$(git -C "$PA_SOURCE" remote get-url origin)" == "$PA_URL" ]] &&
    [[ "$(git -C "$PA_SOURCE" rev-parse HEAD)" == "$PA_COMMIT" ]] &&
    [[ "$(git -C "$PA_SOURCE" rev-parse "refs/tags/$PA_TAG^{}")" == "$PA_COMMIT" ]] &&
    [[ -z "$(git -C "$PA_SOURCE" status --porcelain --untracked-files=all)" ]]
}

pa_syntax() {
  "$PA_PYTHON" -I -B - "$PA_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('src/pyannote/audio/__init__.py', 'src/pyannote/audio/core/pipeline.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'pyproject.toml').is_file()
print('Pyannote-Quellen geprueft; kein Import, Audio- oder Modellzugriff.')
PY
}

pa_fetch_source() {
  if [[ -e "$PA_SOURCE" ]]; then
    pa_source_ok || {
      echo 'Pyannote-Quelle fremd/unvollstaendig/veraendert; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    mkdir "$PA_SOURCE"
    git -C "$PA_SOURCE" init
    git -C "$PA_SOURCE" remote add origin "$PA_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$PA_SOURCE" fetch --depth 1 origin "refs/tags/$PA_TAG:refs/tags/$PA_TAG"
    [[ "$(git -C "$PA_SOURCE" rev-parse "refs/tags/$PA_TAG^{}")" == "$PA_COMMIT" ]] || {
      echo 'Pyannote-Release-Tag weicht vom geprueften Commit ab; Abbruch.' >&2
      return 1
    }
    git -c core.hooksPath=/dev/null -C "$PA_SOURCE" checkout --detach "$PA_COMMIT"
  fi
  pa_source_ok && pa_syntax || return 1
  printf '%s\n' "$PA_COMMIT" >"$PA_MARKER"
  echo 'pyannote.audio aus GitHub vorbereitet. Quellen allein sind keine lauffertige Diarisierung.'
}

pa_runtime_preflight() {
  [[ "${INSTALL_HEAVY_TOOLS:-0}" == 1 ]] || {
    echo 'PyTorch-Pakete brauchen zusaetzlich INSTALL_HEAVY_TOOLS=1.' >&2
    return 1
  }
  [[ "$(uname -m)" == x86_64 ]] || {
    echo 'Automatischer CPU-Wheel-Pfad ist auf Linux x86_64 begrenzt; ARM nur Quellen.' >&2
    return 1
  }
  "$PA_PYTHON" -I -B -c 'import sys, venv; assert (3,10) <= sys.version_info < (3,14)' || {
    echo 'Pyannote-Paketpfad: vorhandenes Python 3.10-3.13 mit venv verwenden; Python 3.12 passt.' >&2
    return 1
  }
  command -v ffmpeg >/dev/null || {
    echo 'FFmpeg fehlt (TorchCodec-Decoding). Bewusst separat einrichten; keine automatische Systeminstallation.' >&2
    return 1
  }
}

pa_runtime_check() {
  [[ -f "$PA_RUNTIME_MARKER" && "$(<"$PA_RUNTIME_MARKER")" == "$PA_COMMIT cpu" && -x "$PA_VENV/bin/python" ]] || return 1
  "$PA_VENV/bin/python" -I -B -m pip --isolated check || return 1
  "$PA_VENV/bin/python" -I -B -c \
    'from importlib.metadata import version; assert version("pyannote-audio") == "4.0.4"; assert version("torch") == "2.10.0+cpu"; assert version("torchaudio") == "2.10.0+cpu"; assert version("torchcodec").split("+")[0] == "0.10.0"'
}

pa_install_runtime() {
  local constraints="$PA_BASE/runtime-constraints.txt"
  [[ ! -e "$PA_VENV" || -f "$PA_VENV/pyvenv.cfg" ]] || {
    echo 'Fremdes venv-Ziel; nichts ueberschrieben.' >&2
    return 1
  }
  rm -f -- "$PA_RUNTIME_MARKER"
  "$PA_PYTHON" -I -B -m venv "$PA_VENV"
  printf '%s\n' 'torch==2.10.0+cpu' 'torchaudio==2.10.0+cpu' 'torchcodec==0.10.0' >"$constraints"
  export PYANNOTE_METRICS_ENABLED=0 HF_HUB_DISABLE_TELEMETRY=1 HF_HUB_OFFLINE=1
  export DO_NOT_TRACK=1 OTEL_SDK_DISABLED=true
  "$PA_VENV/bin/python" -I -B -m pip --isolated install \
    --index-url https://download.pytorch.org/whl/cpu --only-binary=:all: --no-cache-dir \
    torch==2.10.0 torchaudio==2.10.0 torchcodec==0.10.0
  # pyproject/Hatch builds the tagged Git checkout; do not run legacy setup.py.
  "$PA_VENV/bin/python" -I -B -m pip --isolated install --index-url https://pypi.org/simple \
    --no-cache-dir --disable-pip-version-check -c "$constraints" "$PA_SOURCE"
  "$PA_VENV/bin/python" -I -B -m pip --isolated check
  "$PA_VENV/bin/python" -I -B -c \
    'from importlib.metadata import version; assert version("pyannote-audio") == "4.0.4"; assert version("torch") == "2.10.0+cpu"; assert version("torchaudio") == "2.10.0+cpu"; assert version("torchcodec").split("+")[0] == "0.10.0"'
  printf '%s\n' "$PA_COMMIT cpu" >"$PA_RUNTIME_MARKER"
  echo 'Private CPU-Pakete installiert. Keine Modelle/Token, kein Pipeline-Import oder Audio-/GPU-Test.'
}

pa_deactivate() {
  rm -f -- "$PA_MARKER" "$PA_RUNTIME_MARKER"
  echo 'Pyannote-Setup-Marker deaktiviert. Quellen, venv, Modelle, Audios und Logs bleiben erhalten.'
}

pyannote_audio_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" program mount log
  pa_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "pyannote.audio: GitHub $PA_URL; Tag $PA_TAG; Commit $PA_COMMIT; ohne Docker."
      echo "Standard nur Quellen. PYANNOTE_AUDIO_INSTALL_RUNTIME=${PYANNOTE_AUDIO_INSTALL_RUNTIME:-0}; CPU-Pakete nur zusaetzlich INSTALL_HEAVY_TOOLS=1."
      echo 'Keine Modelle, Tokens, Telemetrie-/Cloud-/Audioaktionen oder Downloads im Dry-Run.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall | status | --status | doctor | check | --check) ;;
    *)
      echo 'Pyannote: nur Quell-/Paketverwaltung, kein Audio-/Pipeline-/Serverstart.' >&2
      return 2
      ;;
  esac
  PA_PYTHON="${PYANNOTE_AUDIO_PYTHON_BIN:-python3}"
  case "$mode" in
    status | --status)
      if [[ -f "$PA_MARKER" && "$(<"$PA_MARKER")" == "$PA_COMMIT" ]] && pa_source_ok >/dev/null 2>&1; then
        echo '{"source_ready":true,"runtime_state":"run_doctor","models_checked":false,"authenticity_verdict":null}'
      else echo '{"source_ready":false,"runtime_state":"not_checked","models_checked":false,"authenticity_verdict":null}'; fi
      return 0
      ;;
    doctor | check | --check)
      [[ -f "$PA_MARKER" && "$(<"$PA_MARKER")" == "$PA_COMMIT" ]] && pa_source_ok && pa_syntax || return 1
      if [[ -e "$PA_RUNTIME_MARKER" ]]; then pa_runtime_check || return 1; else echo 'CPU-Pakete nicht eingerichtet; nur Quellen vorhanden.'; fi
      echo 'Kein Modell-, Decoder-, Diarisierungs- oder Echtheitstest.'
      return 0
      ;;
  esac
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git "$PA_PYTHON" flock; do
    command -v "$program" >/dev/null || {
      echo "Pyannote: $program fehlt; Basiswerkzeug separat einrichten." >&2
      return 1
    }
  done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    [[ "${PYANNOTE_AUDIO_INSTALL_RUNTIME:-0}" == 0 || "${PYANNOTE_AUDIO_INSTALL_RUNTIME:-0}" == 1 ]] || return 2
    if [[ "${PYANNOTE_AUDIO_INSTALL_RUNTIME:-0}" == 1 ]]; then pa_runtime_preflight || return 1; fi
    mount="$PA_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$PA_ROOT/scripts/lib/resource_check.sh"
    if [[ "${PYANNOTE_AUDIO_INSTALL_RUNTIME:-0}" == 1 ]]; then
      require_ram_mb 8192
      REQUIRE_WINDOWS_HOST_FREE_MB=10240 require_disk_mb 10240 "$mount"
    else REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"; fi
  elif [[ ! -d "$PA_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$PA_BASE" "$PA_LOGS"
  exec 9>"$PA_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Pyannote-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$PA_LOGS/pyannote_audio_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Pyannote-Audio-Installer: 2026-10-16-github-source-cpu; Aktion: $mode; Commit: $PA_COMMIT"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "Pyannote-Fehler ($rc). Dateien erhalten. Log: $log; nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    pa_deactivate
    return 0
  fi
  pa_fetch_source
  if [[ "${PYANNOTE_AUDIO_INSTALL_RUNTIME:-0}" == 1 ]]; then
    if [[ "$mode" == install ]] && pa_runtime_check >/dev/null 2>&1; then
      echo 'CPU-Pakete bereits konsistent; keine erneute Installation.'
    else pa_install_runtime; fi
  else echo 'Keine CPU-/GPU-Pakete installiert. Optionalen Paketpfad siehe docs/tools/pyannote-audio.md.'; fi
)
