#!/usr/bin/env bash
set -euo pipefail
FILM_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
FILM_URL=https://github.com/google-research/frame-interpolation.git
FILM_COMMIT=69f8708f08e62c2edf46a27616a4bfcf083e2076

film_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$FILM_ROOT/"*)
    echo 'FILM-Workspace muss ausserhalb des Setup-Repos liegen.' >&2
    return 1
    ;;
  esac
  FILM_BASE="$root/tools/film"
  FILM_SOURCE="$FILM_BASE/source"
  FILM_MARKER="$FILM_BASE/source-ready"
  FILM_LOGS="$root/install_logs"
  for path in "$root" "$FILM_BASE" "$FILM_SOURCE" "$FILM_SOURCE/.git" "$FILM_MARKER" "$FILM_LOGS" "$FILM_BASE/operation.lock"; do
    [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || {
      echo 'FILM: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
  done
}

film_source_ok() {
  [[ -d "$FILM_SOURCE/.git" ]] &&
    [[ "$(git -C "$FILM_SOURCE" rev-parse --show-toplevel)" == "$FILM_SOURCE" ]] &&
    [[ "$(git -C "$FILM_SOURCE" remote get-url origin)" == "$FILM_URL" ]] &&
    [[ "$(git -C "$FILM_SOURCE" rev-parse HEAD)" == "$FILM_COMMIT" ]] &&
    [[ -z "$(git -C "$FILM_SOURCE" status --porcelain --untracked-files=all)" ]]
}

film_inspect() {
  film_source_ok || return 1
  python3 -I -B - "$FILM_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('eval/interpolator.py', 'eval/interpolator_test.py', 'eval/interpolator_cli.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
assert (root / 'LICENSE').is_file()
assert (root / 'requirements.txt').is_file()
print('FILM-Quellstand und Syntax geprueft. Kein TensorFlow-/Modellimport oder Bildzugriff.')
PY
}

film_runtime_guard() {
  [[ "${FILM_INSTALL_RUNTIME:-0}" == 0 ]] || {
    echo 'FILM: automatische Legacy-Laufzeit nicht freigegeben. Upstream ist archiviert und pinnt TensorFlow 2.6.2.' >&2
    echo 'Das alte Python-/CUDA-Rezept ist kein getesteter Ubuntu-24.04-/RTX-5080-Pfad.' >&2
    echo 'Nur GitHub-Quellinstallation unterstuetzt; FILM_INSTALL_RUNTIME entfernen. Siehe docs/tools/film.md.' >&2
    return 2
  }
}

film_fetch_source() {
  if [[ -e "$FILM_SOURCE" ]]; then
    film_source_ok || {
      echo 'FILM: fremde, unvollstaendige oder veraenderte Quelle. Manuell sichern; kein Reset/Ueberschreiben.' >&2
      return 1
    }
  else
    mkdir "$FILM_SOURCE"
    git -C "$FILM_SOURCE" init
    git -C "$FILM_SOURCE" remote add origin "$FILM_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$FILM_SOURCE" fetch --depth 1 origin "$FILM_COMMIT"
    git -c core.hooksPath=/dev/null -C "$FILM_SOURCE" checkout --detach FETCH_HEAD
  fi
  film_inspect || return 1
  printf '%s\n' "$FILM_COMMIT" >"$FILM_MARKER"
  echo 'FILM aus GitHub installiert (Quellcode), ohne Docker. KEINE lauffertige TensorFlow-/GPU-Umgebung.'
  echo 'Keine Python-Pakete, SavedModels, Bildverarbeitung, Cloud oder Dienste ausgefuehrt.'
}

film_deactivate() {
  rm -f -- "$FILM_MARKER"
  echo 'FILM-Quellregistrierung deaktiviert. Quellen, Umgebungen, Modelle, Bilder, Videos und Logs bleiben erhalten.'
}

film_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" program mount log
  film_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "FILM GitHub: $FILM_URL; Commit: $FILM_COMMIT; kein Docker."
      echo 'Archivierter Upstream; nur Quellen. Keine TensorFlow-/CUDA-/Modellinstallation.'
      echo 'Kein Download oder Interpolationslauf im Dry-Run.'
      return 0
      ;;
    status | --status)
      if [[ -f "$FILM_MARKER" && "$(<"$FILM_MARKER")" == "$FILM_COMMIT" ]] && film_source_ok >/dev/null 2>&1; then
        echo '{"source_ready":true,"runtime_ready":false,"models_checked":false,"scope":"github-source-only"}'
      else
        echo '{"source_ready":false,"runtime_ready":false,"models_checked":false,"scope":"github-source-only"}'
      fi
      return 0
      ;;
    doctor | check | --check)
      [[ -f "$FILM_MARKER" && "$(<"$FILM_MARKER")" == "$FILM_COMMIT" ]] && film_inspect || {
        echo 'FILM-Quellinstallation fehlt oder ist inkonsistent.' >&2
        return 1
      }
      echo 'Doctor prueft nur Quelle/Syntax. Keine lauffertige TensorFlow-/Modellumgebung.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'FILM: nur GitHub-Quellverwaltung; kein Interpolations-/Serverstart.' >&2
      return 2
      ;;
  esac
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then film_runtime_guard || return $?; fi
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'FILM als normaler Linux-Benutzer ohne sudo aufrufen.' >&2
    return 1
  }
  for program in git python3 flock; do
    command -v "$program" >/dev/null || {
      echo "FILM: Basiswerkzeug $program fehlt; separat einrichten." >&2
      return 1
    }
  done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)' || {
      echo 'Python 3.10+ fuer die reine Syntaxpruefung erforderlich.' >&2
      return 1
    }
    mount="$FILM_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$FILM_ROOT/scripts/lib/resource_check.sh"
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"
  elif [[ ! -d "$FILM_BASE" ]]; then
    echo 'FILM nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$FILM_BASE" "$FILM_LOGS"
  exec 9>"$FILM_BASE/operation.lock"
  flock -n 9 || {
    echo 'FILM: andere Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$FILM_LOGS/film_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "FILM-Installer: 2026-10-16-github-source-only; Aktion: $mode; Commit: $FILM_COMMIT"
  trap 'rc=$?; if ((rc != 0)); then echo "FILM-Fehler ($rc). Dateien erhalten. Log: $log; nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    film_deactivate
    return 0
  fi
  film_fetch_source
)
