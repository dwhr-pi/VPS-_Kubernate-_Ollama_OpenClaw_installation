#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
kustomize_arch() {
  [[ "$(uname -s)" == Linux ]] || {
    log_error 'Kustomize-Installer unterstuetzt Linux/WSL.'
    return 1
  }
  case "$(uname -m)" in
    x86_64 | amd64) echo amd64 ;;
    aarch64 | arm64) echo arm64 ;;
    *)
      log_error 'Kustomize: nicht unterstuetzte Architektur.'
      return 1
      ;;
  esac
}

kustomize_verify_archive() {
  local archive="$1" checksums="$2" asset="$3" hash
  hash="$(awk -v name="$asset" '$2 == name {print $1}' "$checksums")"
  [[ "$hash" =~ ^[a-fA-F0-9]{64}$ ]] || return 1
  printf '%s  %s\n' "$hash" "$archive" | sha256sum --check --status
}

kustomize_main() {
  local mode="${1:-install}" version="${KUSTOMIZE_VERSION:-v5.8.2}" arch asset base tmp_dir
  case "$mode" in
    --check | --status)
      kustomize version
      return $?
      ;;
    --help | -h)
      echo 'Kustomize: --check, --status, --dry-run; KUSTOMIZE_VERSION=vX.Y.Z'
      return 0
      ;;
    install | --dry-run) ;;
    *)
      log_error "Unbekannte Option: $mode"
      return 2
      ;;
  esac
  [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    log_error 'KUSTOMIZE_VERSION muss vX.Y.Z entsprechen.'
    return 2
  }
  arch="$(kustomize_arch)" || return 1
  asset="kustomize_${version}_linux_${arch}.tar.gz"
  base="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${version}"
  if [[ "$mode" == --dry-run ]]; then
    echo "Kustomize: $base/$asset; checksums.txt; Ziel /usr/local/bin/kustomize. Kein Download oder Cluster-Zugriff."
    return 0
  fi
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_Kustomize 'Kustomize aus GitHub-Release'
  if ! require_disk_mb 256 / || ! ensure_base_apt_packages ca-certificates curl tar coreutils; then
    end_measurement failed
    return 1
  fi
  tmp_dir="$(mktemp -d)" || {
    end_measurement failed
    return 1
  }
  if ! curl -fsSL --connect-timeout 15 --max-time 300 "$base/$asset" -o "$tmp_dir/$asset" ||
    ! curl -fsSL --connect-timeout 15 --max-time 60 "$base/checksums.txt" -o "$tmp_dir/checksums.txt" ||
    ! kustomize_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums.txt" "$asset" ||
    ! tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" kustomize ||
    ! chmod 0755 "$tmp_dir/kustomize" ||
    ! "$tmp_dir/kustomize" version >/dev/null ||
    ! sudo install -m 0755 "$tmp_dir/kustomize" /usr/local/bin/kustomize; then
    log_error 'Kustomize: Download/Pruefsumme/Client-Test/Installation fehlgeschlagen. Kein Erfolg gespeichert.'
    rm -rf -- "$tmp_dir"
    end_measurement failed
    return 1
  fi
  rm -rf -- "$tmp_dir"
  mark_tool_installed Kustomize
  end_measurement success
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then kustomize_main "$@"; fi
