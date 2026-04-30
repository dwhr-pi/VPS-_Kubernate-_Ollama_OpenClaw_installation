#!/bin/bash
TOOL_NAME="MinIO"
TOOL_KEY="MinIO"
TOOL_SLUG="minio"
TOOL_GIT_REPO="https://github.com/minio/minio.git"
COMPOSE_YAML='services:
  minio:
    image: quay.io/minio/minio:latest
    container_name: minio
    restart: unless-stopped
    env_file:
      - .env
    command: server /data --console-address ":9001"
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - ./data:/data'
TOOL_ENV_FILE_CONTENT='MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=change-me-please'
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
install_github_docker_stack_tool
