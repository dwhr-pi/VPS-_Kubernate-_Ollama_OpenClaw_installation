#!/usr/bin/env bash
set -euo pipefail
VO_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
VO_URL=https://github.com/Netflix/void-model.git
VO_COMMIT=e3914f8f551dd4b880661991fd6b28cd1699a97a

vo_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
  local -a paths=() resolved=()
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$VO_ROOT/"*)
    echo 'VOID-Workspace nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  VO_BASE="$root/tools/void_model"
  VO_SOURCE="$VO_BASE/source"
  VO_MARKER="$VO_BASE/source-ready"
  VO_LOGS="$root/install_logs"
  paths=("$root" "$VO_BASE" "$VO_SOURCE" "$VO_SOURCE/.git" "$VO_MARKER" "$VO_LOGS" "$VO_BASE/operation.lock")
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'VOID: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

vo_source_ok() {
  [[ -d "$VO_SOURCE/.git" && ! -e "$VO_SOURCE/.env" && ! -L "$VO_SOURCE/.env" ]] &&
    [[ "$(git -C "$VO_SOURCE" rev-parse --show-toplevel)" == "$VO_SOURCE" ]] &&
    [[ "$(git -C "$VO_SOURCE" remote get-url origin)" == "$VO_URL" ]] &&
    [[ "$(git -C "$VO_SOURCE" rev-parse HEAD)" == "$VO_COMMIT" ]] &&
    [[ "$(git -C "$VO_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
    [[ "$(git -C "$VO_SOURCE" sparse-checkout list)" == "$(vo_sparse_patterns)" ]] &&
    [[ -z "$(git -C "$VO_SOURCE" status --porcelain --untracked-files=all)" ]]
}

vo_inspect() {
  vo_source_ok || return 1
  python3 -I -B - "$VO_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('inference/cogvideox_fun/predict_v2v.py', 'inference/cogvideox_fun/inference_with_pass1_warped_noise.py', 'VLM-MASK-REASONER/stage2_vlm_analysis.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'requirements.txt').is_file()
assert (root / 'LICENSE').is_file()
assert not (root / '.env').exists()
print('VOID-Pin und Syntax geprueft; keine Imports oder Laufzeitinstallation.')
PY
}

vo_sparse_patterns() {
  # Allow source trees only; root .env, media, notebooks and weights are not checked out.
  cat <<'PATTERNS'
/README.md
/LICENSE
/requirements.txt
/inference/
/videox_fun/
/config/
/VLM-MASK-REASONER/
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

vo_sparse_checkout() {
  vo_sparse_patterns | git -C "$VO_SOURCE" sparse-checkout set --no-cone --stdin
}

vo_fetch() {
  if [[ -e "$VO_SOURCE" ]]; then
    vo_source_ok || {
      echo 'VOID-Quelle fremd/unvollstaendig/veraendert oder voller Checkout; manuell sichern. Kein Reset/Loeschen.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$VO_SOURCE"
    git -C "$VO_SOURCE" remote add origin "$VO_URL"
    vo_sparse_checkout
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$VO_SOURCE" fetch --filter=blob:none --depth 1 origin "$VO_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$VO_SOURCE" checkout --detach FETCH_HEAD
  fi
  vo_inspect || return 1
  printf '%s\n' "$VO_COMMIT" >"$VO_MARKER"
  echo 'VOID-GitHub-Quellinstallation vorbereitet (nicht betriebsbereit). Keine Python-Pakete, Modelle oder Dienste installiert/gestartet.'
}

vo_deactivate() {
  rm -f -- "$VO_MARKER"
  echo 'VOID-Quellregistrierung deaktiviert; Quelle, eigene Daten/Modelle und Logs bleiben erhalten.'
}

void_model_main() (
  set -euo pipefail
  umask 077
  unset GEMINI_API_KEY GOOGLE_API_KEY HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program mount log
  vo_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "VOID GitHub: $VO_URL; Pin $VO_COMMIT; ohne Docker."
      echo 'Nur Quellinstallation via Sparse-Checkout, keine .env/Medien/Gewichte im Arbeitsbaum. KEINE betriebsbereite Video-Laufzeit.'
      echo 'Reserve 1 GiB Disk, 2 GiB Windows-C:; Dry-Run ohne Download oder Import.'
      return 0
      ;;
    status | --status)
      if [[ -f "$VO_MARKER" && "$(<"$VO_MARKER")" == "$VO_COMMIT" ]] && vo_source_ok >/dev/null 2>&1; then
        echo '{"source_ready":true,"runtime_ready":false,"scope":"github-source-only"}'
      else echo '{"source_ready":false,"runtime_ready":false,"scope":"github-source-only"}'; fi
      return 0
      ;;
    doctor | check | --check)
      [[ -f "$VO_MARKER" && "$(<"$VO_MARKER")" == "$VO_COMMIT" ]] && vo_inspect || return 1
      echo 'Quellen geprueft, Video-Laufzeit NICHT eingerichtet; kein GUI-/Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'VOID: nur Quellverwaltung, kein App-/Video-/Serverstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${VOID_MODEL_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'VOID-Laufzeit nicht freigegeben: GPU-Laufzeit/Modelle separat pruefen; Maskenpipeline kann Gemini verwenden. Kein automatischer API-Aufruf. Siehe docs/tools/void-model.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git python3 flock; do command -v "$program" >/dev/null || {
    echo "VOID: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
    mount="$VO_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$VO_ROOT/scripts/lib/resource_check.sh"
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"
  elif [[ ! -d "$VO_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$VO_BASE" "$VO_LOGS"
  exec 9>"$VO_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere VOID-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$VO_LOGS/void_model_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "VOID-Installer: 2026-10-18-github-sparse-source; Aktion: $mode; Pin: $VO_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "VOID-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    vo_deactivate
    return 0
  fi
  df -Pk "$VO_BASE"
  vo_fetch
  df -Pk "$VO_BASE"
)
