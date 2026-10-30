#!/usr/bin/env bash
set -euo pipefail
SF_ROOT="$(cd "${BASH_SOURCE[0]%/*}/../../.." && pwd)"
SF_URL=https://github.com/sfztools/sfizz.git
SF_COMMIT=4e70dc0bef53b41f2853ed46e26f5911114c92d0
SF_VERSION=1.2.3

sf_modules() {
  # Gitlinks resolved from the pinned 1.2.3 source; no submodule --remote.
  cat <<'PINS'
external/abseil-cpp https://github.com/abseil/abseil-cpp.git c2435f8342c2d0ed8101cb43adfd605fdc52dca2
external/filesystem https://github.com/gulrak/filesystem.git 8a2edd6d92ed820521d42c94d179462bf06b5ed3
external/simde https://github.com/simd-everywhere/simde.git 2bf459d4ed6d7ed6b9f31bd9e07c91bace5009e0
external/st_audiofile/thirdparty/dr_libs https://github.com/mackron/dr_libs.git 4b3d07849537ce0b71b22180c0b1335eacc6e9be
external/st_audiofile/thirdparty/libaiff https://github.com/sfztools/libaiff.git 78864a4a2e769e426be8cfd78ae7f5f72e236c33
external/st_audiofile/thirdparty/wavpack https://github.com/dbry/WavPack.git 07ffb331d23c16e2d2979370441f63ea722760bc
PINS
}

sf_paths() {
  local root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}" path
  [[ "$root" == /* && "$root" != / ]] || return 1
  case "$root/" in "$SF_ROOT/"*)
    echo 'Sfizz: User-Daten nicht im Setup-Repo.' >&2
    return 1
    ;;
  esac
  SF_BASE="$root/tools/sfizz"
  SF_SOURCE="$SF_BASE/source"
  SF_BUILD="$SF_BASE/build"
  SF_BINARY="$SF_BUILD/library/bin/sfizz_render"
  SF_MARKER="$SF_BASE/source-ready"
  SF_NATIVE="$SF_BASE/native.json"
  SF_LOGS="$root/install_logs"
  local -a paths=("$root" "$SF_BASE" "$SF_SOURCE" "$SF_SOURCE/.git" "$SF_BUILD" "$SF_BUILD/library" "$SF_BUILD/library/bin" "$SF_BINARY" "$SF_MARKER" "$SF_NATIVE" "$SF_LOGS" "$SF_BASE/operation.lock") resolved=()
  local index=0
  mapfile -t resolved < <(realpath -m -- "${paths[@]}")
  [[ "${#resolved[@]}" == "${#paths[@]}" ]] || return 1
  for path in "${paths[@]}"; do
    [[ ! -L "$path" && "${resolved[$index]}" == "$path" ]] || {
      echo 'Sfizz: Symlink/nicht normalisierter Pfad.' >&2
      return 1
    }
    index=$((index + 1))
  done
}

sf_repo_ok() {
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

sf_checkout() {
  local path="$1" url="$2" commit="$3"
  [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || return 1
  if [[ -e "$path" && ! -d "$path/.git" ]]; then
    [[ -d "$path" && -z "$(find "$path" -mindepth 1 -maxdepth 1 -print -quit)" ]] || {
      echo 'Sfizz: Fremder/unvollstaendiger Quellordner; nichts geloescht.' >&2
      return 1
    }
  fi
  if [[ -d "$path/.git" ]]; then
    sf_repo_ok "$path" "$url" "$commit" || {
      echo 'Sfizz: Quelle geaendert/fremd; manuell sichern, kein Reset.' >&2
      return 1
    }
  else
    git -c init.defaultBranch=main init "$path" || return 1
    git -C "$path" remote add origin "$url" || return 1
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$path" fetch --depth 1 origin "$commit" || return 1
    GIT_LFS_SKIP_SMUDGE=1 GIT_TERMINAL_PROMPT=0 git -c credential.helper= -c core.hooksPath=/dev/null -C "$path" checkout --detach FETCH_HEAD || return 1
  fi
  sf_repo_ok "$path" "$url" "$commit"
}

sf_source_ok() {
  local rel url commit path
  sf_repo_ok "$SF_SOURCE" "$SF_URL" "$SF_COMMIT" || return 1
  while read -r rel url commit; do
    path="$SF_SOURCE/$rel"
    [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || return 1
    sf_repo_ok "$path" "$url" "$commit" || return 1
  done < <(sf_modules)
  [[ -f "$SF_SOURCE/CMakeLists.txt" && -f "$SF_SOURCE/clients/sfizz_render.cpp" && -f "$SF_SOURCE/LICENSE" ]]
}

sf_fetch() {
  local rel url commit
  sf_checkout "$SF_SOURCE" "$SF_URL" "$SF_COMMIT" || return 1
  while read -r rel url commit; do
    sf_checkout "$SF_SOURCE/$rel" "$url" "$commit" || return 1
  done < <(sf_modules)
  sf_source_ok || return 1
  printf '%s\n' "$SF_COMMIT" >"$SF_MARKER"
}

sf_native_record() {
  python3 -I -B - "$SF_BINARY" "$SF_NATIVE" "$SF_COMMIT" "${1:-check}" <<'PY'
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

sf_build_preflight() {
  local tool
  for tool in cmake make cc c++; do
    command -v "$tool" >/dev/null || {
      echo "Sfizz Build: $tool fehlt; Build-Werkzeuge separat einrichten." >&2
      return 1
    }
  done
  local cmake_version
  cmake_version="$(cmake --version | head -n 1)" || return 1
  [[ "$cmake_version" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]] || return 1
  [[ "${BASH_REMATCH[1]}" == 3 && "${BASH_REMATCH[2]}" -ge 19 ]] || {
    echo 'Sfizz: CMake >=3.19 und <4 verwenden (archivierte Abhaengigkeiten).' >&2
    return 1
  }
  SF_JOBS="${SFIZZ_BUILD_JOBS:-1}"
  [[ "$SF_JOBS" =~ ^[12]$ ]] || {
    echo 'SFIZZ_BUILD_JOBS muss 1 oder 2 sein.' >&2
    return 1
  }
  if [[ -e "$SF_BUILD" && (! -f "$SF_BUILD/.sfizz-build" || -L "$SF_BUILD/.sfizz-build") ]]; then
    echo 'Sfizz: Fremder Build-Ordner; nichts ueberschrieben.' >&2
    return 1
  fi
  if [[ -f "$SF_BUILD/.sfizz-build" && "$(<"$SF_BUILD/.sfizz-build")" != "$SF_COMMIT" ]]; then
    echo 'Sfizz: Build-Ordner gehoert zu anderem Pin; nichts ueberschrieben.' >&2
    return 1
  fi
}

sf_build_native() {
  rm -f -- "$SF_NATIVE"
  mkdir -p "$SF_BUILD"
  [[ ! -L "$SF_BUILD/.sfizz-build" && ! -L "$SF_BUILD/CMakeCache.txt" ]] || return 1
  printf '%s\n' "$SF_COMMIT" >"$SF_BUILD/.sfizz-build"
  cmake -S "$SF_SOURCE" -B "$SF_BUILD" -DCMAKE_BUILD_TYPE=Release \
    -DSFIZZ_JACK=OFF -DSFIZZ_RENDER=ON -DSFIZZ_SHARED=OFF \
    -DSFIZZ_TESTS=OFF -DSFIZZ_BENCHMARKS=OFF -DSFIZZ_DEMOS=OFF \
    -DSFIZZ_DEVTOOLS=OFF -DSFIZZ_USE_SNDFILE=OFF -DENABLE_LTO=OFF \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON -DBUILD_TESTING=OFF || return 1
  cmake --build "$SF_BUILD" --target sfizz_render --parallel "$SF_JOBS" || return 1
  sf_source_ok || return 1
  sf_native_record write || return 1
  echo "sfizz_render gebaut: $SF_BINARY; nicht gestartet, kein Audiotest."
}

sfizz_main() (
  set -euo pipefail
  umask 077
  local mode="${1:-install}" tool mount log native=false reserve=1024
  sf_paths || return 1
  case "$mode" in
    --dry-run | --plan | plan | --help)
      echo 'Achtung: sfztools/sfizz ist archiviert; Engine/Renderer, keine DAW-Plugins.'
      echo "Sfizz 1.2.3: GitHub $SF_URL; Pin $SF_COMMIT; ohne Docker."
      echo 'Standard: Quelle plus 6 gepinnte GitHub-Unterprojekte. SFIZZ_BUILD=1: optional Offline-Renderer, max. 1 Job (einstellbar 1-2).'
      echo 'Quelle: 1 GiB freie Disk, WSL C: 2 GiB; Build: 4 GiB RAM/Disk/WSL C:. Kein Audio-/Dienststart.'
      return 0
      ;;
    status | --status | doctor | check | --check)
      if [[ -f "$SF_MARKER" && "$(<"$SF_MARKER")" == "$SF_COMMIT" ]] && sf_source_ok >/dev/null 2>&1; then
        if sf_native_record check >/dev/null 2>&1; then native=true; fi
        echo "{\"source_ready\":true,\"native_built\":$native,\"audio_tested\":false}"
        return 0
      fi
      echo '{"source_ready":false,"native_built":false,"audio_tested":false}'
      [[ "$mode" == status || "$mode" == --status ]]
      return $?
      ;;
    install | update | --repair | uninstall | --uninstall) ;;
    *)
      echo 'Sfizz: nur Quellen/Build verwalten, kein Start/Training.' >&2
      return 2
      ;;
  esac
  [[ "${SFIZZ_BUILD:-0}" =~ ^[01]$ ]] || {
    echo 'SFIZZ_BUILD muss 0 oder 1 sein.' >&2
    return 2
  }
  [[ "$(uname -s)" == Linux && "$EUID" != 0 ]] || {
    echo 'Normalen Linux-Benutzer ohne sudo verwenden.' >&2
    return 1
  }
  for tool in git python3 flock; do command -v "$tool" >/dev/null || {
    echo "Sfizz: $tool fehlt; separat einrichten." >&2
    return 1
  }; done
  if [[ "$mode" != uninstall && "$mode" != --uninstall ]]; then
    case "$(uname -m)" in x86_64 | aarch64) ;; *)
      echo 'Sfizz: automatischer Linux-Pfad nur x86_64/ARM64.' >&2
      return 1
      ;;
    esac
    python3 -I -B -c 'import sys; assert sys.version_info >= (3,10)'
    mount="$SF_BASE"
    while [[ ! -d "$mount" ]]; do
      mount="${mount%/*}"
      [[ -n "$mount" ]] || mount=/
    done
    source "$SF_ROOT/scripts/lib/resource_check.sh"
    if [[ "${SFIZZ_BUILD:-0}" == 1 ]]; then
      sf_build_preflight || return 1
      require_ram_mb 4096 || return 1
      [[ "$(awk '/^MemAvailable:/ {print int($2/1024)}' /proc/meminfo)" -ge 2048 ]] || {
        echo 'Sfizz Build: mindestens 2 GiB aktuell freien RAM schaffen.' >&2
        return 1
      }
      reserve=4096
    fi
    REQUIRE_WINDOWS_HOST_FREE_MB=$((reserve == 1024 ? 2048 : reserve)) require_disk_mb "$reserve" "$mount"
  elif [[ ! -d "$SF_BASE" ]]; then
    echo 'Nicht eingerichtet; nichts deaktiviert.'
    return 0
  fi
  mkdir -p "$SF_BASE" "$SF_LOGS"
  exec 9>"$SF_BASE/operation.lock"
  flock -n 9 || {
    echo 'Andere Sfizz-Operation aktiv.' >&2
    return 1
  }
  log="$(mktemp "$SF_LOGS/sfizz_$(date +%Y%m%d_%H%M%S)_XXXXXX.log")"
  exec > >(tee -a "$log") 2>&1
  echo "Sfizz Installer: 2026-10-18-github-native; Aktion: $mode; Pin: $SF_COMMIT"
  echo 'Achtung: sfztools/sfizz ist archiviert. Engine/Renderer, keine DAW-Plugins.'
  trap 'rc=$?; if ((rc)); then echo "Sfizz Fehler ($rc); Quellen/Daten erhalten. Log: $log; nach Pruefung --repair."; fi' EXIT
  if [[ "$mode" == uninstall || "$mode" == --uninstall ]]; then
    rm -f -- "$SF_MARKER" "$SF_NATIVE"
    echo 'Quell-/Buildregistrierung deaktiviert; Quellen, Binaerdateien, Instrumente/Samples und Logs bleiben erhalten.'
    return 0
  fi
  df -Pk "$SF_BASE"
  sf_fetch
  if [[ "${SFIZZ_BUILD:-0}" == 1 ]]; then sf_build_native; fi
  df -Pk "$SF_BASE"
  echo 'Sfizz GitHub-Installation vorbereitet. Build-Status separat pruefen; kein Audio-/Plugin-/Mikrofonstart.'
)
