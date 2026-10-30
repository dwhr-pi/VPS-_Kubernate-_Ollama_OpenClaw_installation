#!/usr/bin/env bash
set -euo pipefail
AE_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
AE_URL=https://github.com/TypesettingTools/Aegisub.git
AE_COMMIT=088ca6caa878209e279871f8897273f49342372b
AE_VERSION=3.5.1

ae_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$AE_ROOT/"*)
    echo 'Aegisub: User-Daten nicht im Setup-Repo.' >&2
    return 1
    ;;
  esac
  AE_BASE="$root/tools/aegisub"
  AE_SOURCE="$AE_BASE/source"
  AE_BUILD="$AE_BASE/build"
  AE_PREFIX="$AE_BASE/native"
  AE_BINARY="$AE_PREFIX/bin/aegisub"
  AE_MARKER="$AE_BASE/source-ready"
  AE_NATIVE="$AE_BASE/native.json"
  AE_LOGS="$root/install_logs"
  local -a paths=("$root" "$AE_BASE" "$AE_SOURCE" "$AE_SOURCE/.git" "$AE_BUILD" "$AE_BUILD/.aegisub-owned" "$AE_PREFIX" "$AE_PREFIX/bin" "$AE_PREFIX/share" "$AE_PREFIX/share/aegisub" "$AE_PREFIX/.aegisub-owned" "$AE_BINARY" "$AE_MARKER" "$AE_NATIVE" "$AE_LOGS" "$AE_BASE/operation.lock") resolved=()
  local index=0
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Aegisub: Symlink/nicht normalisierter Pfad.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

ae_repo_ok() {
  local path="$1" url="$2" commit="$3" top state
  top="$(git -C "$path" rev-parse --show-toplevel)" || return 1
  [[ -n "$top" ]] || return 1
  state="$(git -C "$path" status --porcelain --untracked-files=all --ignore-submodules=none)" || return 1
  [[ -d "$path/.git" && ! -L "$path/.git" ]] &&
    [[ "$top" -ef "$path" ]] &&
    [[ "$(git -C "$path" remote get-url origin)" == "$url" ]] &&
    [[ "$(git -C "$path" rev-parse HEAD)" == "$commit" ]] &&
    [[ -z "$state" ]]
}

ae_checkout() {
  local path="$1" url="$2" commit="$3"
  [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || return 1
  if [[ -e "$path" && ! -d "$path/.git" ]]; then
    [[ -d "$path" && -z "$(find "$path" -mindepth 1 -maxdepth 1 -print -quit)" ]] || {
      echo 'Aegisub: Fremder/unvollstaendiger Quellordner; nichts geloescht.' >&2
      return 1
    }
  fi
  if [[ -d "$path/.git" ]]; then
    ae_repo_ok "$path" "$url" "$commit" || {
      echo 'Aegisub: Quelle geaendert/fremd; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$path" || return 1
    git -C "$path" remote add origin "$url" || return 1
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$path" fetch --depth 1 origin "$commit" || return 1
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$path" checkout --detach FETCH_HEAD || return 1
  fi
  ae_repo_ok "$path" "$url" "$commit"
}

ae_source_ok() {
  ae_repo_ok "$AE_SOURCE" "$AE_URL" "$AE_COMMIT" || return 1
  [[ -f "$AE_SOURCE/meson.build" && -f "$AE_SOURCE/src/main.cpp" && -f "$AE_SOURCE/LICENCE" ]]

}

ae_fetch() {
  ae_checkout "$AE_SOURCE" "$AE_URL" "$AE_COMMIT" || return 1
  ae_source_ok || return 1
  printf '%s\n' "$AE_COMMIT" >"$AE_MARKER"
}

ae_native_record() {
  [[ -f "$AE_PREFIX/share/aegisub/automation/include/utils.lua" ]] || return 1
  python3 -I -B - "$AE_BINARY" "$AE_NATIVE" "$AE_COMMIT" "${1:-check}" <<'PY'
import hashlib
import json
import platform
from pathlib import Path
import sys
binary, marker = Path(sys.argv[1]), Path(sys.argv[2])
assert binary.is_file() and not binary.is_symlink()
with binary.open('rb') as stream:
    header = stream.read(32)
    assert len(header) == 32 and header[:6] == bytes([127, 69, 76, 70, 2, 1])
    machine = {'x86_64': 62, 'amd64': 62, 'aarch64': 183, 'arm64': 183}[platform.machine().lower()]
    assert int.from_bytes(header[18:20], 'little') == machine
    stream.seek(0)
    checksum = hashlib.file_digest(stream, 'sha256').hexdigest() if hasattr(hashlib, 'file_digest') else None
if checksum is None:
    checksum = hashlib.sha256(binary.read_bytes()).hexdigest()
record = {'commit': sys.argv[3], 'sha256': checksum}
if sys.argv[4] == 'write':
    marker.write_text(json.dumps(record) + '\n', encoding='utf-8')
else:
    assert json.loads(marker.read_text(encoding='utf-8')) == record
PY
}

ae_build_preflight() {
  local tool
  for tool in meson ninja cc c++ pkg-config wx-config msgfmt; do
    command -v "$tool" >/dev/null || {
      echo "Aegisub Build: $tool fehlt; separat einrichten." >&2
      return 1
    }
  done
  python3 -I -B - "$(meson --version)" "$(wx-config --version)" <<'PY' || return 1
import re
import sys
def version(value):
    match = re.match(r'^(\d+)\.(\d+)\.(\d+)', value)
    assert match, value
    return tuple(map(int, match.groups()))
assert version(sys.argv[1]) >= (0,60,0), 'Meson >=0.60 erforderlich'
assert version(sys.argv[2]) >= (3,2,2), 'wxWidgets >=3.2.2 erforderlich'
PY
  pkg-config --exists fontconfig libass zlib icu-uc icu-i18n luajit gl ffms2 alsa || {
    echo 'Aegisub: Entwicklungsbibliotheken fehlen. Siehe docs/tools/aegisub.md; keine automatische Paketinstallation.' >&2
    return 1
  }
  AE_JOBS="${AEGISUB_BUILD_JOBS:-1}"
  [[ "$AE_JOBS" =~ ^[12]$ ]] || {
    echo 'AEGISUB_BUILD_JOBS muss 1 oder 2 sein.' >&2
    return 1
  }
  local directory marker
  for directory in "$AE_BUILD" "$AE_PREFIX"; do
    marker="$directory/.aegisub-owned"
    if [[ -e "$directory" ]]; then
      [[ -d "$directory" && -f "$marker" && ! -L "$marker" &&
        "$(<"$marker")" == "$AE_COMMIT" ]] || {
        echo 'Aegisub: Fremder Build-/Installationsordner; nichts ueberschrieben.' >&2
        return 1
      }
      [[ -z "$(find "$directory" -type l -print -quit)" ]] || {
        echo 'Aegisub: Symlink im Build-/Installationsordner; Abbruch.' >&2
        return 1
      }
    fi
  done
}

ae_build_native() {
  rm -f -- "$AE_NATIVE"
  mkdir -p "$AE_BUILD" "$AE_PREFIX"
  [[ ! -L "$AE_BUILD/.aegisub-owned" && ! -L "$AE_PREFIX/.aegisub-owned" ]] || return 1
  printf '%s\n' "$AE_COMMIT" >"$AE_BUILD/.aegisub-owned"
  printf '%s\n' "$AE_COMMIT" >"$AE_PREFIX/.aegisub-owned"
  local -a configure=(setup "$AE_BUILD" "$AE_SOURCE")
  if [[ -f "$AE_BUILD/meson-private/coredata.dat" ]]; then configure+=(--reconfigure); fi
  meson "${configure[@]}" --prefix="$AE_PREFIX" --bindir=bin --datadir=share \
    --libdir=lib --libexecdir=libexec --sysconfdir=etc --localstatedir=var \
    --buildtype=release --wrap-mode=nofallback -Dtests=false -Dsystem_luajit=true \
    -Denable_update_checker=false -Dalsa=enabled -Dffms2=enabled \
    -Dlibpulse=disabled -Dportaudio=disabled -Dopenal=disabled \
    -Dhunspell=disabled -Duchardet=disabled -Dlibportal=disabled \
    -Dfftw3=disabled -Dcsri=disabled || return 1
  meson compile -C "$AE_BUILD" -j "$AE_JOBS" || return 1
  # Clear inherited DESTDIR; install only inside the explicitly configured prefix.
  (
    unset DESTDIR
    meson install -C "$AE_BUILD" --no-rebuild --skip-subprojects
  ) || return 1
  ae_source_ok || return 1
  ae_native_record write || return 1
  echo "Aegisub privat gebaut/installiert: $AE_BINARY; GUI nicht gestartet."
}

aegisub_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" tool mount log native=false reserve=1024
  ae_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo "Aegisub 3.5.1: GitHub $AE_URL; Pin $AE_COMMIT; ohne Docker."
      echo 'Standard: gepinnte GitHub-Quellen. AEGISUB_BUILD=1: optional nativer GUI-Build, 1 Job (einstellbar 1-2).'
      echo 'Quelle: 1 GiB freie Disk, WSL C: 2 GiB; Build: 4 GiB RAM und 8 GiB Disk/WSL C:. Kein Audio-/Dienststart.'
      return 0
      ;;
    status | --status | doctor | check | --check)
      if [[ -f "$AE_MARKER" && "$(<"$AE_MARKER")" == "$AE_COMMIT" ]] && ae_source_ok >/dev/null 2>&1; then
        if ae_native_record check >/dev/null 2>&1; then native=true; fi
        echo "{\"source_ready\":true,\"native_built\":$native,\"gui_tested\":false}"
        return 0
      fi
      echo '{"source_ready":false,"native_built":false,"gui_tested":false}'
      [[ "$mode" == status || "$mode" == --status ]]
      return $?
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Aegisub: nur Quellen/Build verwalten, kein Start/Training.' >&2
      return 2
      ;;
  esac
  [[ "${AEGISUB_BUILD:-0}" =~ ^[01]$ ]] || {
    echo 'AEGISUB_BUILD muss 0 oder 1 sein.' >&2
    return 2
  }
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Normalen Linux-Benutzer ohne sudo verwenden.' >&2
    return 1
  }
  for tool in git python3 flock; do command -v "$tool" >/dev/null || {
    echo "Aegisub: $tool fehlt; separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    case "$(uname -m)" in x86_64 | aarch64) ;; *)
      echo 'Aegisub: automatischer Linux-Pfad nur x86_64/ARM64.' >&2
      return 1
      ;;
    esac
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
    mount="$AE_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    source "$AE_ROOT/scripts/lib/resource_check.sh"
    if [[ "${AEGISUB_BUILD:-0}" == 1 ]]; then
      ae_build_preflight || return 1
      require_ram_mb 4096 || return 1
      [[ "$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo)" -ge 2048 ]] || {
        echo 'Aegisub Build: mindestens 2 GiB aktuell freien RAM schaffen.' >&2
        return 1
      }
      reserve=8192
    fi
    REQUIRE_WINDOWS_HOST_FREE_MB=$((reserve == 1024 ? 2048 : reserve)) require_disk_mb "$reserve" "$mount"
  elif [[ ! -d "$AE_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$AE_BASE" "$AE_LOGS"
  exec 9>"$AE_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Aegisub-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$AE_LOGS/aegisub_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Aegisub Installer: 2026-10-18-github-native; Aktion: $mode; Pin: $AE_COMMIT"
  local rc
  trap 'rc=$?; if ((rc)); then echo "Aegisub Fehler ($rc); Quellen/Daten erhalten. Log: $log; nach Pruefung --repair."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    rm -f -- "$AE_MARKER" "$AE_NATIVE"
    echo 'Quell-/Buildregistrierung deaktiviert; Quellen, Binaerdateien, Benutzerdaten und Logs bleiben erhalten.'
    return 0
  fi
  df -Pk "$AE_BASE"
  ae_fetch || return 1
  if [[ "${AEGISUB_BUILD:-0}" == 1 ]]; then ae_build_native || return 1; fi
  df -Pk "$AE_BASE"
  echo 'Aegisub GitHub-Installation vorbereitet. Build-Status separat pruefen; kein GUI-/Audio-/Mikrofonstart.'
)
