# Penpot Stack

Dieser Stack basiert inhaltlich auf dem offiziellen Penpot-Docker-Compose-Beispiel und wurde fuer dieses Repository vorsichtig angepasst:

- Web-UI standardmaessig nur auf `127.0.0.1`
- Standardport fuer Penpot hier: `9011` statt `9001`, um Kollisionen mit MinIO zu vermeiden
- Mailcatch nur lokal auf `1081`
- PostgreSQL und Valkey bleiben intern im Compose-Netz
- `PENPOT_PUBLIC_URI` muss angepasst werden, wenn Penpot ueber Reverse Proxy, Cloudflare Tunnel oder Tailscale veroeffentlicht wird

Wichtige Dateien:

- `docker-compose.penpot.yml`
- `penpot.env.example`

Fuer MCP ist in diesem Repository vorerst nur die Doku vorbereitet. Der offizielle Penpot-MCP-Server ist inzwischen in das Hauptrepo `penpot/penpot` integriert und sollte erst bewusst separat aktiviert werden.
