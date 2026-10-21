#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
if [[ $# -eq 0 ]]; then
    set -- doctor
fi
exec "${RAG_COMPLIANCE_PYTHON_BIN:-python3}" -I -B "$ROOT/tools/rag_compliance/review.py" "$@"
