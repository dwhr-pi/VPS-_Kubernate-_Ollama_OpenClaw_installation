#!/bin/bash
TOOL_NAME="RabbitMQ"
TOOL_KEY="RabbitMQ"
APT_PACKAGES="rabbitmq-server"
TOOL_ENABLE_SERVICE="rabbitmq-server"
TOOL_DESCRIPTION="Message-Broker für Queue-basierte Agentenorchestrierung und Workflow-Entkopplung."
TOOL_OPENCLAW_NOTE="Ergänzt Redis/NATS, wenn robustere Queue-Semantik oder Dead-Letter-Queues gebraucht werden."
source "$(dirname "$0")/helpers/apt_tool_common.sh"
install_apt_tool
