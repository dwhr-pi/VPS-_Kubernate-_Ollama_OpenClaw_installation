#!/bin/bash
TOOL_NAME="Vault"
TOOL_KEY="Vault"
TOOL_SLUG="vault"
COMPOSE_YAML='services:
  vault:
    image: hashicorp/vault:1.17
    container_name: vault
    cap_add:
      - IPC_LOCK
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: change-me
      VAULT_DEV_LISTEN_ADDRESS: 0.0.0.0:8200
    ports:
      - "8200:8200"'
TOOL_DESCRIPTION="Lokale Vault-Instanz für Secrets-Management und sichere Profileingaben."
TOOL_OPENCLAW_NOTE="Hilft beim Trennen von Secrets, API-Keys und OpenClaw-Profilkonfigurationen."
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
