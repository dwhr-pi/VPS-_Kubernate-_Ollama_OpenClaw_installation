#!/bin/bash
TOOL_NAME="Supabase"
TOOL_KEY="Supabase"
TOOL_SLUG="supabase"
TOOL_DESCRIPTION="Self-Hosted Supabase als Daten-, Auth-, Realtime- und Storage-Backend auf Basis der offiziellen GitHub-Quellen."
TOOL_MODULE_TYPE="Backend-Platform-Scaffold"
TOOL_GIT_REPO="https://github.com/supabase/supabase.git"
TOOL_APT_PACKAGES="git docker.io docker-compose-v2"
TOOL_POST_INSTALL='if [ -d docker ]; then cd docker && cp .env.example .env 2>/dev/null || true && docker compose up -d; else echo \"Kein docker-Verzeichnis im geklonten Supabase-Repo gefunden. Bitte Upstream prüfen.\"; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Supabase

```txt
Richte ein self-hosted Backend für Auth, Postgres, Storage und Realtime ein und erkläre, wie es mit Open WebUI, LiteLLM und RAG-Diensten zusammenspielt.
```'
TOOL_OPENCLAW_NOTE="Supabase ist hier als größeres Backend-Modul gedacht. Die Self-Hosted-Struktur folgt dem offiziellen GitHub-Repo und bleibt dadurch nah am Upstream."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
