#!/bin/bash
TOOL_NAME="Voice_Assistant_Runtime"
TOOL_KEY="Voice_Assistant_Runtime"
TOOL_SLUG="voice_assistant_runtime"
TOOL_DESCRIPTION="Vorkonfiguriertes Laufzeitmodul für Speech-to-Text, TTS und Antwortverkettung."
TOOL_MODULE_TYPE="Laufzeitmodul"
TOOL_OPENCLAW_NOTE="Nutze Whisper, Piper oder Coqui TTS zusammen mit OpenClaw/Ollama für lokale Sprachassistenten."
TOOL_ENV_TEMPLATE='STT_ENGINE=whisper\nTTS_ENGINE=piper\nLLM_BACKEND=ollama\nOLLAMA_HOST=http://localhost:11434'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
