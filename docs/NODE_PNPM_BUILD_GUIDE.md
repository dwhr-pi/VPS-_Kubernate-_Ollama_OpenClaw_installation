# Node pnpm Build Guide

## Ziel

Node-/pnpm-Builds sollen reproduzierbarer werden und nicht durch globale Versionen kaputtgehen.

## Empfehlungen

- Node LTS per nvm/fnm oder klar dokumentierter Systemquelle.
- `corepack enable` verwenden, wenn Projekt `packageManager` setzt.
- `pnpm-workspace.yaml` nutzen, wenn ein Repo Workspaces erwartet.
- Keine globalen `pnpm add -g` ohne Grund.

## Fehlerbilder

| Fehler | Ursache | Reparatur |
|---|---|---|
| `ERR_PNPM_WORKSPACE_PKG_NOT_FOUND` | Workspace-Paket fehlt oder falscher Checkout | Upstream-Doku pruefen, Submodule/Monorepo-Pfade pruefen |
| `Script not found build` | Upstream hat kein Buildscript im Root | richtige Workspace-App bauen |
| `buildx plugin` fehlt | Docker Compose Build braucht buildx | Docker Buildx installieren/aktivieren |
| `RUN --mount requires BuildKit` | BuildKit deaktiviert | `DOCKER_BUILDKIT=1` setzen |

## Safe Default

Bei Build-Fehlern nicht automatisch weitere schwere Tools installieren. Log anzeigen, Diagnose erzeugen, naechstes Tool nur nach Freigabe.
