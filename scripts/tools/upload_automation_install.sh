#!/bin/bash
TOOL_NAME="Upload_Automation"
TOOL_KEY="Upload_Automation"
TOOL_SLUG="upload_automation"
TOOL_DESCRIPTION="Connector-Modul für Upload-, Publish- und Übergabe-Workflows."
TOOL_MODULE_TYPE="Workflow-Modul"
TOOL_OPENCLAW_NOTE="Ergänzt Content_Automation mit offenen Übergabepunkten für APIs, Cloud-Ziele und Publish-Schritte."
TOOL_ENV_TEMPLATE='UPLOAD_TARGET=manual\nPRIMARY_CHANNEL=youtube\nSECONDARY_CHANNEL=tiktok'
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
