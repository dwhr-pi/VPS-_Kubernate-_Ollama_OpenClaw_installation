#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

syft_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    *) log_error 'Syft: nicht unterstuetzte Architektur.'; return 1 ;;
  esac
}

syft_verify_archive() {
  local archive="$1" checksums="$2" asset="$3" hash
  hash="$(awk -v name="$asset" '$2 == name {print $1}' "$checksums")"
  [[ "$hash" =~ ^[a-fA-F0-9]{64}$ ]] || return 1
  printf '%s  %s\n' "$hash" "$archive" | sha256sum --check --status
}

syft_main() {
  local mode="${1:-install}" version="${SYFT_VERSION:-v1.54.1}" arch asset checksum_asset base tmp_dir
  case "$mode" in
    --check|--status) syft version; return $? ;;
    --help|-h) echo 'Syft: --check, --status, --dry-run; SYFT_VERSION=vX.Y.Z fuer ein festes GitHub-Release.'; return 0 ;;
    install|--dry-run) ;;
    *) log_error "Unbekannte Option: $mode"; return 2 ;;
  esac
  [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { log_error 'SYFT_VERSION muss vX.Y.Z entsprechen.'; return 2; }
  arch="$(syft_arch)" || return 1
  asset="syft_${version#v}_linux_${arch}.tar.gz"
  checksum_asset="syft_${version#v}_checksums.txt"
  base="https://github.com/anchore/syft/releases/download/$version"
  if [ "$mode" = --dry-run ]; then
    echo "Syft: ${base}/${asset}; SHA256 aus ${checksum_asset}; Ziel /usr/local/bin/syft."
    return 0
  fi
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_Syft 'Syft aus Anchore-GitHub-Release'
  if ! require_disk_mb 256 / || ! ensure_base_apt_packages ca-certificates curl tar coreutils; then
    end_measurement failed; return 1
  fi
  tmp_dir="$(mktemp -d)" || { end_measurement failed; return 1; }
  log_info "Installiere Syft aus GitHub: $base/$asset"
  if ! curl -fsSL --connect-timeout 15 --max-time 300 "$base/$asset" -o "$tmp_dir/$asset" ||
     ! curl -fsSL --connect-timeout 15 --max-time 60 "$base/$checksum_asset" -o "$tmp_dir/checksums" ||
     ! syft_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums" "$asset" ||
     ! tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" syft ||
     ! chmod 0755 "$tmp_dir/syft" ||
     ! "$tmp_dir/syft" version >/dev/null ||
     ! sudo install -m 0755 "$tmp_dir/syft" /usr/local/bin/syft; then
    log_error 'Syft: Download, SHA256, Entpacken, Versionstest oder Installation fehlgeschlagen.'
    rm -rf -- "$tmp_dir"; end_measurement failed; return 1
  fi
  rm -rf -- "$tmp_dir"
  mark_tool_installed Syft
  end_measurement success
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  syft_main "$@"
fi
