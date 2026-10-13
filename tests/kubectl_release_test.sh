#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/tools/kubectl_install.sh"
uname() { echo "$test_arch"; }
test_arch=x86_64
[[ "$(kubectl_arch)" == amd64 ]]
test_arch=aarch64
[[ "$(kubectl_arch)" == arm64 ]]
test_arch=unsupported
if kubectl_arch >/dev/null 2>&1; then echo 'FAIL: unsupported architecture'; exit 1; fi
test_arch=x86_64 KUBECTL_VERSION=v1.34.0
sudo() { echo 'Unexpected sudo' >&2; return 99; }
curl() { echo 'Unexpected download' >&2; return 99; }
kubectl_main --dry-run >/dev/null
KUBECTL_VERSION=invalid
if kubectl_main --dry-run >/dev/null 2>&1; then echo 'FAIL: invalid version accepted'; exit 1; fi
tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$tmp_dir"' EXIT
printf 'test-binary\n' > "$tmp_dir/binary"
sha256sum "$tmp_dir/binary" | cut -d' ' -f1 > "$tmp_dir/hash"
verify_kubectl_checksum "$tmp_dir/binary" "$tmp_dir/hash"
printf 'corrupt\n' >> "$tmp_dir/binary"
if verify_kubectl_checksum "$tmp_dir/binary" "$tmp_dir/hash"; then echo 'FAIL: corrupt download accepted'; exit 1; fi
echo 'PASS: architectures, version validation, dry-run and checksum rejection checked.'
