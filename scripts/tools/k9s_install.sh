#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

k9s_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    *) log_error 'K9s: nicht unterstuetzte Architektur.'; return 1 ;;
  esac
}

k9s_verify_archive() {
  local archive="$1" checksums="$2" asset="$3" hash
  hash="$(awk -v name="$asset" '$2 == name {print $1}' "$checksums")"
  [[ "$hash" =~ ^[a-fA-F0-9]{64}$ ]] || return 1
  printf '%s  %s\n' "$hash" "$archive" | sha256sum --check --status
}

k9s_main() {
  local mode="${1:-install}" version="${K9S_VERSION:-v0.51.0}" arch asset base tmp_dir
  case "$mode" in
    --check|--status) k9s version; return $? ;;
    --help|-h) echo 'K9s: --check, --status, --dry-run; K9S_VERSION=vX.Y.Z fuer eine feste GitHub-Version.'; return 0 ;;
    install|--dry-run) ;;
    *) log_error "Unbekannte Option: $mode"; return 2 ;;
  esac
  [[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { log_error 'K9S_VERSION muss vX.Y.Z entsprechen.'; return 2; }
  arch="$(k9s_arch)" || return 1
  asset="k9s_Linux_${arch}.tar.gz"
  base="https://github.com/derailed/k9s/releases/download/$version"
  if [ "$mode" = --dry-run ]; then
    echo "K9s: ${base}/${asset}; checksums.sha256; Ziel /usr/local/bin/k9s."
    return 0
  fi
  AUTO_INSTALL_TOOL_BASE_DEPS=false begin_measurement tool_install_K9s 'K9s aus GitHub-Release'
  if ! require_disk_mb 256 / || ! ensure_base_apt_packages ca-certificates curl tar coreutils; then
    end_measurement failed; return 1
  fi
  tmp_dir="$(mktemp -d)" || { end_measurement failed; return 1; }
  log_info "Installiere K9s aus GitHub: ${base}/${asset}"
  if ! curl -fsSL --connect-timeout 15 --max-time 300 "$base/$asset" -o "$tmp_dir/$asset" ||
     ! curl -fsSL --connect-timeout 15 --max-time 60 "$base/checksums.sha256" -o "$tmp_dir/checksums.sha256" ||
     ! k9s_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums.sha256" "$asset" ||
     ! tar -xzf "$tmp_dir/$asset" -C "$tmp_dir" k9s ||
     ! chmod 0755 "$tmp_dir/k9s" ||
     ! "$tmp_dir/k9s" version >/dev/null ||
     ! sudo install -m 0755 "$tmp_dir/k9s" /usr/local/bin/k9s; then
    log_error 'K9s: Download, Pruefsumme, Entpacken, Client-Test oder Installation fehlgeschlagen.'
    rm -rf -- "$tmp_dir"; end_measurement failed; return 1
  fi
  rm -rf -- "$tmp_dir"
  mark_tool_installed K9s
  end_measurement success
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  k9s_main "$@"
fi
