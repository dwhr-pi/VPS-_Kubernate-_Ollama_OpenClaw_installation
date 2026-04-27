#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
init_tool_tracking "PDF_Parser"
sudo rm -rf /opt/pdf_parser
mark_current_tool_removed
echo "PDF_Parser wurde entfernt."
