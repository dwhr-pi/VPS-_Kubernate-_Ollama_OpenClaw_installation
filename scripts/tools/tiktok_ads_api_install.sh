#!/bin/bash
TOOL_NAME="TikTok_Ads_API"
TOOL_KEY="TikTok_Ads_API"
TOOL_SLUG="tiktok_ads_api"
TOOL_DESCRIPTION="Connector-Modul für TikTok Ads Kampagnen- und Performance-Daten."
TOOL_MODULE_TYPE="Marketing-Connector"
TOOL_ENV_TEMPLATE='TIKTOK_ADS_ACCESS_TOKEN=\nTIKTOK_ADS_ADVERTISER_ID='
source "$(dirname "$0")/helpers/scaffold_tool_common.sh"
install_scaffold_tool
