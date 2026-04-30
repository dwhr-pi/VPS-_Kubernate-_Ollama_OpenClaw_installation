#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
bash "$ROOT_DIR/scripts/tools/open_webui_install.sh"
bash "$ROOT_DIR/scripts/tools/lightrag_install.sh"
bash "$ROOT_DIR/scripts/tools/qdrant_install.sh"
bash "$ROOT_DIR/scripts/tools/chromadb_install.sh"
bash "$ROOT_DIR/scripts/tools/data_juicer_install.sh"
bash "$ROOT_DIR/scripts/tools/pdf_parser_install.sh"
mark_profile_installed "RAG_Wissensdatenbank"
