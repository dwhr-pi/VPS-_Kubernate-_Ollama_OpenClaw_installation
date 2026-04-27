#!/bin/bash
TOOL_NAME="RabbitMQ"
TOOL_KEY="RabbitMQ"
APT_PACKAGES="rabbitmq-server"
TOOL_ENABLE_SERVICE="rabbitmq-server"
source "$(dirname "$0")/helpers/apt_tool_common.sh"
uninstall_apt_tool
