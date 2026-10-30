#!/usr/bin/env bash
# Standard-Update ausschliesslich ueber signierte Release-Metadaten; Repair bleibt separat.
set -Eeuo pipefail
ROOT="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
if (($# == 0)) || [[ $# == 1 && $1 == --dry-run ]]; then
  mode=${1:---apply}
  if [[ -n ${OPENCLAW_RELEASE_TAG:-} && -n ${OPENCLAW_RELEASE_ARTIFACTS:-} && -n ${OPENCLAW_RELEASE_PUBLIC_KEY:-} ]]; then
    set -- --tag "$OPENCLAW_RELEASE_TAG" --artifacts "$OPENCLAW_RELEASE_ARTIFACTS" --public-key "$OPENCLAW_RELEASE_PUBLIC_KEY" "$mode"
    if [[ "$mode" == --apply ]]; then set -- "$@" --fetch; fi
  else
    printf '%s\n' 'Kein Release gewaehlt: --tag vX.Y.Z --artifacts ABS --public-key ABS [--dry-run|--apply --fetch]. Kein main-Fallback.' >&2
    exit 2
  fi
fi
exec python3 -I -B "$ROOT/scripts/security/update_verified_release.py" "$@"
