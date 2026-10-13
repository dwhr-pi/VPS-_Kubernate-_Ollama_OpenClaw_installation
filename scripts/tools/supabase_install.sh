#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers/simple_tool_common.sh
source "$SCRIPT_DIR/helpers/simple_tool_common.sh"
TOOL_NAME="Supabase"
TOOL_KEY="Supabase"
TOOL_SLUG="supabase"
TOOL_DESCRIPTION="Self-Hosted Supabase als Daten-, Auth-, Realtime- und Storage-Backend auf Basis der offiziellen GitHub-Quellen."
TOOL_MODULE_TYPE="Backend-Platform-Scaffold"
TOOL_GIT_REPO="https://github.com/supabase/supabase.git"
TOOL_APT_PACKAGES="git"
start_supabase_stack() {
    if [ ! -d "$TOOL_DIR/docker" ]; then
        log_error "Supabase: docker-Verzeichnis fehlt. Git-Quelle/Upstream-Layout pruefen."
        return 1
    fi
    ensure_docker_compose_available || return 1
    (
        cd "$TOOL_DIR/docker" || exit 1
        if [ ! -f .env ]; then
            if [ ! -f .env.example ]; then
                log_error "Supabase: .env und .env.example fehlen."
                exit 1
            fi
            cp .env.example .env || exit 1
            chmod 600 .env || exit 1
        fi
        run_docker_compose up -d
    )
}
TOOL_POST_INSTALL_FUNCTION="start_supabase_stack"
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Supabase

```txt
Richte ein self-hosted Backend für Auth, Postgres, Storage und Realtime ein und erkläre, wie es mit Open WebUI, LiteLLM und RAG-Diensten zusammenspielt.
```'
TOOL_OPENCLAW_NOTE="Supabase ist hier als größeres Backend-Modul gedacht. Die Self-Hosted-Struktur folgt dem offiziellen GitHub-Repo und bleibt dadurch nah am Upstream."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
