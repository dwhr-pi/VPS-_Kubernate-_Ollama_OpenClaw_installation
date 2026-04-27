#!/bin/bash
TOOL_NAME="LlamaIndex"
TOOL_SLUG="llamaindex"
TOOL_PACKAGES="llama-index"
TOOL_DESCRIPTION="Indexing- und Retrieval-Layer für Dokumente, Papers und juristische Quellen."
TOOL_OPENCLAW_NOTE="Besonders passend für KI_Forschung und Rechtsberatung mit RAG-Fokus."
TOOL_PROMPT_EXAMPLE='```txt
Erstelle mit LlamaIndex einen Index für Papers oder Gesetze und formuliere ein Abfrage-Beispiel für Ollama.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
