#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="Helm"
INSTALL_BIN="${HELM_INSTALL_BIN:-/usr/local/bin/helm}"
REPO_API="https://api.github.com/repos/helm/helm/releases/latest"
RELEASE_BASE="https://get.helm.sh"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Helm Installer

Installiert Helm nicht via apt, weil Ubuntu noble kein offizielles helm-Paket
in den Standard-Repositories bereitstellt. Die Version wird aus GitHub
ermittelt, das offizielle Helm-Release-Archiv wird geladen und per SHA256
geprueft.

Optionen:
  --check      helm version pruefen
  --dry-run    Nur anzeigen, was passieren wuerde
  --help       Hilfe anzeigen

Umgebungsvariablen:
  HELM_VERSION      Feste Version, z. B. v3.15.4. Ohne Angabe wird latest per GitHub API genutzt.
  HELM_INSTALL_BIN  Zielpfad, Standard: /usr/local/bin/helm

Architektur:
  x86_64/amd64  -> linux-amd64
  aarch64/arm64 -> linux-arm64
  armv7l/armv6l -> linux-arm
USAGE
}

run_cmd() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] %q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)
      printf 'amd64'
      ;;
    aarch64|arm64)
      printf 'arm64'
      ;;
    armv7l|armv6l)
      printf 'arm'
      ;;
    *)
      log_error "Helm Release fuer Architektur '$(uname -m)' ist im Installer nicht hinterlegt."
      return 1
      ;;
  esac
}

resolve_version() {
  if [ -n "${HELM_VERSION:-}" ]; then
    printf '%s\n' "${HELM_VERSION#v}"
    return 0
  fi

  curl -fsSL "$REPO_API" | sed -n 's/.*"tag_name":[[:space:]]*"v\([^"]*\)".*/\1/p' | head -n 1
}

check_installed() {
  if command -v helm >/dev/null 2>&1; then
    helm version --short
    return 0
  fi
  log_warn "Helm ist noch nicht installiert oder nicht im PATH."
  return 1
}

main() {
  local mode="install"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --check|--status)
        mode="check"
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log_error "Unbekannte Option: $1"
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  if [ "$mode" = "check" ]; then
    check_installed
    exit $?
  fi

  begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: ${TOOL_NAME}"

  if ! ensure_user_workspace || ! require_disk_mb 256 /; then
    end_measurement "failed"
    return 1
  fi

  ensure_base_apt_packages ca-certificates curl tar

  local arch version platform asset url checksum_url tmpdir archive checksum_file extract_dir
  arch="$(detect_arch)"
  version="$(resolve_version)"
  if [ -z "$version" ]; then
    log_error "Helm-Version konnte nicht bestimmt werden."
    end_measurement "failed"
    exit 1
  fi

  platform="linux-${arch}"
  asset="helm-v${version}-${platform}.tar.gz"
  url="${RELEASE_BASE}/${asset}"
  checksum_url="${url}.sha256sum"
  tmpdir="$(mktemp -d)"
  archive="${tmpdir}/${asset}"
  checksum_file="${tmpdir}/${asset}.sha256sum"
  extract_dir="${tmpdir}/${platform}"

  log_info "Installiere Helm aus offiziellem Release:"
  log_info "  GitHub-Projekt: https://github.com/helm/helm"
  log_info "  Version:        v${version}"
  log_info "  Architektur:    ${platform}"
  log_info "  Binary:         ${url}"
  log_info "  Checksum:       ${checksum_url}"
  log_info "  Ziel:           ${INSTALL_BIN}"

  if [ "$DRY_RUN" = "1" ]; then
    run_cmd curl -fsSL "$url" -o "$archive"
    run_cmd curl -fsSL "$checksum_url" -o "$checksum_file"
    run_cmd bash -lc "cd '$tmpdir' && sha256sum -c '$checksum_file'"
    run_cmd tar -xzf "$archive" -C "$tmpdir"
    run_cmd sudo install -m 0755 "${extract_dir}/helm" "$INSTALL_BIN"
    end_measurement "success"
    exit 0
  fi

  curl -fsSL "$url" -o "$archive"
  curl -fsSL "$checksum_url" -o "$checksum_file"

  (
    cd "$tmpdir"
    sha256sum -c "$checksum_file"
  )

  tar -xzf "$archive" -C "$tmpdir"
  sudo install -m 0755 "${extract_dir}/helm" "$INSTALL_BIN"
  rm -rf "$tmpdir"

  if ! "$INSTALL_BIN" version --short; then
    log_error "Helm wurde installiert, aber der Versionstest ist fehlgeschlagen."
    end_measurement "failed"
    exit 1
  fi

  mark_tool_installed "$TOOL_NAME"
  log_success "${TOOL_NAME} installiert."
  end_measurement "success"
}

main "$@"
