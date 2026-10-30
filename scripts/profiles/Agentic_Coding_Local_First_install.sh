#!/usr/bin/env bash
set -euo pipefail
case "${1:-install}" in
  --dry-run | --plan)
    echo 'Plan: ein Coding-Client, optional vorhandenes Ollama, Tests, manuelles Review. Keine automatische Installation; Automaton bleibt gesperrt.'
    ;;
  *)
    echo 'Profil ist documentation-first. Erst docs/AGENTIC_CODING_GUIDE.md lesen; keine automatische Toolchain-Installation.' >&2
    exit 2
    ;;
esac
