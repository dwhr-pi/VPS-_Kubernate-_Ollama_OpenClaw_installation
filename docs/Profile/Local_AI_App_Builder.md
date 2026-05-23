# Local_AI_App_Builder

Status: planned  
Kategorie: Entwicklung, Dashboard, Desktop  
Installationsart: lokal-first, WSL2/Linux, optional Desktop-Bruecke zu Windows

## Zweck

Dieses Profil buendelt lokale App-Entwicklung fuer Dashboards, Admin-UIs, Companion-Apps und Setup-Frontends.

## Varianten

- `Desktop_App_Builder`: lokale Desktoptools und kleine Helferapps
- `Electron_Tauri_App_Builder`: Desktop-Apps mit Tauri oder Electron
- `React_Dashboard_Builder`: WebUIs mit React/Vite/Playwright

## Toolbasis

| Tool | Aufgabe | Status |
|---|---|---|
| Node.js LTS | Runtime und Build | stabil |
| pnpm/Corepack | Paketmanagement | stabil |
| Vite/React | Dashboards | empfohlen |
| Playwright | UI-Tests | empfohlen |
| Tauri | leichte Desktop-Apps | optional |
| Electron | Desktop-Apps mit Webstack | optional/schwerer |
| shadcn/ui | UI-Bausteine | optional |

## Safe Defaults

- Keine Admin-Oberflaechen automatisch auf `0.0.0.0`.
- `.env.example` statt echter Secrets.
- Lokale Ports dokumentieren und nach Installation pruefen.

## Beispielworkflow

1. OpenClaw nimmt eine Dashboard-Idee auf.
2. Ollama erzeugt Komponentenentwurf und Datenmodell.
3. Vite/React erstellt lokale UI.
4. Playwright prueft Kernpfade.
5. Das Setup verlinkt nur localhost oder Tailnet.

