#!/usr/bin/env bash
set -euo pipefail

echo "ENV Permissions Audit"
echo "====================="

find "${HOME}" -maxdepth 3 \( -name ".env" -o -name ".env.*" \) -type f 2>/dev/null | while read -r file; do
  perms="$(stat -c '%a' "$file" 2>/dev/null || echo unknown)"
  echo "$perms $file"
done

echo
echo "Empfehlung:"
echo "- .env-Dateien möglichst auf 600 begrenzen"
echo "- keine sensiblen .env-Dateien im Git-Repo ablegen"
