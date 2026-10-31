#!/usr/bin/env bash
# Dependency bootstrap only; never generates keys or bypasses release verification.
set -Eeuo pipefail

ensure_minisign() {
  local consent="${1:-0}" answer='' os_id
  if command -v minisign >/dev/null 2>&1; then
    minisign -v
    return
  fi
  [[ $(uname -s) == Linux && -r /etc/os-release ]] || {
    printf 'Minisign fehlt; auf dieser Plattform separat installieren.\n' >&2
    return 1
  }
  os_id=$(sed -n 's/^ID=//p' /etc/os-release)
  os_id=${os_id//\"/}
  if [[ "$os_id" != ubuntu && "$os_id" != debian ]] || ! command -v apt-get >/dev/null 2>&1; then
    printf 'Minisign fehlt; automatische Einrichtung nur fuer Ubuntu/Debian mit apt-get.\n' >&2
    return 1
  fi
  printf '%s\n' 'Minisign fehlt. Installation aus den eingerichteten APT-Paketquellen erfordert Administratorrechte.' >&2
  if [[ "$consent" != 1 ]]; then
    if [[ -t 0 ]]; then
      printf 'Minisign jetzt installieren? [j/N] ' >&2
      read -r answer || return 1
      case "$answer" in j | ja | y | yes | J | JA | Y | YES) ;; *)
        printf 'Keine Installation freigegeben; abgebrochen.\n' >&2
        return 1
        ;;
      esac
    else
      printf 'Keine interaktive Zustimmung; bei bewusster Freigabe --install-minisign verwenden.\n' >&2
      return 1
    fi
  fi
  if ((EUID == 0)); then
    apt-get -o DPkg::Lock::Timeout=300 update || return 1
    apt-get -o DPkg::Lock::Timeout=300 install --no-remove --no-install-recommends -y minisign || return 1
  else
    command -v sudo >/dev/null 2>&1 || return 1
    sudo apt-get -o DPkg::Lock::Timeout=300 update || return 1
    sudo apt-get -o DPkg::Lock::Timeout=300 install --no-remove --no-install-recommends -y minisign || return 1
  fi
  command -v minisign >/dev/null 2>&1 && minisign -v
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  case "${1:-}" in
    '') ensure_minisign 0 ;;
    --install-minisign) [[ $# == 1 ]] && ensure_minisign 1 ;;
    *) printf 'Aufruf: bash ensure_minisign.sh [--install-minisign]\n' >&2; exit 2 ;;
  esac
fi
