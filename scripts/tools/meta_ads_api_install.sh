#!/bin/bash
TOOL_NAME="Meta_Ads_API"
TOOL_KEY="Meta_Ads_API"
TOOL_SLUG="meta_ads_api"
TOOL_DESCRIPTION="Connector-Modul für Meta Ads Daten- und Kampagnenflows."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='META_APP_ID=\nMETA_APP_SECRET=\nMETA_ACCESS_TOKEN='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
