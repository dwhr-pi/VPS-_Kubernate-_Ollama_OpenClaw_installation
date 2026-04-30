#!/bin/bash
TOOL_NAME="Promptfoo"
TOOL_KEY="Promptfoo"
TOOL_SLUG="promptfoo"
TOOL_DESCRIPTION="Prompt-, Agenten- und RAG-Testframework für Qualität, Regressionen und Red-Teaming."
TOOL_MODULE_TYPE="AI-Evaluation-Scaffold"
TOOL_GIT_REPO="https://github.com/promptfoo/promptfoo.git"
TOOL_APT_PACKAGES="git nodejs npm"
TOOL_POST_INSTALL='if [ -f package.json ]; then npm install && npm run build || npm install; fi'
TOOL_PROMPT_EXAMPLE='# Beispielprompts für Promptfoo

```txt
Erzeuge eine Testsuite für Prompts, RAG-Antworten und Sicherheitsfälle und dokumentiere die wichtigsten Regressionen im Setup.
```'
TOOL_OPENCLAW_NOTE="Promptfoo dient hier als Test- und Eval-Schicht für Prompts, RAG-Pipelines und Guardrail-Regeln."
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
