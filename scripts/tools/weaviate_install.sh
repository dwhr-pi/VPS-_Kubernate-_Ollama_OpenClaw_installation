#!/bin/bash
TOOL_NAME="Weaviate"
TOOL_KEY="Weaviate"
TOOL_SLUG="weaviate"
COMPOSE_YAML='services:
  weaviate:
    image: semitechnologies/weaviate:latest
    container_name: weaviate
    restart: unless-stopped
    ports:
      - "8081:8080"
    environment:
      QUERY_DEFAULTS_LIMIT: "25"
      AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED: "true"
      PERSISTENCE_DATA_PATH: "/var/lib/weaviate"
      DEFAULT_VECTORIZER_MODULE: "none"
      CLUSTER_HOSTNAME: "node1"
    volumes:
      - ./data:/var/lib/weaviate'
TOOL_PROMPT_EXAMPLE='```txt
Baue mit Weaviate eine Wissensbasis für mehrere Profile und beschreibe ein Schema für Agenten-Memory und Retrieval.
```'
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
