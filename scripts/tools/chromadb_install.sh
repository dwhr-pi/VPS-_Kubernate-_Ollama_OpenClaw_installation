#!/bin/bash
TOOL_NAME="ChromaDB"
TOOL_KEY="ChromaDB"
TOOL_SLUG="chromadb"
TOOL_PACKAGES="chromadb"
TOOL_DESCRIPTION="Lokale Vector-Datenbank für RAG, Prompt-Memory und Profilwissen."
TOOL_OPENCLAW_NOTE="Passt zu Programmierer-, Marketing- und Rechtsprofilen für Memory-Layer und RAG."
TOOL_PROMPT_EXAMPLE='```txt
Erstelle eine lokale ChromaDB-Collection für vergangene Kampagnen, Code-Snippets oder Rechtsdokumente und entwirf ein Retrieval-Schema.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
