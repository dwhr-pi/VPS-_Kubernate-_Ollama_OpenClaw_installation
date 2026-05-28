#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="https://github.com/nextcloud/server.git"

usage() {
  cat <<'USAGE'
Usage: scripts/mynextcloud/sync_upstream_server.sh /path/to/myNextCloud-server [--apply]

Dry-run by default. With --apply the script adds/fetches upstream, but does not merge or reset.
USAGE
}

main() {
  local repo_dir="${1:-}"
  local mode="${2:-}"
  if [ -z "$repo_dir" ] || [ "${repo_dir:-}" = "-h" ] || [ "${repo_dir:-}" = "--help" ]; then
    usage
    exit 0
  fi
  if [ ! -d "$repo_dir/.git" ]; then
    echo "Fehler: kein Git-Repo: $repo_dir" >&2
    exit 1
  fi

  echo "Fork based on Nextcloud. Not affiliated with or endorsed by Nextcloud GmbH."
  echo "Repo: $repo_dir"
  echo "Upstream: $UPSTREAM_URL"

  if [ "$mode" != "--apply" ]; then
    echo "DRY-RUN: wuerde upstream setzen/fetchen. Fuer Ausfuehrung: --apply"
    git -C "$repo_dir" remote -v
    git -C "$repo_dir" status --short
    exit 0
  fi

  if git -C "$repo_dir" remote get-url upstream >/dev/null 2>&1; then
    git -C "$repo_dir" remote set-url upstream "$UPSTREAM_URL"
  else
    git -C "$repo_dir" remote add upstream "$UPSTREAM_URL"
  fi
  git -C "$repo_dir" fetch upstream --tags
  git -C "$repo_dir" status --short
  echo "Upstream wurde gefetcht. Bitte Branding-/Lizenz-Diff pruefen, bevor gemergt wird."
}

main "$@"
