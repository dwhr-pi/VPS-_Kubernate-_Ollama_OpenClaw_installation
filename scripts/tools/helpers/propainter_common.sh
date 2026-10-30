#!/usr/bin/env bash
set -euo pipefail
PP_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
PP_URL=https://github.com/sczhou/ProPainter.git
PP_COMMIT=e870e79321c31b733e2031af5aa2fb1fe3ac7eec
PP_LICENSE_FILE="$PP_ROOT/licenses/propainter/S-Lab-1.0.txt"

pp_read_license_choice() {
  [[ -t 0 ]] || return 1
  read -r -p 'Lizenz akzeptieren und fortfahren? [(j)a/(N)ein = ablehnen]: ' PP_LICENSE_ANSWER
}

pp_confirm_license() {
  local PP_LICENSE_ANSWER=""
  [[ -f "$PP_LICENSE_FILE" && ! -L "$PP_LICENSE_FILE" && -s "$PP_LICENSE_FILE" ]] || {
    echo 'ProPainter-Lizenztext fehlt oder ist unsicher; Installation abgebrochen.' >&2
    return 2
  }
  printf '\n--- ProPainter: vollstaendiger Lizenztext ---\n'
  printf 'Quelle: https://github.com/sczhou/ProPainter/blob/%s/LICENSE\n\n' "$PP_COMMIT"
  cat -- "$PP_LICENSE_FILE" || return 2
  printf '\n--- Ende Lizenztext ---\n'
  case "${PROPAINTER_ACCEPT_LICENSE:-ask}" in
    1)
      echo 'Lizenzannahme explizit durch PROPAINTER_ACCEPT_LICENSE=1 bestaetigt.'
      return 0
      ;;
    0)
      echo 'Lizenz abgelehnt (PROPAINTER_ACCEPT_LICENSE=0); nichts heruntergeladen.' >&2
      return 2
      ;;
    ask) ;;
    *)
      echo 'PROPAINTER_ACCEPT_LICENSE: nur 0 oder 1 setzen, andernfalls fuer Rueckfrage weglassen.' >&2
      return 2
      ;;
  esac
  if pp_read_license_choice; then
    case "$PP_LICENSE_ANSWER" in
      j | J | ja | Ja | JA | akzeptieren)
        echo 'Lizenz fuer diesen Aufruf akzeptiert.'
        return 0
        ;;
    esac
  fi
  echo 'Lizenz nicht akzeptiert; Installation abgebrochen, kein Download. Nichtinteraktiv nur nach eigener Pruefung PROPAINTER_ACCEPT_LICENSE=1 setzen.' >&2
  return 2
}

pp_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path index=0
  local -a paths=() resolved=()
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$PP_ROOT/"*)
    echo 'ProPainter-Workspace nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  PP_BASE="$root/tools/propainter"
  PP_SOURCE="$PP_BASE/source"
  PP_MARKER="$PP_BASE/source-ready"
  PP_LOGS="$root/install_logs"
  paths=("$root" "$PP_BASE" "$PP_SOURCE" "$PP_SOURCE/.git" "$PP_MARKER" "$PP_LOGS" "$PP_BASE/operation.lock")
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'ProPainter: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

pp_source_ok() {
  [[ -d "$PP_SOURCE/.git" && ! -e "$PP_SOURCE/.env" && ! -L "$PP_SOURCE/.env" ]] &&
    [[ "$(git -C "$PP_SOURCE" rev-parse --show-toplevel)" == "$PP_SOURCE" ]] &&
    [[ "$(git -C "$PP_SOURCE" remote get-url origin)" == "$PP_URL" ]] &&
    [[ "$(git -C "$PP_SOURCE" rev-parse HEAD)" == "$PP_COMMIT" ]] &&
    [[ "$(git -C "$PP_SOURCE" config --bool core.sparseCheckout)" == true ]] &&
    [[ "$(git -C "$PP_SOURCE" sparse-checkout list)" == "$(pp_sparse_patterns)" ]] &&
    [[ -z "$(git -C "$PP_SOURCE" status --porcelain --untracked-files=all)" ]]
}

pp_inspect() {
  pp_source_ok || return 1
  python3 -I -B - "$PP_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('inference_propainter.py', 'model/propainter.py', 'model/recurrent_flow_completion.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'requirements.txt').is_file()
assert (root / 'LICENSE').is_file()
assert not (root / '.env').exists()
print('ProPainter-Pin und Syntax geprueft; keine Imports oder Laufzeitinstallation.')
PY
}

pp_sparse_patterns() {
  # Allow source trees only; root .env, media, notebooks and weights are not checked out.
  cat <<'PATTERNS'
/README.md
/LICENSE
/requirements.txt
/inference_propainter.py
/model/
/core/
/RAFT/
/utils/
/configs/
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

pp_sparse_checkout() {
  pp_sparse_patterns | git -C "$PP_SOURCE" sparse-checkout set --no-cone --stdin
}

pp_fetch() {
  if [[ -e "$PP_SOURCE" ]]; then
    pp_source_ok || {
      echo 'ProPainter-Quelle fremd/unvollstaendig/veraendert oder voller Checkout; manuell sichern. Kein Reset/Loeschen.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$PP_SOURCE"
    git -C "$PP_SOURCE" remote add origin "$PP_URL"
    pp_sparse_checkout
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$PP_SOURCE" fetch --filter=blob:none --depth 1 origin "$PP_COMMIT"
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$PP_SOURCE" checkout --detach FETCH_HEAD
  fi
  pp_inspect || return 1
  printf '%s\n' "$PP_COMMIT" >"$PP_MARKER"
  echo 'ProPainter-GitHub-Quellinstallation vorbereitet (nicht betriebsbereit). Keine Python-Pakete, Modelle oder Dienste installiert/gestartet.'
}

pp_deactivate() {
  rm -f -- "$PP_MARKER"
  echo 'ProPainter-Quellregistrierung deaktiviert; Quelle, eigene Daten/Modelle und Logs bleiben erhalten.'
}

propainter_main() (
  set -euo pipefail
  umask 077
  unset GEMINI_API_KEY GOOGLE_API_KEY HF_TOKEN HUGGING_FACE_HUB_TOKEN
  export HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 HF_HUB_DISABLE_TELEMETRY=1
  local mode="${1:-install}" program mount log
  pp_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo 'Lizenz: S-Lab 1.0, nichtkommerziell; kommerzielle Nutzung gesondert klaeren.'
      echo "ProPainter GitHub: $PP_URL; Pin $PP_COMMIT; ohne Docker."
      echo 'Nur Quellinstallation via Sparse-Checkout, keine .env/Medien/Gewichte im Arbeitsbaum. KEINE betriebsbereite Video-Laufzeit.'
      echo 'Reserve 1 GiB Disk, 2 GiB Windows-C:; Dry-Run ohne Download oder Import.'
      return 0
      ;;
    status | --status)
      if [[ -f "$PP_MARKER" && "$(<"$PP_MARKER")" == "$PP_COMMIT" ]] && pp_source_ok >/dev/null 2>&1; then
        echo '{"source_ready":true,"runtime_ready":false,"scope":"github-source-only"}'
      else echo '{"source_ready":false,"runtime_ready":false,"scope":"github-source-only"}'; fi
      return 0
      ;;
    doctor | check | --check)
      [[ -f "$PP_MARKER" && "$(<"$PP_MARKER")" == "$PP_COMMIT" ]] && pp_inspect || return 1
      echo 'Quellen geprueft, Video-Laufzeit NICHT eingerichtet; kein GUI-/Modelltest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'ProPainter: nur Quellverwaltung, kein App-/Video-/Serverstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall && "${PROPAINTER_INSTALL_RUNTIME:-0}" != 0 ]]; then
    echo 'ProPainter-Laufzeit nicht freigegeben: Ungepinnte Torch-/Video-Abhaengigkeiten und automatische Gewichtsdownloads bei Inferenz separat pruefen. Siehe docs/tools/propainter.md.' >&2
    return 2
  fi
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    pp_confirm_license || return $?
  fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git python3 flock; do command -v "$program" >/dev/null || {
    echo "ProPainter: $program fehlt; Basis separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
    mount="$PP_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$PP_ROOT/scripts/lib/resource_check.sh"
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"
  elif [[ ! -d "$PP_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$PP_BASE" "$PP_LOGS"
  exec 9>"$PP_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere ProPainter-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$PP_LOGS/propainter_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "ProPainter-Installer: 2026-10-18-github-sparse-source; Aktion: $mode; Pin: $PP_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "ProPainter-Fehler ($rc); Dateien erhalten. Log: $log. Nach Pruefung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    pp_deactivate
    return 0
  fi
  df -Pk "$PP_BASE"
  pp_fetch
  df -Pk "$PP_BASE"
)
