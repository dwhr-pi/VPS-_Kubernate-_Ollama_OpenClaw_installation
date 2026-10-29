#!/usr/bin/env bash
# Derselbe offline gepruefte Sealed-Secrets-Vertrauensanker, kein Klartextmanifest.
set -euo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
exec bash "$ROOT/scripts/seal_openclaw_secret.sh" --namespace llmops \
  --name gemini-runtime --key GEMINI_API_KEY "$@"
