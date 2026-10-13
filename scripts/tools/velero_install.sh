#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
# shellcheck source=../lib/resource_check.sh
source "$ROOT_DIR/scripts/lib/resource_check.sh"

velero_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    *) log_error 'Velero: nicht unterstuetzte Architektur.'; return 1 ;;
  esac
}

velero_verify_archive() {
  local archive="$1" checksums="$2" asset="$3" hash
  hash="$(awk -v name="$asset" '{f=$2; sub(/^\*/, "", f); if(f==name) print $1}' "$checksums")"
  [[ "$hash" =~ ^[a-fA-F0-9]{64}$ ]] || return 1
  printf '%s  %s\n' "$hash" "$archive" | sha256sum --check --status
}

velero_main() {
  local mode="${1:-install}" version="${VELERO_VERSION:-v1.18.4}" arch member asset base tmp_dir
  case "$mode" in
    --check|--status) velero version --client-only; return $? ;;
    --help|-h) echo 'Velero: --check, --status, --dry-run; VELERO_VERSION=vX.Y.Z fuer eine feste Version.'; return 0 ;;
    install|--dry-run) ;;
    *) log_error "Unbekannte Option: $mode"; return 2 ;;
  esac
  [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { log_error 'VELERO_VERSION muss vX.Y.Z entsprechen.'; return 2; }
  arch="$(velero_arch)" || return 1
  member="velero-${version}-linux-${arch}"
  asset="${member}.tar.gz"
  base="https://github.com/velero-io/velero/releases/download/$version"
  if [ "$mode" = --dry-run ]; then
    echo "Velero: ${base}/${asset}; SHA256 aus CHECKSUM; CLI nach /usr/local/bin/velero."
    return 0
  fi
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_Velero 'Velero CLI aus GitHub-Release'
  if ! require_disk_mb 256 / || ! ensure_base_apt_packages ca-certificates curl tar coreutils; then
    end_measurement failed; return 1
  fi
  tmp_dir="$(mktemp -d)" || { end_measurement failed; return 1; }
  log_info "Velero-Download: $base/$asset"
  if ! curl -fsSL --connect-timeout 15 --max-time 300 "$base/$asset" -o "$tmp_dir/$asset" ||
     ! curl -fsSL --connect-timeout 15 --max-time 60 "$base/CHECKSUM" -o "$tmp_dir/CHECKSUM" ||
     ! velero_verify_archive "$tmp_dir/$asset" "$tmp_dir/CHECKSUM" "$asset" ||
     ! tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" "$member/velero" ||
     ! chmod 0755 "$tmp_dir/$member/velero" ||
     ! "$tmp_dir/$member/velero" version --client-only >/dev/null ||
     ! sudo install -m 0755 "$tmp_dir/$member/velero" /usr/local/bin/velero; then
    log_error 'Velero: Download, CHECKSUM, Entpacken, CLI-Test oder Installation fehlgeschlagen.'
    rm -rf -- "$tmp_dir"; end_measurement failed; return 1
  fi
  rm -rf -- "$tmp_dir"
  mark_tool_installed Velero
  end_measurement success
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  velero_main "$@"
fi
