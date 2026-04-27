#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_NAME="PDF_Parser"
TOOL_KEY="PDF_Parser"
TOOL_SLUG="pdf_parser"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../helpers/status_tracking.sh"
init_tool_tracking "$TOOL_KEY"
sudo apt-get update
sudo apt-get install -y poppler-utils tesseract-ocr python3 python3-venv python3-pip
sudo mkdir -p /opt/pdf_parser
sudo chown -R "$USER:$USER" /opt/pdf_parser
python3 -m venv /opt/pdf_parser/venv
source /opt/pdf_parser/venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install pymupdf pdfplumber unstructured
deactivate
cat > /opt/pdf_parser/README.md <<EOF
# PDF_Parser

Dokumenten- und PDF-Parser für Legal-, Research- und Content-Workflows.
EOF
mark_current_tool_installed
echo "PDF_Parser wurde erfolgreich installiert."
