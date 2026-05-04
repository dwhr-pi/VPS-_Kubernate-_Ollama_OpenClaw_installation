#!/bin/bash
set -euo pipefail
TOOL_NAME="Argilla"
TOOL_KEY="Argilla"
TOOL_SLUG="argilla"
COMPOSE_YAML='services:
  argilla:
    image: argilla/argilla-quickstart:latest
    container_name: argilla
    restart: unless-stopped
    ports:
      - "127.0.0.1:6900:6900"
    volumes:
      - ./data:/var/lib/argilla
'
TOOL_DESCRIPTION="Self-Hosted Data-Curation- und Feedback-Plattform für Annotation, Review und LLM-Dataset-Arbeit."
TOOL_PROMPT_EXAMPLE='Argilla lokal für Review-Workflows, Labeling und Feedback-Loops in RAG- oder Fine-Tuning-Projekten vorbereiten.'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
