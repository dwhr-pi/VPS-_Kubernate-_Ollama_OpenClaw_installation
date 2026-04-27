#!/bin/bash
TOOL_NAME="Exchange_APIs"
TOOL_KEY="Exchange_APIs"
TOOL_SLUG="exchange_apis"
TOOL_PACKAGES="ccxt"
TOOL_DESCRIPTION="Exchange-API-Bibliothek für Markt-, Konto- und Orderdaten."
TOOL_OPENCLAW_NOTE="Ergänzt Trading_AI für Strategie-Tests, Börsenanbindungen und Marktdaten."
TOOL_PROMPT_EXAMPLE='```txt
Entwirf eine Exchange-API-Anbindung für Markt- und Kursdaten und bereite damit einen Backtest-Workflow vor.
```'
source "$(dirname "$0")/helpers/python_tool_common.sh"
install_python_tool
