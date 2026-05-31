#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"

TOOL_NAME="Flux_CLI"
INSTALL_BIN="${FLUX_INSTALL_BIN:-/usr/local/bin/flux}"
REPO_API="https://api.github.com/repos/fluxcd/flux2/releases/latest"
RELEASE_BASE="https://github.com/fluxcd/flux2/releases/download"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Flux CLI Installer

Installiert Flux CLI direkt aus offiziellen GitHub-Releases und verifiziert die
SHA256-Checksumme. Kein curl|bash-One-Liner.

Optionen:
  --check      flux --version pruefen
  --dry-run    Nur anzeigen, was passieren wuerde
  --help       Hilfe anzeigen

Umgebungsvariablen:
  FLUX_VERSION      Feste Version, z. B. v2.8.8. Ohne Angabe wird latest per GitHub API genutzt.
  FLUX_INSTALL_BIN  Zielpfad, Standard: /usr/local/bin/flux

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
    armv7l|armv6l)
      printf 'arm'
      ;;
    *)
      echo "Fehler: Nicht unterstuetzte Architektur fuer Flux CLI: $(uname -m)" >&2
      return 1
      ;;
  esac
}

resolve_version() {
  if [ -n "${FLUX_VERSION:-}" ]; then
    printf '%s\n' "${FLUX_VERSION#v}"
    return 0
  fi

  curl -fsSL "$REPO_API" | sed -n 's/.*"tag_name":[[:space:]]*"v\([^"]*\)".*/\1/p' | head -n 1
}

check_installed() {
  if command -v flux >/dev/null 2>&1; then
    flux --version
    return 0
  fi
  echo "Flux CLI ist noch nicht installiert oder nicht im PATH."
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
        echo "Unbekannte Option: $1" >&2
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

  begin_measurement "tool_install_${TOOL_NAME}" "Tool installieren: Flux CLI"

  local arch version asset checksum_asset url checksum_url tmpdir archive checksum_file
  arch="$(detect_arch)"
  version="$(resolve_version)"
  if [ -z "$version" ]; then
    echo "Fehler: Flux-Version konnte nicht bestimmt werden." >&2
    end_measurement "failed"
    exit 1
  fi

  asset="flux_${version}_linux_${arch}.tar.gz"
  checksum_asset="flux_${version}_checksums.txt"
  url="${RELEASE_BASE}/v${version}/${asset}"
  checksum_url="${RELEASE_BASE}/v${version}/${checksum_asset}"
  tmpdir="$(mktemp -d)"
  archive="${tmpdir}/${asset}"
  checksum_file="${tmpdir}/${checksum_asset}"

  echo "Installiere Flux CLI aus offiziellem GitHub-Release:"
  echo "  Version:      v${version}"
  echo "  Architektur:  linux_${arch}"
  echo "  Binary:       ${url}"
  echo "  Checksums:    ${checksum_url}"
  echo "  Ziel:         ${INSTALL_BIN}"

  if [ "$DRY_RUN" = "1" ]; then
    run_cmd curl -fsSL "$url" -o "$archive"
    run_cmd curl -fsSL "$checksum_url" -o "$checksum_file"
    run_cmd sha256sum -c "$checksum_file" --ignore-missing
    run_cmd tar -xzf "$archive" -C "$tmpdir" flux
    run_cmd sudo install -m 0755 "${tmpdir}/flux" "$INSTALL_BIN"
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

  tar -xzf "$archive" -C "$tmpdir" flux
  sudo install -m 0755 "${tmpdir}/flux" "$INSTALL_BIN"
  rm -rf "$tmpdir"

  if ! "$INSTALL_BIN" --version; then
    echo "Fehler: Flux CLI wurde installiert, aber der Versionstest ist fehlgeschlagen." >&2
    end_measurement "failed"
    exit 1
  fi

  mark_tool_installed "$TOOL_NAME"
  end_measurement "success"
}

main "$@"
