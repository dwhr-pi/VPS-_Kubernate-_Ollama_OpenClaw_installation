#!/bin/bash
TOOL_NAME="Web3_APIs"
TOOL_KEY="Web3_APIs"
TOOL_SLUG="web3_apis"
TOOL_PACKAGES="web3"
TOOL_DESCRIPTION="Python-Bibliothek für Web3- und Blockchain-Integrationen."
TOOL_OPENCLAW_NOTE="Ergänzt das Trading_AI-Profil für Chain-Daten, Wallet- und Protokollabfragen."
TOOL_PROMPT_EXAMPLE='```txt
Verbinde mein Trading-Profil mit Web3-Datenquellen und skizziere eine Risiko- und Marktabfrage für On-Chain-Daten.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
