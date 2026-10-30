#!/usr/bin/env bash
set -euo pipefail
VD_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
VD_URL=https://github.com/medahmedkrichen/ViDubb.git
VD_COMMIT=6a90ea25fd14d7cb241f1c5759fc9f4b8b93f49d

vd_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
  local -a paths=() resolved=()
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$VD_ROOT/"*)
    echo 'ViDubb-Workspace nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  VD_BASE="$root/tools/vidubb"
  VD_SOURCE="$VD_BASE/source"
  VD_MARKER="$VD_BASE/source-ready"
  VD_LOGS="$root/install_logs"
  paths=("$root" "$VD_BASE" "$VD_SOURCE" "$VD_SOURCE/.git" "$VD_MARKER" "$VD_LOGS" "$VD_BASE/operation.lock")
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'ViDubb: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

vd_source_ok() {
  [[ -d "$VD_SOURCE/.git" && ! -e "$VD_SOURCE/.env" && ! -L "$VD_SOURCE/.env" ]] &&
    [[ "$(git -C "$VD_SOURCE" rev-parse --show-toplevel)" == "$VD_SOURCE" ]] &&
    [[ "$(git -C "$VD_SOURCE" remote get-url origin)" == "$VD_URL" ]] &&
    [[ "$(git -C "$VD_SOURCE" rev-parse HEAD)" == "$VD_COMMIT" ]] &&
    [[ "$(git -C "$VD_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
    [[ "$(git -C "$VD_SOURCE" sparse-checkout list)" == "$(vd_sparse_patterns)" ]] &&
    [[ -z "$(git -C "$VD_SOURCE" status --porcelain --untracked-files=all)" ]]
}

vd_inspect() {
  vd_source_ok || return 1
  python3 -I -B - "$VD_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('app.py', 'inference.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'requirements.txt').is_file()
assert (root / 'LICENSE').is_file()
assert not (root / '.env').exists()
print('ViDubb-Pin und Syntax geprueft; keine Imports oder Laufzeitinstallation.')
PY
}

vd_sparse_patterns() {
  # Allow source trees only; root .env, media, notebooks and weights are not checked out.
  cat <<'PATTERNS'
/README.md
/LICENSE
/requirements.txt
/app.py
/inference.py
/tools/
/Wav2Lip/
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

vd_sparse_checkout() {
  vd_sparse_patterns | git -C "$VD_SOURCE" sparse-checkout set --no-cone --stdin
}

vd_fetch() {
  if [[ -e "$VD_SOURCE" ]]; then
    vd_source_ok || {
      echo 'ViDubb-Quelle fremd/unvollstaendig/veraendert oder voller Checkout; manuell sichern. Kein Reset/Loeschen.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$VD_SOURCE"
    git -C "$VD_SOURCE" remote add origin "$VD_URL"
    vd_sparse_checkout
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$VD_SOURCE" fetch --filter=blob:none --depth 1 origin "$VD_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$VD_SOURCE" checkout --detach FETCH_HEAD
  fi
  vd_inspect || return 1
  printf '%s\n' "$VD_COMMIT" >"$VD_MARKER"
  echo 'ViDubb-GitHub-Quellinstallation vorbereitet (nicht betriebsbereit). Keine Python-Pakete, Modelle oder Dienste installiert/gestartet.'
}

vd_deactivate() {
  rm -f -- "$VD_MARKER"
  echo 'ViDubb-Quellregistrierung deaktiviert; Quelle, eigene Daten/Modelle und Logs bleiben erhalten.'
}

vidubb_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" program mount log
  vd_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "ViDubb GitHub: $VD_URL; Pin $VD_COMMIT; ohne Docker."
      echo 'Nur Quellinstallation via Sparse-Checkout, keine .env/Medien/Gewichte im Arbeitsbaum. KEINE betriebsbereite Dubbing-Laufzeit.'
      echo 'Reserve 1 GiB Disk, 2 GiB Windows-C:; Dry-Run ohne Download oder Import.'
      return 0
      ;;
    status | --status)
      if [[ -f "$VD_MARKER" && "$(<"$VD_MARKER")" == "$VD_COMMIT" ]] && vd_source_ok >/dev/null 2>&1; then
        echo '{"source_ready":true,"runtime_ready":false,"scope":"github-source-only"}'
      else echo '{"source_ready":false,"runtime_ready":false,"scope":"github-source-only"}'; fi
      return 0
      ;;
    doctor | check | --check)
      [[ -f "$VD_MARKER" && "$(<"$VD_MARKER")" == "$VD_COMMIT" ]] && vd_inspect || return 1
      echo 'Quellen geprueft, Dubbing-Laufzeit NICHT eingerichtet; kein GUI-/Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'ViDubb: nur Quellverwaltung, kein App-/Dubbing-/Serverstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${VIDUBB_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'ViDubb-Laufzeit nicht freigegeben: Legacy-Abhaengigkeiten, pip beim Import und loeschende Arbeitsablaeufe. Siehe docs/tools/vidubb.md.' >&2
    return 2
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git python3 flock; do command -v "$program" >/dev/null || {
    echo "ViDubb: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
    mount="$VD_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$VD_ROOT/scripts/lib/resource_check.sh"
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"
  elif [[ ! -d "$VD_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$VD_BASE" "$VD_LOGS"
  exec 9>"$VD_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere ViDubb-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$VD_LOGS/vidubb_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "ViDubb-Installer: 2026-10-16-github-sparse-source; Aktion: $mode; Pin: $VD_COMMIT"
  local rc
  trap 'rc=$?; if ((rc != 0)); then echo "ViDubb-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    vd_deactivate
    return 0
  fi
  df -Pk "$VD_BASE"
  vd_fetch
  df -Pk "$VD_BASE"
)
