#!/usr/bin/env bash
# Called inside the tool lock, after consent and build-resource preflight.
private_cpython310_ok() {
  "$1" -I -B -c 'import sys, ssl, sqlite3, bz2, lzma, ctypes, venv, ensurepip; assert sys.version_info[:2] == (3,10)'
}

private_cpython310_base_deps() {
  local package
  local -a missing=()
  for package in build-essential pkg-config ca-certificates libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev libffi-dev liblzma-dev uuid-dev; do
    dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -qx 'install ok installed' || missing+=("$package")
  done
  ((${#missing[@]})) || return 0
  { command -v apt-get >/dev/null && command -v sudo >/dev/null; } || {
    echo 'Fehlende CPython-Buildbibliotheken manuell einrichten; apt/sudo nicht vorhanden.' >&2
    return 1
  }
  sudo -v || return 1
  source "${BASH_SOURCE[0]%/*}/apt_lock_wait.sh"
  run_apt_with_lock_wait update || return $?
  run_apt_with_lock_wait install -y "${missing[@]}"
}

build_private_cpython310() (
  set -euo pipefail
  local base="$1" prefix source_dir path jobs="${CPYTHON_BUILD_JOBS:-1}"
  local version=3.10.22 commit=acb4dc12b6df8615af7b43120ef601e04072f7d2
  prefix="$base/runtime/python-$version"
  [[ "$jobs" =~ ^[1-2]$ ]] || {
    echo 'CPYTHON_BUILD_JOBS: fuer diesen Build 1 oder 2 erlaubt.' >&2
    return 2
  }
  [[ "$base" == /* && "$base" != / ]] || return 1
  for path in "$base" "$base/runtime" "$prefix"; do
    [[ ! -L "$path" && "$(realpath -m -- "$path")" == "$path" ]] || return 1
  done
  if [[ -e "$prefix" ]]; then
    echo 'CPython-Ziel bereits vorhanden, aber nicht ausgewaehlt/nutzbar. Erst manuell pruefen; kein Ueberschreiben.' >&2
    return 1
  fi
  private_cpython310_base_deps >&2 || return $?
  mkdir -p "$base/runtime" || return 1
  source_dir="$(mktemp -d "$base/runtime/cpython-build.XXXXXXXX")" || return 1
  echo "CPython $version aus GitHub, Commit $commit; $jobs Buildjob(s)." >&2
  echo "Privates Ziel: $prefix; Diagnosequellen: $source_dir. Kein System-Python/PATH-Austausch." >&2
  git -c init.defaultBranch=main init "$source_dir/source" >&2 || return $?
  git -C "$source_dir/source" remote add origin https://github.com/python/cpython.git >&2 || return $?
  GIT_TERMINAL_PROMPT=0 git -c credential.helper= -C "$source_dir/source" fetch --depth 1 origin "$commit" >&2 || return $?
  git -c core.hooksPath=/dev/null -C "$source_dir/source" checkout --detach FETCH_HEAD >&2 || return $?
  [[ "$(git -C "$source_dir/source" rev-parse HEAD)" == "$commit" ]] || return 1
  (
    set -e
    cd "$source_dir/source" || exit 1
    ./configure --prefix="$prefix" --with-ensurepip=install || exit $?
    make -j "$jobs" || exit $?
    make altinstall || exit $?
  ) >&2 || return $?
  private_cpython310_ok "$prefix/bin/python3.10" >&2 || return 1
  "$prefix/bin/python3.10" -I -B -c 'import sys; assert sys.version_info[:3] == (3,10,22)' >&2 || return 1
  printf '%s\n' "$prefix/bin/python3.10"
)
