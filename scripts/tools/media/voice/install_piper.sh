#!/usr/bin/env bash
set -euo pipefail

TOOL_ID="piper"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"

echo "MEDIA STUDIO: ${TOOL_ID}"
echo "Dieses Tool ist documentation-first/planned und wird nicht automatisch installiert."
echo "Bitte zuerst Doku, Lizenz, Ressourcenbedarf, Einwilligung und KI-Kennzeichnung pruefen."
echo "Doku: ${REPO_ROOT}/docs/media_studio/README.md"
echo "Fortfahren mit echter Installation ist absichtlich nicht implementiert."
exit 0
