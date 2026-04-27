#!/bin/bash
TOOL_NAME="Neo4j"
TOOL_KEY="Neo4j"
TOOL_SLUG="neo4j"
COMPOSE_YAML='services:
  neo4j:
    image: neo4j:5
    environment:
      NEO4J_AUTH: neo4j/change-me
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - ./data:/data'
TOOL_DESCRIPTION="Graphdatenbank für Beziehungsanalysen, Wissensgraphen und Legal-/Research-Fälle."
TOOL_OPENCLAW_NOTE="Kann im Rechtsprofil für Fallbeziehungen, Fristen und Risiko-Scoring dienen."
source "$(dirname "$0")/helpers/docker_compose_tool_common.sh"
install_docker_compose_tool
