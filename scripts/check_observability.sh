#!/usr/bin/env bash
set -euo pipefail

echo "Observability-Check"

for cmd in glances netdata prometheus grafana-server loki docker podman kubectl; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "OK: $cmd gefunden"
  else
    echo "INFO: $cmd nicht gefunden"
  fi
done

for port in 3000 9090 3100 19999 8080; do
  if command -v ss >/dev/null 2>&1 && ss -ltn "( sport = :$port )" | tail -n +2 | grep -q .; then
    echo "INFO: Port $port ist belegt"
  fi
done

echo "Empfehlung Low-Resource: zuerst Glances oder Netdata, Grafana/Prometheus/Loki nur optional."

