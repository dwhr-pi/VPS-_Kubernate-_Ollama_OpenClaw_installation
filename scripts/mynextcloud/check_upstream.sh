#!/usr/bin/env bash
set -euo pipefail

SERVER_FORK_URL="https://github.com/dwhr-pi/myNextCloud-server.git"
ANDROID_FORK_URL="https://github.com/dwhr-pi/myNexcloud-for-android.git"
SERVER_UPSTREAM_URL="https://github.com/nextcloud/server.git"
ANDROID_UPSTREAM_URL="https://github.com/nextcloud/android.git"
ANDROID_LIBRARY_URL="https://github.com/nextcloud/android-library.git"
NEXTCLOUDPI_URL="https://github.com/nextcloud/nextcloudpi.git"

check_remote() {
  local label="$1"
  local url="$2"
  printf "Pruefe %-24s %s\n" "$label" "$url"
  if git ls-remote --heads "$url" >/dev/null 2>&1; then
    echo "  OK: erreichbar"
  else
    echo "  WARNUNG: nicht erreichbar oder keine Berechtigung"
  fi
}

check_local_repo() {
  local label="$1"
  local dir="$2"
  local upstream="$3"
  [ -n "$dir" ] || return 0
  if [ ! -d "$dir/.git" ]; then
    echo "WARNUNG: $label ist kein Git-Repo: $dir"
    return 0
  fi
  echo
  echo "Lokaler Fork: $label ($dir)"
  git -C "$dir" remote -v
  if ! git -C "$dir" remote get-url upstream >/dev/null 2>&1; then
    echo "HINWEIS: upstream fehlt. Vorgeschlagen: git remote add upstream $upstream"
  fi
  git -C "$dir" status --short
}

main() {
  local server_dir="${1:-}"
  local android_dir="${2:-}"

  check_remote "Server Fork" "$SERVER_FORK_URL"
  check_remote "Android Fork" "$ANDROID_FORK_URL"
  check_remote "Server Upstream" "$SERVER_UPSTREAM_URL"
  check_remote "Android Upstream" "$ANDROID_UPSTREAM_URL"
  check_remote "Android Library" "$ANDROID_LIBRARY_URL"
  check_remote "NextcloudPi Referenz" "$NEXTCLOUDPI_URL"

  check_local_repo "myNextCloud Server" "$server_dir" "$SERVER_UPSTREAM_URL"
  check_local_repo "myNextCloud Mobile" "$android_dir" "$ANDROID_UPSTREAM_URL"
}

main "$@"
