#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/syft_install.sh"
uname() { echo "$test_arch"; }
test_arch=x86_64
[[ "$(syft_arch)" == amd64 ]]
test_arch=aarch64
[[ "$(syft_arch)" == arm64 ]]
test_arch=unknown
if syft_arch >/dev/null 2>&1; then echo 'FAIL: unsupported architecture'; exit 1; fi
test_arch=x86_64 SYFT_VERSION=v1.54.1
curl() { echo 'Unexpected download' >&2; return 99; }
sudo() { echo 'Unexpected sudo' >&2; return 99; }
output="$(syft_main --dry-run)"
[[ "$output" == *syft_1.54.1_linux_amd64.tar.gz* ]]
SYFT_VERSION=invalid
if syft_main --dry-run >/dev/null 2>&1; then echo 'FAIL: invalid version'; exit 1; fi
tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$tmp_dir"' EXIT
asset=syft_1.54.1_linux_amd64.tar.gz
printf 'test-archive\n' > "$tmp_dir/$asset"
hash="$(sha256sum "$tmp_dir/$asset" | cut -d' ' -f1)"
printf '%s  %s\n' "$hash" "$asset" > "$tmp_dir/checksums"
syft_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums" "$asset"
if syft_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums" wrong.tar.gz; then echo 'FAIL: wrong asset'; exit 1; fi
printf 'corrupt' >> "$tmp_dir/$asset"
if syft_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums" "$asset"; then echo 'FAIL: corrupt archive'; exit 1; fi
echo 'PASS: Syft architectures, release name, dry-run and checksum rejection.'
