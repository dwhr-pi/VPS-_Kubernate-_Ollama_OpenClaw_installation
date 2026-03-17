# OpenClaw .env example
#
# Quick start:
# 1) Copy this file to `.env` (for local runs from this repo), OR to `~/.openclaw/.env` (for launchd/systemd daemons).
# 2) Fill only the values you use.
# 3) Keep real secrets out of git.
#
# Env-source precedence for environment variables (highest -> lowest):
# process env, ./.env, ~/.openclaw/.env, then openclaw.json `env` block.
# Existing non-empty process env vars are not overridden by dotenv/config env loading.
# Note: direct config keys (for example `gateway.auth.token` or channel tokens in openclaw.json)
# are resolved separately from env loading and often take precedence over env fallbacks.

# -----------------------------------------------------------------------------
# Gateway auth + paths
# -----------------------------------------------------------------------------
# Lokales Setup, keine externen Kosten
BLOCK_PAID_API=true
# Recommended if the gateway binds beyond loopback.
OPENCLAW_GATEWAY_TOKEN=a40b6c058e322f2b6d3e03d038b2146baebf0684d8df419e
# Example generator: openssl rand -hex 32

# Optional alternative auth mode (use token OR password).
# OPENCLAW_GATEWAY_PASSWORD=change-me-to-a-strong-password

# Optional path overrides (defaults shown for reference).
OPENCLAW_STATE_DIR=/home/ubuntu/.openclaw
OPENCLAW_CONFIG_PATH=/home/ubuntu/.openclaw/openclaw.json
OPENCLAW_HOME=/home/ubuntu

# Optional: import missing keys from your login shell profile.
OPENCLAW_LOAD_SHELL_ENV=1
OPENCLAW_SHELL_ENV_TIMEOUT_MS=15000
OLLAMA_HOST=http://127.0.0.1:11434
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:1b

# -----------------------------------------------------------------------------
# Model provider API keys (set at least one)
# -----------------------------------------------------------------------------
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
GEMINI_API_KEY=AIzaSyCBKBBHQZUSjyfKWLt6vRsTQ82y9dWbWsw
# OPENROUTER_API_KEY=sk-or-...
# OPENCLAW_LIVE_OPENAI_KEY=sk-...
# OPENCLAW_LIVE_ANTHROPIC_KEY=sk-ant-...
# OPENCLAW_LIVE_GEMINI_KEY=...
# OPENAI_API_KEY_1=...
# ANTHROPIC_API_KEY_1=...
GEMINI_API_KEY_1=AIzaSyDjZPuexNFtiJhtQZscSA7PSZLN2AYk9B0
# GOOGLE_API_KEY=...
GOOGLE_PLACES_API_KEY=AIzaSyB0o48ssEs-zc2Rrq6LGb-JxNmAHB63lHQ
# OPENAI_API_KEYS=sk-1,sk-2
# ANTHROPIC_API_KEYS=sk-ant-1,sk-ant-2
GEMINI_API_KEYS=AIzaSyCBKBBHQZUSjyfKWLt6vRsTQ82y9dWbWsw,AIzaSyDjZPuexNFtiJhtQZscSA7PSZLN2AYk9B0

# Optional additional providers
# ZAI_API_KEY=...
# AI_GATEWAY_API_KEY=...
# MINIMAX_API_KEY=...
# SYNTHETIC_API_KEY=...

# -----------------------------------------------------------------------------
# Channels (only set what you enable)
# -----------------------------------------------------------------------------
TELEGRAM_BOT_TOKEN=8342520213:AAGN1qacvyHPTgjUcw_wBUOZGmQFGg41B8o
DISCORD_BOT_TOKEN=41eb2d25c6e4e12812310dcc432cb2c8eaadd572ee68892b8808e364099121a9
# SLACK_BOT_TOKEN=xoxb-...
# SLACK_APP_TOKEN=xapp-...

# Optional channel env fallbacks
# MATTERMOST_BOT_TOKEN=...
# MATTERMOST_URL=https://chat.example.com
# ZALO_BOT_TOKEN=...
# OPENCLAW_TWITCH_ACCESS_TOKEN=oauth:...

# -----------------------------------------------------------------------------
# Tools + voice/media (optional)
# -----------------------------------------------------------------------------
BRAVE_API_KEY=BSAaP9Z61snBPRRJ1-4T1uqIht-r_hK
# PERPLEXITY_API_KEY=pplx-...
# FIRECRAWL_API_KEY=...

# ELEVENLABS_API_KEY=sk_915e3bb7a2aa2b27f93255f75485c703d2673060c77e1029
# XI_API_KEY=...  # alias for ElevenLabs
# DEEPGRAM_API_KEY=...


# Notion API Key für OpenClaw
NOTION_API_KEY=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



# Ab hier neues, nicht Bestandteil der orginalen `.env`
# Web tools 
