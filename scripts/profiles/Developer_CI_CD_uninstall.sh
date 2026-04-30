#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
for s in pre_commit_hooks kustomize kubectl helm k9s opentofu ansible renovate github_cli docker act forgejo; do
  bash "$ROOT_DIR/scripts/tools/${s}_uninstall.sh" || true
done
mark_profile_removed "Developer_CI_CD"
