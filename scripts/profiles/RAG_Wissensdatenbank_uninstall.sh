#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
bash "$ROOT_DIR/scripts/tools/pdf_parser_uninstall.sh" || true
bash "$ROOT_DIR/scripts/tools/data_juicer_uninstall.sh" || true
bash "$ROOT_DIR/scripts/tools/chromadb_uninstall.sh" || true
bash "$ROOT_DIR/scripts/tools/qdrant_uninstall.sh" || true
bash "$ROOT_DIR/scripts/tools/lightrag_uninstall.sh" || true
bash "$ROOT_DIR/scripts/tools/open_webui_uninstall.sh" || true
mark_profile_removed "RAG_Wissensdatenbank"
