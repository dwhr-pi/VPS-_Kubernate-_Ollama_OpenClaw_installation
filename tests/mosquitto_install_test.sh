#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
plan="$(bash "$repo_dir/scripts/tools/mosquitto_install.sh" --dry-run)"
[[ "$plan" == *'"kind": "cmake"'* && "$plan" == *'eclipse-mosquitto/mosquitto'* ]]
[[ "$plan" == *'app/sbin/mosquitto'* ]]
echo "PASS: native CMake plan, no broker/config/port changes. Rollback/auth example covered by Python fixtures."
