#!/bin/bash
TOOL_NAME="MusicGen"
TOOL_KEY="MusicGen"
TOOL_SLUG="musicgen"
TOOL_PACKAGES="audiocraft"
TOOL_DESCRIPTION="Lokale Musikgenerierung auf Basis von Meta Audiocraft / MusicGen."
TOOL_OPENCLAW_NOTE="Nützlich für Media_Musik, Audio und experimentelle Musik-Pipelines."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
