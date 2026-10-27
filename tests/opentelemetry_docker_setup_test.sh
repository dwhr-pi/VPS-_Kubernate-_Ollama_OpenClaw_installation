#!/usr/bin/env bash
# Regression contract replaces the retired Docker provisioning tests.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
cd "$ROOT"
exec "${PYTHON_BIN:-python3}" -B -m unittest tests.test_docker_remainder
