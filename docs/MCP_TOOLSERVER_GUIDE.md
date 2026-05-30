# MCP Toolserver Guide

MCP-Server sollen Tools kontrolliert fuer Agenten bereitstellen.

## Geplante lokale MCP-Server

- filesystem
- git
- github
- shell
- browser
- sqlite
- postgres
- fetch
- memory

## Sicherheitsregeln

- Read-only-first.
- Schreibrechte nur nach Freigabe.
- Shell-Zugriff stark begrenzen.
- Keine Secrets in Prompts oder Logs.
- Netzwerkzugriffe allowlisten.

## Tool-Registry

Die MCP-Bausteine sind als planned/manual Tools registriert und installieren
nichts automatisch.
