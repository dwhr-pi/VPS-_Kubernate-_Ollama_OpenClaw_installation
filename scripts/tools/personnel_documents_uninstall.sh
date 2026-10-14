#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers/personnel_documents_common.sh"
personnel_main "${1:-uninstall}"
