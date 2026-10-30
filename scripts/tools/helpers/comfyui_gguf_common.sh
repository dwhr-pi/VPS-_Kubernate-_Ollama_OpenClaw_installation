#!/usr/bin/env bash
set -euo pipefail
CG_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
CG_URL=https://github.com/city96/ComfyUI-GGUF.git
CG_COMMIT=6ea2651e7df66d7585f6ffee804b20e92fb38b8a

cg_candidate_paths() {
  printf '%s\n' /opt/comfyui /opt/ComfyUI "$1/tools/comfyui/source" "$1/tools/comfyui" "$HOME/ComfyUI"
}

cg_validate_paths() {
  local path index=0
  local -a resolved=()
  mapfile -t resolved < <(realpath -m -- "$@")
  [[ "${#resolved[@]}" == "$#" ]] || return 1
  for path in "$@"; do
    [[ "$path" == /* && ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'ComfyUI-GGUF: Symlink/nicht normalisierter Pfad; Abbruch.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

cg_resolve_comfy() {
  local root="$1" candidate
  local -a found=() registered=() pythons=()
  if [[ -f "$CG_MARKER" ]]; then
    mapfile -t registered <"$CG_MARKER"
    [[ "${#registered[@]}" == 3 && "${registered[0]}" == "$CG_COMMIT" &&
      "${registered[1]}" == */custom_nodes/ComfyUI-GGUF ]] || {
      echo 'GGUF-Registrierung ist abweichend; manuell pruefen, nichts ueberschrieben.' >&2
      return 1
    }
  fi
  if [[ -n "${COMFYUI_ROOT:-}" ]]; then
    CG_COMFY="$COMFYUI_ROOT"
  elif [[ "${#registered[@]}" == 3 ]]; then
    CG_COMFY="${registered[1]%/custom_nodes/ComfyUI-GGUF}"
  else
    while IFS= read -r candidate; do
      if [[ -f "$candidate/main.py" && -d "$candidate/comfy" ]]; then found+=("$candidate"); fi
    done < <(cg_candidate_paths "$root")
    if ((${#found[@]} > 1)); then
      printf 'Mehrere ComfyUI-Installationen gefunden; COMFYUI_ROOT bewusst setzen:\n' >&2
      printf '  %s\n' "${found[@]}" >&2
      return 1
    fi
    CG_COMFY="${found[0]:-/opt/comfyui}"
  fi
  if [[ -n "${COMFYUI_GGUF_PYTHON_BIN:-}" ]]; then
    CG_PYTHON="$COMFYUI_GGUF_PYTHON_BIN"
  elif [[ "${#registered[@]}" == 3 ]]; then
    CG_PYTHON="${registered[2]}"
  else
    for candidate in "$CG_COMFY/venv/bin/python" "$CG_COMFY/.venv/bin/python"; do
      if [[ -x "$candidate" ]]; then pythons+=("$candidate"); fi
    done
    if ((${#pythons[@]} > 1)); then
      echo 'Mehrere ComfyUI-venvs vorhanden; COMFYUI_GGUF_PYTHON_BIN bewusst setzen.' >&2
      printf '  %s\n' "${pythons[@]}" >&2
      return 1
    fi
    CG_PYTHON="${pythons[0]:-$CG_COMFY/venv/bin/python}"
  fi
}

cg_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$CG_ROOT/"*)
    echo 'GGUF-Workspace nicht im Setup-Repo ablegen.' >&2
    return 1
    ;;
  esac
  CG_BASE="$root/tools/comfyui_gguf"
  CG_SOURCE="$CG_BASE/source"
  CG_MARKER="$CG_BASE/installed"
  CG_SOURCE_MARKER="$CG_BASE/source-ready"
  # Validate parents before reading a registration to resolve its target.
  cg_validate_paths "$root" "$CG_BASE" "$CG_MARKER" || return 1
  cg_resolve_comfy "$root" || return 1
  CG_TARGET="$CG_COMFY/custom_nodes/ComfyUI-GGUF"
  CG_LOGS="$root/install_logs"
  cg_validate_paths "$root" "$CG_BASE" "$CG_SOURCE" "$CG_SOURCE/.git" "$CG_MARKER" "$CG_SOURCE_MARKER" "$CG_LOGS" "$CG_BASE/operation.lock" "$CG_COMFY" "$CG_COMFY/custom_nodes" || return 1
  case "$CG_COMFY/" in "$CG_ROOT/"*)
    echo 'ComfyUI muss ausserhalb des Setup-Repos liegen.' >&2
    return 1
    ;;
  esac
  case "$CG_COMFY/" in "$CG_BASE/"*)
    echo 'ComfyUI darf nicht innerhalb des GGUF-Tool-Workspaces liegen.' >&2
    return 1
    ;;
  esac
  case "$CG_BASE/" in "$CG_COMFY/custom_nodes/"*)
    echo 'Privater GGUF-Workspace darf nicht in custom_nodes liegen.' >&2
    return 1
    ;;
  esac
  if [[ -f "$CG_MARKER" && "$(<"$CG_MARKER")" != "$(printf '%s\n' "$CG_COMMIT" "$CG_TARGET" "$CG_PYTHON")" ]]; then
    echo 'GGUF-Registrierung gehoert zu anderem Ziel/Python oder ist abweichend. Zuerst mit bisherigen Pfaden pruefen/deaktivieren.' >&2
    return 1
  fi
  # This one deliberate symlink is the managed plugin activation.
  if [[ -e "$CG_TARGET" || -L "$CG_TARGET" ]]; then
    [[ -L "$CG_TARGET" && "$(readlink -- "$CG_TARGET")" == "$CG_SOURCE" ]] || {
      echo 'ComfyUI-GGUF: fremder Node-Ordner/Link vorhanden; manuell sichern, kein Ueberschreiben.' >&2
      return 1
    }
  fi
}

cg_source_ok() {
  [[ -d "$CG_SOURCE/.git" ]] &&
    [[ "$(git -C "$CG_SOURCE" rev-parse --show-toplevel)" == "$CG_SOURCE" ]] &&
    [[ "$(git -C "$CG_SOURCE" remote get-url origin)" == "$CG_URL" ]] &&
    [[ "$(git -C "$CG_SOURCE" rev-parse HEAD)" == "$CG_COMMIT" ]] &&
    [[ -z "$(git -C "$CG_SOURCE" status --porcelain --untracked-files=all)" ]]
}

cg_syntax() {
  python3 -I -B - "$CG_SOURCE" <<'PY'
import ast
from pathlib import Path
import sys
root = Path(sys.argv[1])
for name in ('__init__.py', 'nodes.py', 'loader.py', 'ops.py', 'dequant.py'):
    ast.parse((root / name).read_text(encoding='utf-8'), filename=name)
print('Node-Syntax geprueft; keine ComfyUI-/GPU-/Modellimports.')
PY
}

cg_comfy_preflight() {
  local missing=()
  echo "GGUF-Zielpruefung: ComfyUI=$CG_COMFY; Python=$CG_PYTHON"
  [[ -f "$CG_COMFY/main.py" ]] || missing+=("$CG_COMFY/main.py")
  [[ -d "$CG_COMFY/comfy" ]] || missing+=("$CG_COMFY/comfy/")
  [[ -d "$CG_COMFY/custom_nodes" ]] || missing+=("$CG_COMFY/custom_nodes/")
  if ((${#missing[@]})); then
    echo 'ComfyUI fehlt/unvollstaendig am ausgewaehlten Pfad. Fehlend:' >&2
    printf '  %s\n' "${missing[@]}" >&2
    echo 'ComfyUI_GGUF ist nur eine Erweiterung, kein eigenstaendiges ComfyUI.' >&2
    echo 'Falls ComfyUI bereits existiert: COMFYUI_ROOT=/absoluter/pfad/ComfyUI setzen (Ordner mit main.py, nicht dessen Elternordner).' >&2
    echo 'Falls nicht installiert: zuerst ComfyUI im Tools-Menue bewusst installieren; dann ComfyUI_GGUF erneut waehlen.' >&2
    echo 'Im Tools-Menue wird eine separate Basisinstallation oder Source-only-Auswahl angeboten; Standard ist Abbrechen.' >&2
    echo 'Nur Quellcode ohne Integration: COMFYUI_GGUF_MODE=source bash scripts/tools/comfyui_gguf_install.sh' >&2
    echo 'Keine automatische ComfyUI-/PyTorch-/Treiberinstallation oder Datenloeschung.' >&2
    return 1
  fi
  [[ -w "$CG_COMFY/custom_nodes" ]] || {
    echo "custom_nodes nicht beschreibbar: $CG_COMFY/custom_nodes. Benutzer/Rechte manuell pruefen; keine automatische sudo/chown-Aenderung." >&2
    return 1
  }
  [[ -x "$CG_PYTHON" ]] || {
    echo "ComfyUI-Python fehlt/ist nicht ausfuehrbar: $CG_PYTHON. COMFYUI_GGUF_PYTHON_BIN auf die vorhandene ComfyUI-venv setzen." >&2
    return 1
  }
  "$CG_PYTHON" -I -B -c \
    'import sys; from importlib.metadata import version; assert sys.version_info >= (3,10); assert sys.prefix != sys.base_prefix; version("torch"); version("packaging")' || {
    echo 'Vorhandene ComfyUI-venv mit Python 3.10+, torch und packaging erforderlich; kein System-Python verwenden.' >&2
    return 1
  }
  "$CG_PYTHON" -I -B -m pip --isolated check
}

cg_dependency_ok() {
  "$CG_PYTHON" -I -B -c \
    'from importlib.metadata import version; from packaging.version import Version; assert Version(version("gguf")) >= Version("0.13.0")'
}

cg_install_dependency() {
  local constraints
  if cg_dependency_ok >/dev/null 2>&1; then
    echo 'Kompatibles gguf vorhanden; keine Paketinstallation oder Aktualisierung.'
    return 0
  fi
  constraints="$(mktemp "$CG_BASE/packages-before.XXXXXX.txt")"
  # Preserve every existing distribution, including old gguf. Conflicts abort.
  "$CG_PYTHON" -I -B - >"$constraints" <<'PY'
from importlib.metadata import distributions
import re
packages = {}
for dist in distributions():
    name, version = dist.metadata['Name'], dist.version
    assert re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]*', name)
    assert re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9.+_!-]*', version)
    key = re.sub(r'[-_.]+', '-', name).lower()
    assert key not in packages or packages[key] == version
    packages[key] = version
for name, version in sorted(packages.items()):
    print(f'{name}=={version}')
PY
  echo 'Installiere nur fehlendes gguf 0.19.0 aus PyPI; vorhandene Paketversionen bleiben fixiert.'
  "$CG_PYTHON" -I -B -m pip --isolated install --index-url https://pypi.org/simple \
    --only-binary=:all: --no-cache-dir --disable-pip-version-check \
    -c "$constraints" gguf==0.19.0 || {
    echo 'Paketkonflikt/fehlendes Wheel: keine bestehenden Pakete automatisch aktualisiert. Snapshot im Tool-Workspace pruefen.' >&2
    return 1
  }
  "$CG_PYTHON" -I -B -m pip --isolated check
  cg_dependency_ok
}

cg_fetch_source() {
  if [[ -e "$CG_SOURCE" ]]; then
    cg_source_ok || {
      echo 'GGUF-Quelle fremd/unvollstaendig/veraendert; kein Reset oder Loeschen.' >&2
      return 1
    }
  else
    mkdir "$CG_SOURCE"
    git -C "$CG_SOURCE" init
    git -C "$CG_SOURCE" remote add origin "$CG_URL"
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$CG_SOURCE" fetch --depth 1 origin "$CG_COMMIT"
    git -c core.hooksPath=/dev/null -C "$CG_SOURCE" checkout --detach FETCH_HEAD
  fi
  cg_source_ok && cg_syntax || return 1
  printf '%s\n' "$CG_COMMIT" >"$CG_SOURCE_MARKER"
}

cg_installed() {
  [[ -f "$CG_MARKER" && "$(<"$CG_MARKER")" == "$(printf '%s\n' "$CG_COMMIT" "$CG_TARGET" "$CG_PYTHON")" &&
  -L "$CG_TARGET" && "$(readlink -- "$CG_TARGET")" == "$CG_SOURCE" ]] &&
    cg_source_ok && cg_dependency_ok
}

cg_activate() {
  rm -f -- "$CG_MARKER"
  cg_install_dependency || return 1
  if [[ -e "$CG_TARGET" || -L "$CG_TARGET" ]]; then
    [[ -L "$CG_TARGET" && "$(readlink -- "$CG_TARGET")" == "$CG_SOURCE" ]] || return 1
  else ln -s -- "$CG_SOURCE" "$CG_TARGET" || return 1; fi
  printf '%s\n' "$CG_COMMIT" "$CG_TARGET" "$CG_PYTHON" >"$CG_MARKER"
  echo 'ComfyUI-GGUF integriert. ComfyUI selbst nach Beendigung laufender Jobs neu starten; hier kein automatischer Start/Neustart.'
}

cg_deactivate() {
  # Recheck ownership of the one link immediately before unlinking it.
  if [[ -e "$CG_TARGET" || -L "$CG_TARGET" ]]; then
    [[ -L "$CG_TARGET" && "$(readlink -- "$CG_TARGET")" == "$CG_SOURCE" ]] || return 1
    rm -- "$CG_TARGET" || return 1
  fi
  rm -f -- "$CG_MARKER" "$CG_SOURCE_MARKER"
  echo 'Verwalteten Node-Link deaktiviert; Quellcode, Python-Pakete, Modelle, Workflows und Logs bleiben erhalten.'
}

comfyui_gguf_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" install_mode="${COMFYUI_GGUF_MODE:-integrate}" program mount log
  cg_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "ComfyUI-GGUF: GitHub $CG_URL; Pin $CG_COMMIT; ohne Docker."
      echo "Modus: $install_mode; ComfyUI: $CG_COMFY; Python: $CG_PYTHON"
      echo "Node-Link: $CG_TARGET -> $CG_SOURCE"
      echo 'Kein Download im Dry-Run. Keine Modelle, Treiber, ComfyUI-/Serverstarts.'
      return 0
      ;;
    --check-base)
      if [[ ! -f "$CG_COMFY/main.py" || ! -d "$CG_COMFY/comfy" || ! -d "$CG_COMFY/custom_nodes" ]]; then
        cg_comfy_preflight || :
        # The separate base installer only owns the /opt/comfyui target.
        [[ "$CG_COMFY" == /opt/comfyui ]] && return 3
        return 1
      fi
      cg_comfy_preflight
      return $?
      ;;
    status | --status)
      if cg_installed >/dev/null 2>&1; then echo '{"integrated":true,"inference_tested":false}'; else echo '{"integrated":false,"inference_tested":false}'; fi
      return 0
      ;;
    doctor | check | --check)
      cg_installed && cg_syntax && "$CG_PYTHON" -I -B -m pip --isolated check || {
        echo 'GGUF-Integration fehlt/ist inkonsistent. Source-only ist keine aktive ComfyUI-Erweiterung.' >&2
        return 1
      }
      echo 'Quelle, Link und Paketmetadaten konsistent; kein Node-Import oder GPU-Funktionstest.'
      return 0
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'ComfyUI-GGUF: nur Installation/Pruefung/Deaktivierung; kein Serverstart.' >&2
      return 2
      ;;
  esac
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Linux als normaler Benutzer erforderlich; ohne sudo.' >&2
    return 1
  }
  for program in git python3 flock; do
    command -v "$program" >/dev/null || {
      echo "Basiswerkzeug $program fehlt; separat einrichten." >&2
      return 1
    }
  done
  [[ "$install_mode" == source || "$install_mode" == integrate ]] || {
    echo 'COMFYUI_GGUF_MODE muss source oder integrate sein.' >&2
    return 2
  }
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    if [[ "$install_mode" == integrate ]]; then cg_comfy_preflight || return 1; fi
    mount="$CG_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    # shellcheck source=../../lib/resource_check.sh
    source "$CG_ROOT/scripts/lib/resource_check.sh"
    REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$mount"
    if [[ "$install_mode" == integrate ]]; then
      REQUIRE_WINDOWS_HOST_FREE_MB=2048 require_disk_mb 1024 "$CG_COMFY"
    fi
  elif [[ ! -d "$CG_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$CG_BASE" "$CG_LOGS"
  exec 9>"$CG_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere GGUF-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$CG_LOGS/comfyui_gguf_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "ComfyUI-GGUF-Installer: 2026-10-19-guided-base-check; Aktion: $mode; Modus: $install_mode"
  trap 'rc=$?; if ((rc != 0)); then echo "GGUF-Fehler ($rc). Quelle/Daten erhalten. Log: $log; nach Behebung --repair verwenden."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    cg_deactivate
    return 0
  fi
  cg_fetch_source
  if [[ "$install_mode" == source ]]; then
    echo 'Nur GitHub-Quellen bereitgestellt; keine neue Einbindung/Paketinstallation. Bestehende Einbindungen bleiben erhalten.'
    return 0
  fi
  cg_activate
)
