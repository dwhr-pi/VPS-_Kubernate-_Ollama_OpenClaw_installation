#!/usr/bin/env bash
# Called only after the tool's opt-in and resource preflight. Stdout is the interpreter path.
build_isolated_cpython311() (
  local version=3.11.17 jobs="${CPYTHON_BUILD_JOBS:-2}"
  local prefix="/opt/openclaw-python/python-${version}" binary root source_dir
  binary="$prefix/bin/python3.11"
  if ! [[ "$jobs" =~ ^[1-9][0-9]?$ ]] || ((jobs > 64)); then
    echo 'Fehler: CPYTHON_BUILD_JOBS muss 1 bis 64 sein.' >&2
    return 2
  fi
  if [[ -L "$prefix" ]] || [[ "$(realpath -m -- "$prefix")" != "$prefix" ]]; then
    echo 'Fehler: Unsicherer isolierter CPython-Pfad.' >&2
    return 1
  fi
  root="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
  mkdir -p "$root/locks" "$root/builds" >&2 || return 1
  command -v flock >/dev/null || {
    echo 'Fehler: flock fehlt (util-linux).' >&2
    return 1
  }
  exec 9>"$root/locks/cpython-${version}.lock" || return 1
  flock -n 9 || {
    echo 'Fehler: CPython-Build laeuft bereits.' >&2
    return 1
  }
  if [[ -x "$binary" ]] && "$binary" -c 'import ssl, sqlite3, bz2, lzma, ctypes, venv, ensurepip' >&2; then
    printf '%s\n' "$binary"
    return 0
  fi
  echo "Baue isoliertes CPython $version aus https://github.com/python/cpython.git (v$version), $jobs Build-Jobs." >&2
  echo "Ziel: $prefix; /usr/bin/python3 bleibt unveraendert. sudo wird vor dem Build geprueft." >&2
  sudo -v || return 1
  ensure_base_apt_packages git build-essential pkg-config ca-certificates libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev libffi-dev liblzma-dev uuid-dev >&2 || return 1
  sudo mkdir -p "$prefix" >&2 || return 1
  sudo chown "$(id -un):$(id -gn)" "$prefix" >&2 || return 1
  source_dir="$(mktemp -d "$root/builds/cpython-${version}.XXXXXXXX")" || return 1
  echo "Build-Dateien: $source_dir (bleiben fuer Diagnose erhalten)." >&2
  GIT_TERMINAL_PROMPT=0 git clone --depth 1 --branch "v$version" https://github.com/python/cpython.git "$source_dir/source" >&2 || return 1
  if ! (
    cd "$source_dir/source" &&
      ./configure --prefix="$prefix" --with-ensurepip=install &&
      make -j "$jobs" &&
      make altinstall
  ) >&2; then
    echo 'Fehler: CPython-Build fehlgeschlagen; Build-Log pruefen. Kein System-Python ersetzt.' >&2
    return 1
  fi
  if ! "$binary" -c 'import sys, ssl, sqlite3, bz2, lzma, ctypes, venv, ensurepip; assert sys.version_info[:3] == (3,11,17)' >&2; then
    echo 'Fehler: Isoliertes CPython ist nicht vollstaendig nutzbar.' >&2
    return 1
  fi
  printf '%s\n' "$binary"
)
