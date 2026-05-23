#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Repo_Maintainer_Agent" "Repo Maintainer Agent" "github_cli pre_commit gitleaks semgrep trivy"
