#!/usr/bin/env bash
# Nur Vorbereitungsnachweis lesen; kein Cluster- oder Dienstaufruf.
set -euo pipefail
exec "${GITOPS_PYTHON_BIN:-python3}" -I -B -c 'import json,pathlib; p=pathlib.Path("/usr/local/share/openclaw-gitops/bootstrap-ready.json"); assert p.is_file() and not p.is_symlink(); d=json.loads(p.read_text()); assert d.get("scope")=="bootstrap-infrastructure-only"; print("Bootstrap vorbereitet; Runtime/Cluster und App-of-Apps separat pruefen.")'
