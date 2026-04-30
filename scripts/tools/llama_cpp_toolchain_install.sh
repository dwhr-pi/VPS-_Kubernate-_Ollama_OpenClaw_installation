#!/bin/bash
TOOL_NAME="Llama_CPP_Toolchain"
TOOL_KEY="Llama_CPP_Toolchain"
TOOL_SLUG="llama_cpp_toolchain"
TOOL_DESCRIPTION="GitHub-basierte llama.cpp-Toolchain für GGUF-Export, Quantisierung und lokale Modelltests."
TOOL_MODULE_TYPE="GGUF- und Quantisierungs-Toolchain"
TOOL_GIT_REPO="https://github.com/ggml-org/llama.cpp.git"
TOOL_APT_PACKAGES="git build-essential cmake ninja-build python3"
TOOL_POST_INSTALL='cmake -S . -B build -G Ninja && cmake --build build -j\"$(nproc)\"'
TOOL_RUN_SCRIPT='#!/bin/bash
set -euo pipefail
echo "Beispiel: ./build/bin/llama-quantize ./modell.gguf ./modell-q4_k_m.gguf Q4_K_M"'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für llama.cpp Toolchain

```txt
Exportiere dieses feinjustierte Modell nach GGUF, quantisiere es für lokale Nutzung und bereite danach ein Ollama-Modelfile vor.
```'
TOOL_OPENCLAW_NOTE="Schließt den LLM-Builder-Workflow von Adapter/Merge über GGUF bis zur lokalen Quantisierung für Ollama."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
