#!/usr/bin/env bash
# Single-shot local probe for a scheduler; never mutates Kubernetes.
set -euo pipefail

request() {
  local timeout="$1" url="$2" code
  shift 2
  if ! code="$(curl -q --silent --show-error --noproxy '*' --proto '=http' \
    --connect-timeout 3 --max-time "$timeout" --output /dev/null \
    --write-out '%{http_code}' "$@" "$url")" || [[ "$code" != 200 ]]; then
    printf 'Watchdog: %s fehlgeschlagen (HTTP %s).\n' "$url" "${code:-unbekannt}" >&2
    return 1
  fi
}

case "${1:-gateway}:$#" in
  gateway:0 | gateway:1)
    request 5 http://127.0.0.1:18789/readyz
    ;;
  ollama:1)
    request 5 http://127.0.0.1:11434/api/tags
    ;;
  warmup:2 | pull:2)
    if [[ ! "$2" =~ ^[a-zA-Z0-9][a-zA-Z0-9._:/-]{0,127}$ ]]; then
      printf 'Watchdog: ungueltiger Modellname.\n' >&2
      exit 2
    fi
    if [[ "$1" == warmup ]]; then
      payload="$(printf '{"model":"%s","stream":false,"keep_alive":"10m"}' "$2")"
      request 90 http://127.0.0.1:11434/api/generate --json "$payload"
    else
      payload="$(printf '{"model":"%s","stream":false}' "$2")"
      request 900 http://127.0.0.1:11434/api/pull --json "$payload"
    fi
    ;;
  *)
    printf 'Aufruf: %s [gateway | ollama | warmup MODELL | pull MODELL]\n' "$0" >&2
    exit 2
    ;;
esac
