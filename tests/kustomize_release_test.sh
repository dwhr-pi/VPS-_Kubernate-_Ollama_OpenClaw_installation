#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/kustomize_install.sh"
test_arch=x86_64
uname() { if [[ "$1" == -s ]]; then echo Linux; else echo "$test_arch"; fi; }
begin_measurement() {
  echo 'Unexpected install in dry-run' >&2
  return 99
}
unset KUSTOMIZE_VERSION
[[ "$(kustomize_main --dry-run)" == *'kustomize_v5.8.2_linux_amd64.tar.gz'* ]]
test_arch=aarch64
[[ "$(kustomize_main --dry-run)" == *'kustomize_v5.8.2_linux_arm64.tar.gz'* ]]
test_arch=unsupported
if kustomize_main --dry-run >/dev/null 2>&1; then exit 1; fi
test_arch=x86_64 KUSTOMIZE_VERSION=invalid
if kustomize_main --dry-run >/dev/null 2>&1; then exit 1; fi
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
printf 'dummy archive\n' >"$temp_dir/archive"
hash="$(sha256sum "$temp_dir/archive")"
printf '%s  asset.tar.gz\n' "${hash%% *}" >"$temp_dir/checksums.txt"
kustomize_verify_archive "$temp_dir/archive" "$temp_dir/checksums.txt" asset.tar.gz
printf 'corruption\n' >>"$temp_dir/archive"
if kustomize_verify_archive "$temp_dir/archive" "$temp_dir/checksums.txt" asset.tar.gz; then exit 1; fi
if kustomize_verify_archive "$temp_dir/archive" "$temp_dir/checksums.txt" missing; then exit 1; fi
echo 'PASS: amd64/arm64, non-install dry-run, version validation and checksum rejection.'
