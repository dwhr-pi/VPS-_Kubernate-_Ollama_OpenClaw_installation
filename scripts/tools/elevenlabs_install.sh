#!/bin/bash
TOOL_NAME="ElevenLabs"
TOOL_KEY="ElevenLabs"
TOOL_SLUG="elevenlabs"
TOOL_DESCRIPTION="Connector-Modul für ElevenLabs-TTS- oder Voice-Cloning-Workflows."
TOOL_MODULE_TYPE="Audio-/Marketing-Connector"
TOOL_ENV_TEMPLATE='ELEVENLABS_API_KEY='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
