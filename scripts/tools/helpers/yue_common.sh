#!/usr/bin/env bash
set -euo pipefail
YU_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
YU_URL=https://github.com/multimodal-art-projection/YuE.git
YU_COMMIT=6d4f0b1f8ce6a55fb2392e959394c46e07ee334d

yu_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
  local -a paths=() resolved=()
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$YU_ROOT/"*)
    echo 'YuE-Workspace nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  YU_BASE="$root/tools/yue"
  YU_SOURCE="$YU_BASE/source"
  YU_MARKER="$YU_BASE/source-ready"
  YU_LOGS="$root/install_logs"
  paths=("$root" "$YU_BASE" "$YU_SOURCE" "$YU_SOURCE/.git" "$YU_MARKER" "$YU_LOGS" "$YU_BASE/operation.lock")
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'YuE: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

yu_source_ok() {
  local top state
  top="$(git -C "$YU_SOURCE" rev-parse --show-toplevel)" || return 1
  state="$(git -C "$YU_SOURCE" status --porcelain --untracked-files=all)" || return 1
  [[ -d "$YU_SOURCE/.git" && ! -e "$YU_SOURCE/.env" && ! -L "$YU_SOURCE/.env" ]] &&
    [[ "$top" -ef "$YU_SOURCE" ]] &&
    [[ "$(git -C "$YU_SOURCE" remote get-url origin)" == "$YU_URL" ]] &&
    [[ "$(git -C "$YU_SOURCE" rev-parse HEAD)" == "$YU_COMMIT" ]] &&
    [[ "$(git -C "$YU_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
    [[ "$(git -C "$YU_SOURCE" sparse-checkout list)" == "$(yu_sparse_patterns)" ]] &&
    [[ -z "$state" ]]
}

yu_inspect() {
  yu_source_ok || return 1
  python3 -I -B - "$YU_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('inference/infer.py', 'inference/mmtokenizer.py', 'inference/codecmanipulator.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'requirements.txt').is_file()
assert (root / 'LICENSE').is_file()
assert not (root / '.env').exists()
print('YuE-Pin und Syntax geprueft; keine Imports oder Laufzeitinstallation.')
PY
}

yu_sparse_patterns() {
  # Allow source trees only; root .env, media, notebooks and weights are not checked out.
  cat <<'PATTERNS'
/README.md
/LICENSE
/requirements.txt
/inference/
/prompt_egs/
!*.model
!*.pt
!*.pth
!*.onnx
!*.bin
!*.safetensors
!*.pkl
!*.npy
!*.npz
!*.wav
!*.mp3
!*.mp4
!*.webm
!*.mov
!*.flac
!*.ogg
!*.m4a
!*.png
!*.jpg
!*.jpeg
!*.gif
!*.webp
!*.ipynb
!*.ckpt
!*.h5
!*.tar.gz
!*.zip
!.env
!.env.*
PATTERNS
}

yu_sparse_checkout() {
  yu_sparse_patterns | git -C "$YU_SOURCE" sparse-checkout set --no-cone --stdin
}

yu_fetch() {
  if [[ -e "$YU_SOURCE" ]]; then
    yu_source_ok || {
      echo 'YuE-Quelle fremd/unvollstaendig/veraendert oder voller Checkout; manuell sichern. Kein Reset/Loeschen.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$YU_SOURCE" || return 1
    git -C "$YU_SOURCE" remote add origin "$YU_URL" || return 1
    yu_sparse_checkout || return 1
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$YU_SOURCE" fetch --filter=blob:none --depth 1 origin "$YU_COMMIT" || return 1
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$YU_SOURCE" checkout --detach FETCH_HEAD || return 1
  fi
  yu_inspect || return 1
  printf '%s\n' "$YU_COMMIT" >"$YU_MARKER"
  echo 'YuE-GitHub-Quellinstallation vorbereitet (nicht betriebsbereit). Keine Python-Pakete, Modelle oder Dienste installiert/gestartet.'
}

yu_deactivate() {
  rm -f -- "$YU_MARKER"
  echo 'YuE-Quellregistrierung deaktiviert; Quelle, eigene Daten/Modelle und Logs bleiben erhalten.'
}

yue_main() (
  set -euo pipefail
  umask 077
  unset GEMINI_API_KEY GOOGLE_API_KEY HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program mount log
  yu_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo 'Generation: YuE-v1, kein automatischer Wechsel zu YuE2/main.'
      echo "YuE GitHub: $YU_URL; Pin $YU_COMMIT; ohne Docker."
      echo 'Nur Quellinstallation via Sparse-Checkout, keine .env/Medien/Gewichte im Arbeitsbaum. KEINE betriebsbereite Musik-Laufzeit.'
      echo 'Reserve 1 GiB Disk, 2 GiB Windows-C:; Dry-Run ohne Download oder Import.'
      return 0
      ;;
    status | --status)
      if [[ -f "$YU_MARKER" && "$(<"$YU_MARKER")" == "$YU_COMMIT" ]] && yu_source_ok >/dev/null 2>&1; then
        echo '{"source_ready":true,"runtime_ready":false,"scope":"github-source-only"}'
      else echo '{"source_ready":false,"runtime_ready":false,"scope":"github-source-only"}'; fi
      return 0
      ;;
    doctor | check | --check)
      [[ -f "$YU_MARKER" && "$(<"$YU_MARKER")" == "$YU_COMMIT" ]] && yu_inspect || return 1
      echo 'Quellen geprueft, Musik-Laufzeit NICHT eingerichtet; kein GUI-/Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'YuE: nur Quellverwaltung, kein App-/Musik-/Serverstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${YUE_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'YuE-v1-Laufzeit separat einrichten: ungepinnte Python-Requirements, GPU-Stack, xcodec-Tokenizer und Modellgewichte fehlen. Kein YuE2-Wechsel oder automatischer Download. Siehe docs/tools/yue.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git python3 flock; do command -v "$program" >/dev/null || {
    echo "YuE: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
    mount="$YU_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$YU_ROOT/scripts/lib/resource_check.sh"
    require_ram_mb 1024 || return 1
    [[ "$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo)" -ge 512 ]] || {
      echo 'YuE-Quellen: mindestens 512 MiB aktuell verfuegbaren RAM schaffen.' >&2
      return 1
    }
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"
  elif [[ ! -d "$YU_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$YU_BASE" "$YU_LOGS"
  exec 9>"$YU_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere YuE-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$YU_LOGS/yue_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "YuE-Installer: 2026-10-18-github-sparse-source; Aktion: $mode; Pin: $YU_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "YuE-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    yu_deactivate
    return 0
  fi
  df -Pk "$YU_BASE"
  yu_fetch || return 1
  df -Pk "$YU_BASE"
)
