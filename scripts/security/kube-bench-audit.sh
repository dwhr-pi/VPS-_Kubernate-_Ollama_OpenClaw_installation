#!/usr/bin/env bash
# Run only a maintainer-provided native binary and benchmark configuration.
set -euo pipefail

if (($# == 0)); then
  printf '%s\n' 'Nur Plan: kein Scan, Download oder Clusterzugriff.' \
    'Bewusster Host-Audit: --run ABS_BIN ABS_CFG BENCHMARK node|server'
  exit 0
fi

if (($# != 5)) || [[ "$1" != --run ]]; then
  printf '%s\n' 'Erwartet: --run ABS_BIN ABS_CFG BENCHMARK node|server' >&2
  exit 2
fi

bin="$2" cfg="$3" benchmark="$4"
if [[ "$bin" != /* || "$cfg" != /* || ! -f "$bin" || ! -x "$bin" ||
  ! -f "$cfg/config.yaml" || ! "$benchmark" =~ ^[a-z0-9][a-z0-9.-]{0,39}$ ||
  ! -d "$cfg/$benchmark" ]]; then
  printf '%s\n' 'Geprueftes natives Binary und passender Benchmark-Pfad fehlen.' >&2
  exit 2
fi

case "$5" in
  node) targets=node ;;
  server) targets=master,controlplane,node,etcd,policies ;;
  *) exit 2 ;;
esac

if [[ "$(uname -s)" != Linux ]]; then
  printf '%s\n' 'Audit nur auf einem bewusst ausgewaehlten Linux-Knoten ausfuehren.' >&2
  exit 2
fi

exec "$bin" run --config-dir "$cfg" --benchmark "$benchmark" --targets "$targets" --json
