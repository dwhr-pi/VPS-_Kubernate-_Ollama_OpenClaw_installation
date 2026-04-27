#!/bin/bash
TOOL_NAME="LangChain"
TOOL_SLUG="langchain"
TOOL_PACKAGES="langchain"
TOOL_DESCRIPTION="Tool-Use-, Prompt- und RAG-Bausteine für Agenten- und Forschungs-Workflows."
TOOL_OPENCLAW_NOTE="Sinnvoll für KI_Forschung, Texter_Werbung_Marketing und Rechtsberatung."
TOOL_PROMPT_EXAMPLE='```txt
Baue mit LangChain eine RAG-Kette, die lokale Dokumente analysiert und Antworten über Ollama generiert.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
