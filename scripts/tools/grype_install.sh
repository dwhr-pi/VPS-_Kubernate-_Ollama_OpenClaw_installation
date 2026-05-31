#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"

TOOL_NAME="Grype"
INSTALL_BIN="${GRYPE_INSTALL_BIN:-/usr/local/bin/grype}"
REPO_API="https://api.github.com/repos/anchore/grype/releases/latest"
RELEASE_BASE="https://github.com/anchore/grype/releases/download"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Grype Installer

Installiert Grype nicht via apt, weil Ubuntu noble kein offizielles grype-Paket
bereitstellt. Stattdessen wird das offizielle GitHub-Release von anchore/grype
geladen und per SHA256-Checksumme verifiziert.

Optionen:
  --check      grype version pruefen
  --dry-run    Nur anzeigen, was passieren wuerde
  --help       Hilfe anzeigen

Umgebungsvariablen:
  GRYPE_VERSION      Feste Version, z. B. v0.87.0. Ohne Angabe wird latest per GitHub API genutzt.
  GRYPE_INSTALL_BIN  Zielpfad, Standard: /usr/local/bin/grype

Architektur:
  x86_64/amd64  -> linux_amd64
  aarch64/arm64 -> linux_arm64
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
    *)
      log_error "Grype GitHub-Release fuer Architektur '$(uname -m)' ist im Installer nicht hinterlegt."
      return 1
      ;;
  esac
}

resolve_version() {
  if [ -n "${GRYPE_VERSION:-}" ]; then
    printf '%s\n' "${GRYPE_VERSION#v}"
    return 0
  fi

  curl -fsSL "$REPO_API" | sed -n 's/.*"tag_name":[[:space:]]*"v\([^"]*\)".*/\1/p' | head -n 1
}

check_installed() {
  if command -v grype >/dev/null 2>&1; then
    grype version
    return 0
  fi
  log_warn "Grype ist noch nicht installiert oder nicht im PATH."
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

  if ! ensure_user_workspace || ! require_disk_mb 512 /; then
    end_measurement "failed"
    return 1
  fi

  ensure_base_apt_packages ca-certificates curl tar

  local arch version asset checksum_asset url checksum_url tmpdir archive checksum_file
  arch="$(detect_arch)"
  version="$(resolve_version)"
  if [ -z "$version" ]; then
    log_error "Grype-Version konnte nicht bestimmt werden."
    end_measurement "failed"
    exit 1
  fi

  asset="grype_${version}_linux_${arch}.tar.gz"
  checksum_asset="grype_${version}_checksums.txt"
  url="${RELEASE_BASE}/v${version}/${asset}"
  checksum_url="${RELEASE_BASE}/v${version}/${checksum_asset}"
  tmpdir="$(mktemp -d)"
  archive="${tmpdir}/${asset}"
  checksum_file="${tmpdir}/${checksum_asset}"

  log_info "Installiere Grype aus offiziellem GitHub-Release:"
  log_info "  Version:      v${version}"
  log_info "  Architektur:  linux_${arch}"
  log_info "  Binary:       ${url}"
  log_info "  Checksums:    ${checksum_url}"
  log_info "  Ziel:         ${INSTALL_BIN}"

  if [ "$DRY_RUN" = "1" ]; then
    run_cmd curl -fsSL "$url" -o "$archive"
    run_cmd curl -fsSL "$checksum_url" -o "$checksum_file"
    run_cmd bash -lc "cd '$tmpdir' && grep ' ${asset}$' '$checksum_asset' > '${checksum_asset}.one' && sha256sum -c '${checksum_asset}.one'"
    run_cmd tar -xzf "$archive" -C "$tmpdir" grype
    run_cmd sudo install -m 0755 "${tmpdir}/grype" "$INSTALL_BIN"
    end_measurement "success"
    exit 0
  fi

  curl -fsSL "$url" -o "$archive"
  curl -fsSL "$checksum_url" -o "$checksum_file"

  (
    cd "$tmpdir"
    grep " ${asset}$" "$checksum_asset" > "${checksum_asset}.one"
    sha256sum -c "${checksum_asset}.one"
  )

  tar -xzf "$archive" -C "$tmpdir" grype
  sudo install -m 0755 "${tmpdir}/grype" "$INSTALL_BIN"
  rm -rf "$tmpdir"

  if ! "$INSTALL_BIN" version; then
    log_error "Grype wurde installiert, aber der Versionstest ist fehlgeschlagen."
    end_measurement "failed"
    exit 1
  fi

  mark_tool_installed "$TOOL_NAME"
  log_success "${TOOL_NAME} installiert."
  end_measurement "success"
}

main "$@"
