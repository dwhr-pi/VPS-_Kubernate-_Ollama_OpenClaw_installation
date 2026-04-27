#!/bin/bash
TOOL_NAME="Llama_CPP"
TOOL_KEY="Llama_CPP"
TOOL_SLUG="llama_cpp"
TOOL_PACKAGES="llama-cpp-python"
TOOL_DESCRIPTION="Lokale llama.cpp-Anbindung für GGUF-Modelle und experimentelle Inferenz."
TOOL_OPENCLAW_NOTE="Nützlich im KI_Forschung-Profil für alternative lokale Modellpfade neben Ollama."
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
