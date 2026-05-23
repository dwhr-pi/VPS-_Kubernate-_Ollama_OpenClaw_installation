#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_uninstaller.sh" "Voice_Command_Center"
