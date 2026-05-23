#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Umwelt_Klima_Energie" "Umwelt Klima Energie" "home_assistant grafana prometheus netdata jupyterlab"
