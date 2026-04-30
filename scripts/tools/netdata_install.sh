#!/bin/bash
TOOL_NAME="Netdata"
TOOL_KEY="Netdata"
TOOL_SLUG="netdata"
TOOL_GIT_REPO="https://github.com/netdata/netdata.git"
COMPOSE_YAML='services:
  netdata:
    image: netdata/netdata:latest
    container_name: netdata
    restart: unless-stopped
    ports:
      - "19999:19999"
    cap_add:
      - SYS_PTRACE
    security_opt:
      - apparmor=unconfined
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /etc/passwd:/host/etc/passwd:ro
      - /etc/group:/host/etc/group:ro'
source "$(dirname "$0")/helpers/github_docker_stack_common.sh"
install_github_docker_stack_tool
