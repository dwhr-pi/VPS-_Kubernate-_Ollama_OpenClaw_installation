#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/agent_framework_common.sh"
agent_framework_main status
