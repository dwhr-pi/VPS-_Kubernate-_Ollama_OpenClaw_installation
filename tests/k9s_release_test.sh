#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/k9s_install.sh"
uname() { echo "$test_arch"; }
test_arch=x86_64
[[ "$(k9s_arch)" == amd64 ]]
test_arch=aarch64
[[ "$(k9s_arch)" == arm64 ]]
test_arch=unknown
if k9s_arch >/dev/null 2>&1; then echo 'FAIL: unsupported architecture'; exit 1; fi
test_arch=x86_64 K9S_VERSION=v0.51.0
sudo() { echo 'Unexpected sudo' >&2; return 99; }
curl() { echo 'Unexpected download' >&2; return 99; }
k9s_main --dry-run >/dev/null
K9S_VERSION=invalid
if k9s_main --dry-run >/dev/null 2>&1; then echo 'FAIL: invalid version'; exit 1; fi
tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$tmp_dir"' EXIT
asset=k9s_Linux_amd64.tar.gz
printf 'test-archive\n' > "$tmp_dir/$asset"
hash="$(sha256sum "$tmp_dir/$asset" | cut -d' ' -f1)"
printf '%s  %s\n' "$hash" "$asset" > "$tmp_dir/checksums"
k9s_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums" "$asset"
if k9s_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums" k9s_Linux_arm64.tar.gz; then echo 'FAIL: wrong asset accepted'; exit 1; fi
printf 'corrupt' >> "$tmp_dir/$asset"
if k9s_verify_archive "$tmp_dir/$asset" "$tmp_dir/checksums" "$asset"; then echo 'FAIL: corrupt archive accepted'; exit 1; fi
echo 'PASS: K9s architectures, dry-run, version and archive checksums checked.'
