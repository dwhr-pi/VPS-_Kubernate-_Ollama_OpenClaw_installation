#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Web_App_Builder" "Web App Builder" "github_cli pre_commit gitleaks semgrep trivy"
