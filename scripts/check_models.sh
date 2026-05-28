#!/usr/bin/env bash
set -euo pipefail

echo "Ollama model check"
if command -v ollama >/dev/null 2>&1; then
  ollama list || true
else
  echo "Hinweis: ollama nicht im PATH."
fi
