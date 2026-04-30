#!/bin/bash
TOOL_NAME="Langfuse"
TOOL_KEY="Langfuse"
TOOL_SLUG="langfuse"
TOOL_GIT_REPO="https://github.com/langfuse/langfuse.git"
COMPOSE_YAML='services:
  langfuse-db:
    image: postgres:16
    container_name: langfuse-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: langfuse
      POSTGRES_USER: langfuse
      POSTGRES_PASSWORD: langfuse
    volumes:
      - ./postgres:/var/lib/postgresql/data
  langfuse:
    image: ghcr.io/langfuse/langfuse:latest
    container_name: langfuse
    restart: unless-stopped
    env_file:
      - .env
    depends_on:
      - langfuse-db
    ports:
      - "3003:3000"'
TOOL_ENV_FILE_CONTENT='DATABASE_URL=postgresql://langfuse:langfuse@langfuse-db:5432/langfuse
NEXTAUTH_SECRET=change-me
SALT=change-me
NEXTAUTH_URL=http://localhost:3003
TELEMETRY_ENABLED=false'
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
install_github_docker_stack_tool
